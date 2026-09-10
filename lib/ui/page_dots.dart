import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';

/// Tanıtım ekranlarının 3 noktalı sayfa göstergesi.
/// Aktif nokta `--accent`, pasif `--track`.
class PageDots extends StatelessWidget {
  const PageDots({required this.count, required this.index, super.key});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == index ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i == index ? t.accent : t.track,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
      ],
    );
  }
}
