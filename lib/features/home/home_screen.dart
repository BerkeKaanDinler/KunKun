import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/daily_pick.dart';
import '../../core/ports/port_providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/models/models.dart';
import '../../domain/usecases/streak.dart';
import '../../data/repositories/repositories.dart';
import '../../ui/buttons.dart';
import '../../ui/feature_gate.dart';
import '../../ui/flex_screen.dart';
import '../../ui/glass.dart';
import '../../ui/icons.dart';
import '../../ui/metrics.dart';
import '../onboarding/onboarding_controller.dart';
import 'home_hero.dart';

/// Günün ayeti — havuz kategorilere bağlı ayetlerden, seçim tarihten türetilir.
final dailyVerseProvider = FutureProvider<VerseWithTranslation?>((ref) async {
  final repo = ref.watch(verseRepositoryProvider);
  final clock = ref.watch(clockPortProvider);
  final pool = await repo.dailyPoolVerseIds();
  final ids = pool.valueOrNull ?? const <String>[];
  final i = DailyPick.verseIndex(clock.now(), ids.length);
  if (i < 0) return null;
  return (await repo.verseById(ids[i])).valueOrNull;
});

/// 5 · Ana sayfa — `Temiz Secilen Temalar.dc.html` · `1`
///
/// Kök `padding: 58px 0 22px`. Selamlama → hero (204) → günün ayeti cam kartı
/// → esnek boşluk → Ayetler aksan kartı → Tüm ayetler → Zikir.
/// **Alt gezinme çubuğu yok**; sayfa kartlarla dallanır.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final name = ref.watch(onboardingProvider).name;
    final stats = ref.watch(dailyStatsProvider).value ?? const <DailyStat>[];
    final streak = StreakCalculator.compute(stats, now: DateTime.now());
    // Beş noktalı ilerleme: son beş günün kaçında zikir var.
    final active = {
      for (final s in stats)
        if (s.totalCount > 0) s.day,
    };
    final now = DateTime.now();
    var last5Active = 0;
    for (var i = 0; i < 5; i++) {
      final d = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      if (active.contains(StreakCalculator.dayKey(d))) last5Active++;
    }

    return FlexScreen(
      children: [
        // 1 · Selamlama + kaydedilenler / ayarlar
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KunMetrics.gutterCard,
            4,
            KunMetrics.gutterCard,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name == null ? 'Merhaba' : 'Merhaba, $name',
                  style: context.type
                      .body(t.textSecondary, size: 17)
                      .copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              KunIconButton(
                icon: KunIcons.bookmarkBorder,
                semanticLabel: 'Kaydedilenler',
                onPressed: () => context.push('/kaydedilenler'),
              ),
              KunIconButton(
                icon: KunIcons.settings,
                semanticLabel: 'Ayarlar',
                onPressed: () => context.push('/ayarlar'),
              ),
            ],
          ),
        ),

        // 2 · Hero · bugünün ismi
        const Padding(
          padding: EdgeInsets.fromLTRB(
            KunMetrics.gutterCard,
            6,
            KunMetrics.gutterCard,
            0,
          ),
          child: HomeHero(),
        ),

        // 3 · Günün ayeti — sabit yüzey, blur çizilir (yoğun katman, 22)
        const Padding(
          padding: EdgeInsets.fromLTRB(
            KunMetrics.gutterCard,
            12,
            KunMetrics.gutterCard,
            0,
          ),
          child: _DailyVerseCard(),
        ),

        // 4 · Esnek boşluk
        const Expanded(child: SizedBox.shrink()),

        // 5 · Ayetler — aksan kartı
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KunMetrics.gutterCard,
          ),
          child: _AccentCard(
            title: 'Ayetler',
            subtitle: 'Hissettiğin duyguya veya duruma göre ayetler',
            onTap: () => context.push('/kesif'),
          ),
        ),

        // 6 · Tüm ayetler — sequential kapalıysa hiç çizilmez
        if (FeatureGate.showSequentialCard)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KunMetrics.gutterCard,
              9,
              KunMetrics.gutterCard,
              2,
            ),
            child: _BranchCard(
              title: 'Tüm ayetler',
              subtitle: 'Tüm ayetleri oku veya sesli dinle',
              // Ü1 · ses kapalıyken oynat butonu çizilmez, kart oka dallanır.
              trailing: FeatureGate.homePlayButton(
                () => const _RoundPlayButton(),
              ),
              onTap: () => context.push('/tum-ayetler'),
            ),
          ),

        // 7 · Zikir
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KunMetrics.gutterCard,
            9,
            KunMetrics.gutterCard,
            2,
          ),
          child: _BranchCard(
            title: 'Zikir',
            subtitle: streak.current == 0
                ? 'Tesbih sayacı'
                : 'Tesbih sayacı · ${streak.current} günlük seri',
            trailing: _StreakDots(filled: last5Active),
            onTap: () => context.push('/zikir'),
          ),
        ),
      ],
    );
  }
}

class _DailyVerseCard extends ConsumerWidget {
  const _DailyVerseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final verse = ref.watch(dailyVerseProvider).value;

    return GlassSurface.fixed(
      layer: GlassLayer.dense,
      radius: t.radiusLg,
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'GÜNÜN AYETİ',
                  style: context.type
                      .meta(t.textSecondary, size: 11, weight: FontWeight.w600)
                      .copyWith(letterSpacing: 11 * 0.12),
                ),
              ),
              Text(
                verse?.verse.reference ?? '—',
                style: context.type
                    .caption(t.accent, size: 12.5)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            verse?.translation.text ?? 'Veri bekleniyor',
            // Ana sayfa kartı bir teaser'dır; en uzun bant (908 karakter)
            // kırpılmazsa ekranı doldurup üç dallanma kartını dışarı iter.
            // Paylaşım görselindeki "asla kırpılmaz" kuralı burayı kapsamaz.
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: context.type
                .body(t.textPrimary, size: 17.5)
                .copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// Ayetler kartı — aksan zemin, `--on-accent` metin.
class _AccentCard extends StatelessWidget {
  const _AccentCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 20),
        decoration: BoxDecoration(
          color: t.accent,
          borderRadius: BorderRadius.circular(t.radiusLg),
          boxShadow: context.shadows.primaryButton,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.type
                        .cardTitle(t.onAccent, size: 24)
                        .copyWith(letterSpacing: 24 * -0.01),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: context.type.caption(
                      t.onAccent.withValues(alpha: 0.84),
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Icon(KunIcons.arrowRight, size: 24, color: t.onAccent),
          ],
        ),
      ),
    );
  }
}

/// Tüm ayetler / Zikir — cam kart, sabit yüzey.
class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: GlassSurface.fixed(
        radius: t.radiusMd,
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.type
                        .cardTitle(t.textPrimary, size: 20)
                        .copyWith(letterSpacing: 20 * -0.01),
                  ),
                  const SizedBox(height: 5),
                  Text(subtitle, style: context.type.caption(t.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            if (trailing != null) ...[trailing!, const SizedBox(width: 10)],
            Icon(KunIcons.arrowRight, size: 22, color: t.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _RoundPlayButton extends StatelessWidget {
  const _RoundPlayButton();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
      child: Icon(KunIcons.play, size: 16, color: t.onAccent),
    );
  }
}

/// Zikir kartındaki 5 noktalı ilerleme — dolu `--accent`, boş %22.
class _StreakDots extends StatelessWidget {
  const _StreakDots({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: t.accent.withValues(alpha: i < filled ? 1 : 0.22),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ],
    );
  }
}
