import 'package:flutter/material.dart'
    show TextSelectionTheme, TextSelectionThemeData;
import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';
import 'metrics.dart';

/// Tek satır metin alanı · 52 px · `--surface-raised` · odakta kenar `--accent`.
class KunTextField extends StatefulWidget {
  const KunTextField({
    required this.controller,
    this.hint,
    this.textDirection,
    this.onSubmitted,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final TextEditingController controller;
  final String? hint;
  final TextDirection? textDirection;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextAlign textAlign;

  @override
  State<KunTextField> createState() => _KunTextFieldState();
}

class _KunTextFieldState extends State<KunTextField> {
  late final FocusNode _focus = FocusNode()..addListener(_onChange);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _focus
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final focused = _focus.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      constraints: const BoxConstraints(minHeight: 52),
      // Tasarım `0d`: dolgu 16, köşe --radius-sm, kenar --accent (odakta).
      padding: const EdgeInsets.all(KunMetrics.v16),
      decoration: BoxDecoration(
        color: t.surfaceRaised,
        border: Border.all(color: focused ? t.accent : t.border, width: 1),
        borderRadius: BorderRadius.circular(t.radiusSm),
      ),
      child: Center(
        child: TextSelectionTheme(
          data: TextSelectionThemeData(
            cursorColor: t.accent,
            selectionColor: t.accentSoft,
            selectionHandleColor: t.accent,
          ),
          child: Stack(
            children: [
              // EditableText yer tutucu desteklemez; altına ayrı çizilir.
              if (widget.controller.text.isEmpty && widget.hint != null)
                Positioned.fill(
                  child: Align(
                    alignment: widget.textAlign == TextAlign.center
                        ? Alignment.center
                        : AlignmentDirectional.centerStart,
                    child: Text(
                      widget.hint!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: widget.textDirection,
                      style: context.type.body(t.textTertiary, size: 17),
                    ),
                  ),
                ),
              EditableText(
                controller: widget.controller,
                focusNode: _focus,
                autofocus: widget.autofocus,
                textDirection: widget.textDirection,
                textAlign: widget.textAlign,
                style: context.type.body(t.textPrimary, size: 17),
                cursorColor: t.accent,
                backgroundCursorColor: t.track,
                selectionColor: t.accentSoft,
                onSubmitted: widget.onSubmitted,
                maxLines: 1,
                cursorRadius: const Radius.circular(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
