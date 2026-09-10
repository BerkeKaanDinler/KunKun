import 'package:flutter/widgets.dart';

import '../../core/theme/tokens_ext.dart';
import '../../ui/metrics.dart';

/// Tanıtım 1–2 ve İsim ekranlarının ortak iskeleti —
/// `Temiz Secilen Temalar.dc.html` · `0b`, `0c`, `0d`.
///
/// Kök `padding: 58px 0 34px` · sağ üstte "Atla" (17 px aksan, min 44 px) ·
/// ortada dikey ortalı içerik (yatay dolgu 24) · altta 3 nokta (alt 18 px) ·
/// en altta birincil buton (yatay 18, alt 4).
class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    required this.content,
    required this.stepIndex,
    required this.buttonLabel,
    required this.onButton,
    required this.onSkip,
    this.contentGap = 26,
    super.key,
  });

  final List<Widget> content;
  final int stepIndex;
  final String buttonLabel;
  final VoidCallback onButton;
  final VoidCallback onSkip;
  final double contentGap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return ColoredBox(
      color: t.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: KunMetrics.screenTop,
            bottom: KunMetrics.screenBottomOnboarding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // "Atla" — tasarımda üç ekranın da sağ üstünde.
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onSkip,
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: KunMetrics.minTouch,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      // widthFactor: 1 olmadan Container alignment'la tüm
                      // genişliği doldurur ve "Atla" ortalanır.
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          'Atla',
                          style: context.type.body(t.accent, size: 17),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < content.length; i++) ...[
                        if (i > 0) SizedBox(height: contentGap),
                        content[i],
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _Dots(index: stepIndex),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onButton,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.accent,
                      borderRadius: BorderRadius.circular(t.radiusSm),
                      boxShadow: context.shadows.primaryButton,
                    ),
                    child: Text(
                      buttonLabel,
                      style: context.type
                          .listRow(t.onAccent, size: 17)
                          .copyWith(height: 1.15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3 nokta · aktif 20 × 7, pasif 7 × 7. Aktif `--accent`, pasif `--track`.
class _Dots extends StatelessWidget {
  const _Dots({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: i == index ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index ? t.accent : t.track,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ],
    );
  }
}
