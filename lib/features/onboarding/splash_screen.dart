import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens_ext.dart';
import '../../ui/logo_mark.dart';
import '../../ui/metrics.dart';
import 'onboarding_controller.dart';

/// 1 · Açılış — `Temiz Secilen Temalar.dc.html` · `0`
///
/// Kök `padding: 58px 0 34px`. Ortada dikey yığın (gap 22, yatay dolgu 30):
/// 132 px logo · "KUN" 44/700 `.14em` · 64 × 1 px aksan ayraç (%75) ·
/// "İlm-i Hâl" 21 px aksan · Arapça lafza 26 px aksan.
/// Alt kenarda 11.5 px `.08em` künye `--text-tertiary`.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1100), _go);
  }

  void _go() {
    if (!mounted) return;
    context.go(ref.read(onboardingProvider).completed ? '/ana' : '/tanitim');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: _go,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: t.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: KunMetrics.screenTop,
              bottom: KunMetrics.screenBottomOnboarding,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LogoMark(size: 132),
                        const SizedBox(height: 22),
                        Column(
                          children: [
                            Text(
                              'KUN',
                              style: context.type
                                  .cardTitle(t.textPrimary, size: 44)
                                  .copyWith(
                                    height: 1,
                                    letterSpacing: 44 * 0.14,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 64,
                              height: 1,
                              color: t.accent.withValues(alpha: 0.75),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'İlm-i Hâl',
                              style: context.type
                                  .body(t.accent, size: 21)
                                  .copyWith(height: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        // Tasarımdan birebir gelen lafza — üretilmedi.
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            'اللّٰه',
                            style: context.type.arabicText(t.accent, size: 26),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 6),
                  child: Text(
                    // Tasarımda bu künye yer tutucudur; kesin metin gelmedi.
                    'UYGULAMA ADI YER TUTUCU',
                    textAlign: TextAlign.center,
                    style: context.type
                        .meta(t.textTertiary, size: 11.5)
                        .copyWith(letterSpacing: 11.5 * 0.08),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
