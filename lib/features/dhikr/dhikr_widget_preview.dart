import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/features.dart';
import '../../core/theme/tokens_ext.dart';
import '../../ui/hero_surface.dart';
import '../../ui/icons.dart';
import '../../ui/logo_mark.dart';
import '../../ui/metrics.dart';
import 'dhikr_session.dart';

/// Z9 · Kilit ekranı widget'ı — `Zikir Ekranlari.dc.html`
///
/// **Aşama 1'de yalnızca uygulama içi önizleme** (`Features.lockWidget = false`).
///
/// Tasarımda sağda beyaz `+1` pill butonu var; bu **etkileşimli widget**
/// demektir (iOS 17+ App Intents, App Group ile paylaşılan sayaç durumu).
/// Aşama 3 işi — önizlemede buton çizilir ama sayacı artırmaz.
class DhikrWidgetPreviewScreen extends ConsumerWidget {
  const DhikrWidgetPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final s = ref.watch(dhikrSessionProvider);
    final target = s.target;
    final progress = target == null || target == 0
        ? 0.0
        : (s.count / target).clamp(0.0, 1.0);

    return ColoredBox(
      color: t.heroSurface,
      child: Stack(
        children: [
          if (t.isGlass)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x47000000),
                      Color(0x0D000000),
                      Color(0x70000000),
                    ],
                    stops: [0.22, 0.46, 1],
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '9:41',
                    textAlign: TextAlign.center,
                    style: context.type
                        .cardTitle(HeroText.primary, size: 78)
                        .copyWith(fontWeight: FontWeight.w600, height: 1.05),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x29FFFFFF),
                      border: Border.all(
                        color: const Color(0x3DFFFFFF),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const LogoMark(size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ZİKİR · ${s.title.toUpperCase()}',
                                style: context.type
                                    .meta(HeroText.secondary, size: 10.5)
                                    .copyWith(letterSpacing: 10.5 * 0.12),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${s.count}',
                                    style: context.type.counter(
                                      HeroText.primary,
                                      size: 26,
                                    ),
                                  ),
                                  if (target != null)
                                    Text(
                                      ' / $target',
                                      style: context.type.body(
                                        HeroText.tertiary,
                                        size: 14,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: SizedBox(
                                  height: 5,
                                  child: Stack(
                                    children: [
                                      const Positioned.fill(
                                        child: ColoredBox(
                                          color: Color(0x1FFFFFFF),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: progress,
                                        child: ColoredBox(color: t.accent),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                s.isPreset
                                    ? 'Namaz sonrası seti · '
                                          '${s.stepIndex + 1}/${s.presets.length} adım'
                                    : 'Serbest · sınırsız',
                                style: context.type.caption(
                                  HeroText.tertiary,
                                  size: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tasarımdaki beyaz +1 pill'i. Önizlemede pasif:
                        // etkileşimli widget Aşama 3 (App Intents + App Group).
                        Opacity(
                          opacity: Features.lockWidget ? 1 : 0.55,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '+1',
                              style: context.type
                                  .listRow(const Color(0xFF10100F), size: 15)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Kilit ekranından sayaç artırma etkileşimli widget gerektirir '
                    '(iOS 17+). Aşama 3\'te native olarak gelecek.',
                    style: context.type
                        .caption(HeroText.tertiary, size: 10.5)
                        .copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.pop(),
                      child: const SizedBox(
                        width: KunMetrics.minTouch,
                        height: KunMetrics.minTouch,
                        child: Icon(
                          KunIcons.back,
                          size: 18,
                          color: HeroText.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x2EFFFFFF),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'ÖNİZLEME',
                        style: context.type.meta(HeroText.primary, size: 10.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
