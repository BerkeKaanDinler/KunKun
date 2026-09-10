import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/models/models.dart';
import '../../domain/usecases/streak.dart';
import '../../ui/atoms.dart';
import '../../ui/glass.dart';
import '../../ui/hero_surface.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../ui/surfaces.dart';
import '../../ui/states.dart';

/// Z8 · İstatistik ve seri — `Zikir Ekranlari.dc.html`
///
/// 34 px "İstatistik" · KESİNTİSİZ SERİ hero'su · SON 7 GÜN cam kartı ·
/// üç kolon (hazır / serbest / toplam).
///
/// **Ü13:** seri `daily_stats`'ten türetilir, ayrı sayaç tutulmaz.
/// **T6:** veri yokken seri kartı ve grafik **hiç çizilmez** — sıfır dolu
/// grafik yanlış okunur.
class DhikrStatsScreen extends ConsumerWidget {
  const DhikrStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final stats = ref.watch(dailyStatsProvider).value ?? const <DailyStat>[];
    final hasData = stats.any((e) => e.totalCount > 0);

    return ColoredBox(
      color: t.surface,
      child: Padding(
        padding: EdgeInsets.only(
          top: media.padding.top > KunMetrics.screenTop
              ? media.padding.top
              : KunMetrics.screenTop,
          bottom: KunMetrics.screenBottom + media.padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackRow(onBack: () => context.pop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KunMetrics.gutterText,
                4,
                KunMetrics.gutterText,
                0,
              ),
              child: Text(
                'İstatistik',
                style: context.type.screenTitle(t.textPrimary),
              ),
            ),
            Expanded(
              child: hasData
                  ? _Content(stats: stats)
                  : Center(
                      child: KunStateView.empty(
                        title: KunStateCopy.stats.title,
                        description: KunStateCopy.stats.body,
                        actionLabel: KunStateCopy.stats.action,
                        onAction: () => context.pop(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.stats});

  final List<DailyStat> stats;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final now = DateTime.now();
    final streak = StreakCalculator.compute(stats, now: now);

    // Son 7 gün — eksik günler 0.
    final byDay = {for (final s in stats) s.day: s};
    final last7 = <DailyStat>[];
    for (var i = 6; i >= 0; i--) {
      final d = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final key = StreakCalculator.dayKey(d);
      last7.add(
        byDay[key] ??
            DailyStat(day: key, totalCount: 0, presetCount: 0, customCount: 0),
      );
    }
    final weekTotal = last7.fold<int>(0, (a, b) => a + b.totalCount);
    final maxDay = last7.fold<int>(
      1,
      (a, b) => b.totalCount > a ? b.totalCount : a,
    );
    final preset = stats.fold<int>(0, (a, b) => a + b.presetCount);
    final custom = stats.fold<int>(0, (a, b) => a + b.customCount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KunMetrics.gutterCard,
        KunMetrics.v16,
        KunMetrics.gutterCard,
        KunMetrics.v16,
      ),
      children: [
        // Kesintisiz seri hero'su
        HeroSurface(
          height: 148,
          padding: const EdgeInsets.all(20),
          logoSize: 148,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'KESİNTİSİZ SERİ',
                style: context.type
                    .meta(
                      HeroText.secondary,
                      size: 10.5,
                      weight: FontWeight.w700,
                    )
                    .copyWith(letterSpacing: 10.5 * 0.14),
              ),
              const SizedBox(height: 8),
              Text(
                '${streak.current} gün',
                style: context.type.counter(HeroText.primary, size: 46),
              ),
              const SizedBox(height: 6),
              Text(
                'En uzun seri ${streak.longest} gün',
                style: context.type.caption(HeroText.tertiary, size: 12.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: KunMetrics.v12),

        // Son 7 gün
        GlassSurface.fixed(
          radius: t.radiusLg,
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'SON 7 GÜN',
                      style: context.type
                          .meta(
                            t.textSecondary,
                            size: 11,
                            weight: FontWeight.w600,
                          )
                          .copyWith(letterSpacing: 11 * 0.12),
                    ),
                  ),
                  Text(
                    '$weekTotal zikir',
                    style: context.type
                        .caption(t.accent, size: 12.5)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: KunMetrics.v14),
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < last7.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: (last7[i].totalCount / maxDay * 120).clamp(
                            3.0,
                            120.0,
                          ),
                          decoration: BoxDecoration(
                            color: i == last7.length - 1 ? t.accent : t.track,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KunMetrics.v12),

        // Üç kolon
        GlassSurface(
          radius: t.radiusMd,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Col(value: '$preset', label: 'hazır'),
              _Col(value: '$custom', label: 'serbest'),
              _Col(value: '${preset + custom}', label: 'toplam', accent: true),
            ],
          ),
        ),
        const SizedBox(height: KunMetrics.v20),
        const _MostPerformed(),
        const SizedBox(height: KunMetrics.v20),
        SectionHeader('Kural'),
        Text(
          'Bir günün sayılması için en az 1 zikir yeterlidir. Gün sınırı yerel '
          'saat gece yarısıdır. Seri günlük toplamlardan türetilir; cihaz saati '
          'geri alınırsa seri ne kırılır ne şişer.',
          style: context.type
              .caption(t.textTertiary, size: 12)
              .copyWith(height: 1.55),
        ),
      ],
    );
  }
}

class _Col extends StatelessWidget {
  const _Col({required this.value, required this.label, this.accent = false});

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.type.cardTitle(
            accent ? t.accent : t.textPrimary,
            size: 19,
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: context.type.caption(t.textSecondary, size: 11)),
      ],
    );
  }
}

/// Z8 · "EN ÇOK YAPILAN" — sıra numarası monospace, ad, serbest kayıtlarda
/// "SERBEST" rozeti, sağda sayı `--accent`.
class _MostPerformed extends ConsumerWidget {
  const _MostPerformed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final stats = ref.watch(dailyStatsProvider).value ?? const <DailyStat>[];
    final presets = ref.watch(dhikrPresetsProvider).value ?? const [];
    final custom = ref.watch(customDhikrProvider).value ?? const [];

    final presetTotal = stats.fold<int>(0, (a, b) => a + b.presetCount);
    final customTotal = stats.fold<int>(0, (a, b) => a + b.customCount);
    if (presetTotal + customTotal == 0) return const SizedBox.shrink();

    // Adım bazında ayrıştırma tutulmuyor; hazır set toplamı adımlara
    // hedeflerine göre dağıtılır, serbest toplam tek satırda gösterilir.
    final rows = <({String name, int count, bool free})>[];
    final targetSum = presets.fold<int>(0, (a, b) => a + b.targetCount);
    for (final p in presets) {
      if (targetSum == 0) break;
      rows.add((
        name: p.nameTr,
        count: (presetTotal * p.targetCount / targetSum).round(),
        free: false,
      ));
    }
    if (custom.isNotEmpty && customTotal > 0) {
      rows.add((name: custom.first.name, count: customTotal, free: true));
    }
    rows.sort((a, b) => b.count.compareTo(a.count));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader('En çok yapılan'),
        DividedCard(
          children: [
            for (var i = 0; i < rows.length && i < 5; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        '${i + 1}',
                        style: context.type
                            .meta(t.textTertiary, size: 12)
                            .copyWith(letterSpacing: 0),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rows[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.body(t.textPrimary, size: 15.5),
                      ),
                    ),
                    if (rows[i].free) ...[
                      const KunBadge.soft('SERBEST'),
                      const SizedBox(width: 9),
                    ],
                    Text(
                      '${rows[i].count}',
                      style: context.type
                          .listRow(t.accent, size: 15)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
