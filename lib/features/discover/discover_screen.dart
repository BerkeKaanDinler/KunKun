import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/result.dart';
import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/models/models.dart';
import '../../ui/glass.dart';
import '../../ui/icons.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../ui/states.dart';
import '../../ui/surfaces.dart';

/// T8 · Açılışta **Hayattan** seçili gelir.
class DiscoverAxis extends Notifier<Axis2> {
  @override
  Axis2 build() => Axis2.hayattan;

  void select(Axis2 axis) => state = axis;
}

final discoverAxisProvider = NotifierProvider<DiscoverAxis, Axis2>(
  DiscoverAxis.new,
);

final discoverProvider = FutureProvider<Result<List<CategoryGroup>>>((ref) {
  final axis = ref.watch(discoverAxisProvider);
  return ref.watch(categoryRepositoryProvider).discover(axis);
});

/// 7 · Keşif — `Temiz Secilen Temalar.dc.html` · `2`
///
/// Geri · 34 px "Ayetler" · arama cam kartı · iki eksen chip'i ·
/// aile başlık kartı + opak kategori listesi.
///
/// **Alt çalar çubuğu yok** — tasarımda da yok (`md/10` iskeleti "en altta
/// cam çalar çubuğu" diyordu, gerçek ekranda bulunmuyor).
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final axis = ref.watch(discoverAxisProvider);
    final async = ref.watch(discoverProvider);
    final media = MediaQuery.of(context);

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
                'Ayetler',
                style: context.type.screenTitle(t.textPrimary),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                KunMetrics.gutterCard,
                12,
                KunMetrics.gutterCard,
                0,
              ),
              child: SearchField(hint: 'Konu ara'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KunMetrics.gutterCard,
                12,
                KunMetrics.gutterCard,
                0,
              ),
              child: Row(
                children: [
                  for (final a in Axis2.values) ...[
                    if (a != Axis2.values.first) const SizedBox(width: 8),
                    Expanded(
                      child: _AxisChip(
                        label: a.label,
                        selected: a == axis,
                        onTap: () =>
                            ref.read(discoverAxisProvider.notifier).select(a),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const KunStateView.error(
                  title: 'Konular yüklenemedi',
                  description:
                      'Konu listesi okunamadı. '
                      'Yeniden denemek sorunu genelde çözer.',
                ),
                data: (result) => result.when(
                  err: (f) => Center(
                    child: KunStateView.fromFailure(
                      f,
                      onRetry: () => ref.invalidate(discoverProvider),
                    ),
                  ),
                  ok: (groups) => _Groups(groups: groups),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AxisChip extends StatelessWidget {
  const _AxisChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: KunMetrics.minTouch),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? t.accent : null,
          border: selected ? null : Border.all(color: t.border, width: 1),
          borderRadius: BorderRadius.circular(t.radiusLg > 8 ? 10 : t.radiusSm),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.type
              .listRow(selected ? t.onAccent : t.textSecondary, size: 15)
              .copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _Groups extends StatelessWidget {
  const _Groups({required this.groups});

  final List<CategoryGroup> groups;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        KunMetrics.gutterCard,
        0,
        KunMetrics.gutterCard,
        KunMetrics.v16,
      ),
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final g = groups[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Aile başlığı — kaydırılan listede olduğu için blur çizilmez.
            GlassSurface(
              radius: t.radiusSm,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: t.accent.withValues(
                            alpha: 1 - (i * 0.15).clamp(0, 0.55),
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          g.family.name,
                          style: context.type
                              .cardTitle(t.textPrimary, size: 17)
                              .copyWith(letterSpacing: 17 * -0.01),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${g.entries.length} kategori',
                        style: context.type.caption(t.textSecondary),
                      ),
                    ],
                  ),
                  if (g.family.description != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 21),
                      child: Text(
                        g.family.description!,
                        style: context.type
                            .caption(t.textSecondary)
                            .copyWith(height: 1.45),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            DividedCard(
              children: [for (final e in g.entries) _CategoryRow(entry: e)],
            ),
          ],
        );
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.entry});

  final CategoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/kategori/${entry.category.id}'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: KunMetrics.minTouch),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.category.name,
                  style: context.type
                      .body(t.textPrimary, size: 16.5)
                      .copyWith(height: 1.3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                // Boş kategori de sayısını gösterir — durum gizlenmez.
                '${entry.verseCount} ayet',
                style: context.type.caption(t.textTertiary, size: 13),
              ),
              const SizedBox(width: 10),
              Icon(KunIcons.chevron, size: 13, color: t.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
