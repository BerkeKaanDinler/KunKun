import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';
import 'icons.dart';
import 'metrics.dart';

/// Geri satırı — tasarımda `padding: 2px 8px 0`, min 44 px,
/// 40 × 44 chevron + 17 px "Geri", ikisi de `--accent`.
class BackRow extends StatelessWidget {
  const BackRow({
    required this.onBack,
    this.label = 'Geri',
    this.trailing,
    super.key,
  });

  final VoidCallback onBack;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: KunMetrics.minTouch),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: SizedBox(
                height: KunMetrics.minTouch,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Icon(KunIcons.back, size: 18, color: t.accent),
                    ),
                    Text(label, style: context.type.body(t.accent, size: 17)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Arama alanı — cam kart, köşe 14, dolgu 11/13.
/// Aşama 1'de pasif: arama Aşama 2'de FTS5 ile geliyor.
class SearchField extends StatelessWidget {
  const SearchField({required this.hint, this.onTap, super.key});

  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: t.glassFill,
          border: Border.all(color: t.glassBorder, width: 1),
          borderRadius: BorderRadius.circular(t.radiusSm),
        ),
        child: Row(
          children: [
            Icon(KunIcons.search, size: 16, color: t.textTertiary),
            const SizedBox(width: 8),
            Text(hint, style: context.type.body(t.textTertiary, size: 17)),
          ],
        ),
      ),
    );
  }
}
