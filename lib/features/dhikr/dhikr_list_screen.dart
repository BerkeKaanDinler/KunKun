import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/models/models.dart';
import '../../ui/atoms.dart';
import '../../ui/buttons.dart';
import '../../ui/icons.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../domain/usecases/streak.dart';
import '../../ui/glass.dart';
import '../../ui/states.dart';
import '../../ui/surfaces.dart';
import 'dhikr_session.dart';

class DhikrTab extends Notifier<int> {
  @override
  int build() => 0;
  void select(int i) => state = i;
}

final dhikrTabProvider = NotifierProvider<DhikrTab, int>(DhikrTab.new);

/// Z1 / Z5 · Hazır zikirler ve Serbest zikirlerim — `Zikir Ekranlari.dc.html`
///
/// Geri + istatistik ikonu · 34 px "Zikir" · sekme · "Sırayla başla" aksan
/// kartı · "NAMAZ SONRASI ZİKİRLERİ" + 4 satır · dipnot.
///
/// **Hazır set sabittir**: metin, anlam ve sayı değiştirilemez, silinemez —
/// bu ekranda düzenleme veya silme yolu yoktur.
class DhikrListScreen extends ConsumerWidget {
  const DhikrListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final tab = ref.watch(dhikrTabProvider);
    final presets = ref.watch(dhikrPresetsProvider).value ?? const [];
    final custom = ref.watch(customDhikrProvider).value ?? const [];

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
            BackRow(
              onBack: () => context.pop(),
              label: '',
              trailing: KunIconButton(
                icon: KunIcons.stats,
                semanticLabel: 'İstatistik',
                onPressed: () => context.push('/zikir/istatistik'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KunMetrics.gutterText,
                4,
                KunMetrics.gutterText,
                0,
              ),
              child: Text(
                'Zikir',
                style: context.type.screenTitle(t.textPrimary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KunMetrics.gutterCard,
                14,
                KunMetrics.gutterCard,
                0,
              ),
              child: KunTabs(
                labels: const ['Hazır zikirler', 'Serbest'],
                index: tab,
                onChanged: (i) => ref.read(dhikrTabProvider.notifier).select(i),
              ),
            ),
            Expanded(
              child: tab == 0
                  ? _PresetTab(presets: presets)
                  : _CustomTab(items: custom),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetTab extends ConsumerWidget {
  const _PresetTab({required this.presets});

  final List<DhikrPreset> presets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KunMetrics.gutterCard,
        16,
        KunMetrics.gutterCard,
        KunMetrics.v16,
      ),
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: presets.isEmpty
              ? null
              : () {
                  ref.read(dhikrSessionProvider.notifier).startPreset(presets);
                  context.push('/zikir/sayac');
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
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
                        'Sırayla başla',
                        style: context.type
                            .cardTitle(t.onAccent, size: 21)
                            .copyWith(letterSpacing: 21 * -0.01),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _setSummary(presets),
                        style: context.type.caption(
                          t.onAccent.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Icon(KunIcons.arrowRight, size: 22, color: t.onAccent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionHeader(
          'Namaz sonrası zikirleri',
          trailing: Text(
            '${presets.length}',
            style: context.type.meta(t.textTertiary),
          ),
        ),
        DividedCard(
          radius: t.radiusLg > 8 ? 18 : t.radiusMd,
          children: [
            for (var i = 0; i < presets.length; i++)
              _PresetRow(
                preset: presets[i],
                onTap: () {
                  ref
                      .read(dhikrSessionProvider.notifier)
                      .startPreset(presets, stepIndex: i);
                  context.push('/zikir/sayac');
                },
              ),
          ],
        ),
        const SizedBox(height: KunMetrics.v12),
        Text(
          'Namaz sonrası dört adım sabittir; metin, anlam ve sayı '
          'değiştirilemez.',
          style: context.type
              .caption(t.textTertiary, size: 12)
              .copyWith(height: 1.5),
        ),
      ],
    );
  }

  static String _setSummary(List<DhikrPreset> presets) {
    if (presets.isEmpty) return '';
    final counts = presets.map((p) => '${p.targetCount}').toList();
    final last = presets.last;
    return '${counts.take(counts.length - 1).join(' · ')} · '
        'kapanışta ${last.nameTr} ${last.targetCount}';
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.preset, required this.onTap});

  final DhikrPreset preset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: KunMetrics.minTouch),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 9,
                      children: [
                        Text(
                          preset.nameTr,
                          style: context.type
                              .listRow(t.textPrimary, size: 17)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            preset.textAr,
                            style: context.type.arabicText(t.accent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      preset.meaning,
                      style: context.type
                          .caption(t.textSecondary)
                          .copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              KunBadge('${preset.targetCount}'),
              const SizedBox(width: 9),
              Icon(KunIcons.chevron, size: 14, color: t.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomTab extends ConsumerWidget {
  const _CustomTab({required this.items});

  final List<CustomDhikr> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    if (items.isEmpty) {
      return Center(
        child: KunStateView.empty(
          title: KunStateCopy.customDhikr.title,
          description: KunStateCopy.customDhikr.body,
          actionLabel: KunStateCopy.customDhikr.action,
          onAction: () => context.push('/zikir/ekle'),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KunMetrics.gutterCard,
        14,
        KunMetrics.gutterCard,
        KunMetrics.v16,
      ),
      children: [
        const _StreakCard(),
        const SizedBox(height: KunMetrics.v16),
        SectionHeader(
          'Kendi zikirlerim',
          trailing: Text(
            '${items.length}',
            style: context.type.meta(t.textTertiary),
          ),
        ),
        DividedCard(
          radius: t.radiusLg > 8 ? 18 : t.radiusMd,
          children: [
            for (final c in items)
              _CustomRow(
                dhikr: c,
                onTap: () {
                  ref.read(dhikrSessionProvider.notifier).startCustom(c);
                  context.push('/zikir/sayac');
                },
                onDelete: () =>
                    ref.read(dhikrRepositoryProvider).removeCustom(c.id),
              ),
          ],
        ),
        const SizedBox(height: KunMetrics.v14),
        SecondaryButton(
          label: 'Serbest zikir ekle',
          onPressed: () => context.push('/zikir/ekle'),
        ),
        const SizedBox(height: KunMetrics.v12),
        Text(
          'Serbest zikirler yalnızca cihazda saklanır, yedeklenmez. '
          'Hedef yoktur; sayaç durmaz.',
          style: context.type
              .caption(t.textTertiary, size: 12)
              .copyWith(height: 1.5),
        ),
      ],
    );
  }
}

class _CustomRow extends StatelessWidget {
  const _CustomRow({
    required this.dhikr,
    required this.onTap,
    required this.onDelete,
  });

  final CustomDhikr dhikr;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Dismissible(
      key: ValueKey('dhikr-${dhikr.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: ColoredBox(
        color: t.danger,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(KunIcons.delete, size: 20, color: Color(0xFFFFFFFF)),
              const SizedBox(width: 8),
              Text(
                'Sil',
                style: context.type.listRow(const Color(0xFFFFFFFF), size: 15),
              ),
            ],
          ),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          color: t.surfaceRaised,
          constraints: const BoxConstraints(minHeight: KunMetrics.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ad kendi satırında, kırpılmaz.
                    Text(
                      dhikr.name,
                      style: context.type
                          .listRow(t.textPrimary, size: 15.5)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (dhikr.textAr != null) ...[
                      const SizedBox(height: 4),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          dhikr.textAr!,
                          style: context.type.arabicText(t.accent),
                        ),
                      ),
                    ],
                    if (dhikr.meaning != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        dhikr.meaning!,
                        style: context.type.caption(t.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 13),
              // Serbest tarafta hedef yok — rozet ∞, aksan renginde.
              const KunBadge('∞', accented: true),
              const SizedBox(width: 9),
              Icon(KunIcons.chevron, size: 14, color: t.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Z5 · seri kartı — `Zikir Ekranlari.dc.html`
///
/// Cam kart (dolgu 13/15, köşe 18): 38 px aksan yuvarlağında seri sayısı,
/// "N günlük seri", "Bugün N zikir · M'si serbest listenden",
/// sağda 7 çubuklu mini grafik (26 px yükseklik, bugünkü çubuk `--accent`).
class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final stats = ref.watch(dailyStatsProvider).value ?? const <DailyStat>[];
    final now = DateTime.now();
    final streak = StreakCalculator.compute(stats, now: now);

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
    final today = last7.last;
    final maxDay = last7.fold<int>(
      1,
      (a, b) => b.totalCount > a ? b.totalCount : a,
    );

    return GlassSurface(
      radius: t.radiusLg > 8 ? 18 : t.radiusMd,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: t.accent, shape: BoxShape.circle),
            child: Text(
              '${streak.current}',
              style: context.type
                  .cardTitle(t.onAccent, size: 15)
                  .copyWith(height: 1),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${streak.current} günlük seri',
                  style: context.type
                      .listRow(t.textPrimary, size: 14.5)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  today.totalCount == 0
                      ? 'Bugün henüz zikir yok'
                      : 'Bugün ${today.totalCount} zikir · '
                            "${today.customCount}'si serbest listenden",
                  style: context.type.caption(t.textSecondary, size: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 26,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < last7.length; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Container(
                    width: 5,
                    height: (last7[i].totalCount / maxDay * 26).clamp(
                      4.0,
                      26.0,
                    ),
                    decoration: BoxDecoration(
                      color: i == last7.length - 1 && today.totalCount > 0
                          ? t.accent
                          : t.track,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
