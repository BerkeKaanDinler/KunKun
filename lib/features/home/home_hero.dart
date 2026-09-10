import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/models/models.dart';
import '../../ui/hero_surface.dart';
import '../../ui/logo_mark.dart';

final _asmaulHusnaProvider = FutureProvider<List<AsmaulHusnaEntry>>(
  (ref) async =>
      (await ref.watch(asmaulHusnaRepositoryProvider).all()).valueOrNull ??
      const [],
);

/// Ana sayfa hero'su · "Bugünün ismi" — tasarım `1` çerçevesi.
///
/// Yükseklik 204, köşe 26, `--hero-surface`, iki radyal katman,
/// sağ üstte 188 px logo (%34). İçerik sol/sağ 20, alt 18.
///
/// **Ü4:** 99 isim verisi gelmedi. Hero yerinde kalır, içerik
/// "veri bekleniyor" durumunda çizilir — isim, anlam ve Arapça **uydurulmaz**.
class HomeHero extends ConsumerWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final names = ref.watch(_asmaulHusnaProvider).value ?? const [];
    final hasData = names.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(t.isGlass ? 26 : t.radiusLg),
      child: SizedBox(
        height: 204,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: t.heroSurface)),
            if (t.isGlass) ...[
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.52, -0.64),
                      radius: 0.8,
                      colors: [
                        Color(0x38FFFFFF),
                        Color(0x38FFFFFF),
                        Color(0x00FFFFFF),
                      ],
                      stops: [0, 0.42, 0.74],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.64, 0.76),
                      radius: 0.7,
                      colors: [
                        Color(0x66000000),
                        Color(0x66000000),
                        Color(0x00000000),
                      ],
                      stops: [0, 0.40, 0.76],
                    ),
                  ),
                ),
              ),
              const Positioned(
                right: -34,
                top: -30,
                child: LogoMark(size: 188, opacity: 0.34),
              ),
            ],
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasData
                        ? 'BUGÜNÜN İSMİ · 99 İSİMDEN ${names.length}.'
                        : 'BUGÜNÜN İSMİ',
                    style: context.type
                        .meta(
                          HeroText.secondary,
                          size: 10.5,
                          weight: FontWeight.w700,
                        )
                        .copyWith(letterSpacing: 10.5 * 0.14),
                  ),
                  const SizedBox(height: 9),
                  if (hasData)
                    const SizedBox.shrink()
                  else
                    // Veri gelmedi — içerik üretilmez, yer tutucu bırakılır.
                    Text(
                      'Esmâ-i Hüsnâ verisi bekleniyor',
                      style: context.type
                          .cardTitle(HeroText.primary, size: 22)
                          .copyWith(letterSpacing: 22 * -0.02),
                    ),
                  const SizedBox(height: 7),
                  Text(
                    hasData ? '' : 'Veri geldiğinde günün ismi burada görünür',
                    style: context.type.caption(HeroText.tertiary, size: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
