import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens_ext.dart';
import '../../ui/hero_surface.dart';
import '../../ui/icons.dart';
import '../../ui/logo_mark.dart';
import '../../ui/metrics.dart';
import '../home/home_screen.dart';

/// 14–15 · Widget önizlemeleri — `Temiz Secilen Temalar.dc.html` · `8`, `8b`
///
/// **Aşama 1'de yalnızca uygulama içi önizleme** (`Features.lockWidget = false`).
/// Native widget Aşama 3.
///
/// **T4:** duvar kâğıdı gömülmez; zemin `--hero-surface` + karartma
/// gradyanından türetilir. Kâğıt indeks'te düz zemin, karartma yok.
class _WallpaperBackdrop extends StatelessWidget {
  const _WallpaperBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ColoredBox(
      color: t.heroSurface,
      child: Stack(
        children: [
          if (t.isGlass)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x33000000), Color(0x7A000000)],
                  ),
                ),
              ),
            ),
          // Geri düğmesi ve künye durum çubuğunun altında kalmasın.
          Positioned.fill(child: SafeArea(child: child)),
        ],
      ),
    );
  }
}

/// Önizleme künyesi — kullanıcı gerçek widget kurduğunu sanmasın.
class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      top: 8,
      right: 8,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const SizedBox(
              width: KunMetrics.minTouch,
              height: KunMetrics.minTouch,
              child: Icon(KunIcons.back, size: 18, color: HeroText.primary),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    );
  }
}

class LockWidgetPreviewScreen extends ConsumerWidget {
  const LockWidgetPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verse = ref.watch(dailyVerseProvider).value;

    return _WallpaperBackdrop(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 70, 22, 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '—',
                  textAlign: TextAlign.center,
                  style: context.type
                      .body(HeroText.secondary, size: 15)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '9:41',
                  textAlign: TextAlign.center,
                  style: context.type
                      .cardTitle(HeroText.primary, size: 80)
                      .copyWith(
                        fontWeight: FontWeight.w300,
                        height: 1.05,
                        letterSpacing: 80 * -0.02,
                      ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x2EFFFFFF),
                    border: Border.all(
                      color: const Color(0x3DFFFFFF),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const LogoMark(size: 17),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              verse?.verse.reference.toUpperCase() ?? '—',
                              style: context.type
                                  .meta(
                                    HeroText.secondary,
                                    size: 10.5,
                                    weight: FontWeight.w700,
                                  )
                                  .copyWith(letterSpacing: 10.5 * 0.12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        verse?.translation.text ?? 'Veri bekleniyor',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.type
                            .body(HeroText.primary, size: 16)
                            .copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Kilit ekranı widget\'ı tek renktir ve iki satırla sınırlıdır.',
                  style: context.type
                      .caption(HeroText.tertiary, size: 10.5)
                      .copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          _PreviewBadge(onBack: () => context.pop()),
        ],
      ),
    );
  }
}

class HomeWidgetPreviewScreen extends ConsumerWidget {
  const HomeWidgetPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final verse = ref.watch(dailyVerseProvider).value;

    return _WallpaperBackdrop(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 66, 22, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '9:41',
                  textAlign: TextAlign.center,
                  style: context.type.body(HeroText.secondary, size: 14),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: t.surfaceRaised,
                    borderRadius: BorderRadius.circular(t.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'GÜNÜN AYETİ',
                              style: context.type
                                  .meta(
                                    t.textSecondary,
                                    size: 10,
                                    weight: FontWeight.w700,
                                  )
                                  .copyWith(letterSpacing: 10 * 0.14),
                            ),
                          ),
                          Text(
                            verse?.verse.reference ?? '—',
                            style: context.type
                                .caption(t.accent, size: 11)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        verse?.translation.text ?? 'Veri bekleniyor',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.type
                            .body(t.textPrimary, size: 17)
                            .copyWith(height: 1.45),
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: t.accent,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 7),
                          // Ü4 · Esmâ-i Hüsnâ verisi yok, isim uydurulmaz.
                          Text(
                            'Dokun, uygulamada aç',
                            style: context.type.caption(
                              t.textSecondary,
                              size: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: t.surfaceRaised,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const LogoMark(size: 52),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Orta boy widget günde bir kez yenilenir; '
                        'küçük boy yalnızca ismi gösterir.',
                        style: context.type
                            .caption(HeroText.secondary, size: 11.5)
                            .copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _PreviewBadge(onBack: () => context.pop()),
        ],
      ),
    );
  }
}
