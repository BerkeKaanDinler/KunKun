import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/models/models.dart';
import '../../ui/feature_gate.dart';
import '../../ui/icons.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../ui/states.dart';
import '../../ui/surfaces.dart';

class SavedTab extends Notifier<int> {
  @override
  int build() => 0;
  void select(int i) => state = i;
}

final savedTabProvider = NotifierProvider<SavedTab, int>(SavedTab.new);

/// Kaydedilen kategoriler, adlarıyla çözülmüş.
final savedCategoryDetailProvider = FutureProvider<List<(String, String)>>((
  ref,
) async {
  final ids = ref.watch(savedCategoriesProvider).value ?? const <String>[];
  final repo = ref.watch(categoryRepositoryProvider);
  final out = <(String, String)>[];
  for (final id in ids) {
    final c = (await repo.categoryById(id)).valueOrNull;
    if (c != null) out.add((id, c.name));
  }
  return out;
});

/// Kaydedilen ayetlerin metniyle birlikte çözülmüş hâli.
final savedDetailProvider =
    FutureProvider<List<(SavedVerse, VerseWithTranslation)>>((ref) async {
      final saved = ref.watch(savedListProvider).value ?? const <SavedVerse>[];
      final repo = ref.watch(verseRepositoryProvider);
      final out = <(SavedVerse, VerseWithTranslation)>[];
      for (final s in saved) {
        final v = (await repo.verseById(s.verseId)).valueOrNull;
        if (v != null) out.add((s, v));
      }
      return out;
    });

/// 13 · Kaydedilenler — `Temiz Secilen Temalar.dc.html` · `7`
///
/// Geri · 34 px başlık · sekmeler · arama · opak kart içinde kayıt satırları ·
/// dipnot. Sağa kaydırarak silme.
///
/// **Çelişki (Ü2):** tasarımın ikinci sekmesi "Konular", `md/10` iskeleti ise
/// "Notlar" diyor. Brief `notes = false` ile tek sekme bırakılmasını istiyor;
/// "Konular" için şemada karşılık yok (`saved_verses` var, kayıtlı kategori
/// yok). Şimdilik tek sekme — sekme çubuğu gizli.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final items = ref.watch(savedDetailProvider).value ?? const [];
    final categories = ref.watch(savedCategoryDetailProvider).value ?? const [];
    final tab = ref.watch(savedTabProvider);

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
                'Kaydedilenler',
                style: context.type.screenTitle(t.textPrimary),
              ),
            ),
            // Tek sekme kalırsa çubuk çizilmez (FeatureGate.savedTabs).
            if (FeatureGate.savedTabs.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KunMetrics.gutterCard,
                  10,
                  KunMetrics.gutterCard,
                  0,
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < FeatureGate.savedTabs.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _Tab(
                          label: FeatureGate.savedTabs[i],
                          count: i == 0 ? items.length : categories.length,
                          selected: i == tab,
                          onTap: () =>
                              ref.read(savedTabProvider.notifier).select(i),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                KunMetrics.gutterCard,
                12,
                KunMetrics.gutterCard,
                0,
              ),
              child: SearchField(hint: 'Kayıtlarda ara'),
            ),
            Expanded(
              child: tab == 1
                  ? _CategoriesTab(categories: categories)
                  : items.isEmpty
                  ? Center(
                      child: KunStateView.empty(
                        title: KunStateCopy.saved.title,
                        description: KunStateCopy.saved.body,
                        actionLabel: KunStateCopy.saved.action,
                        onAction: () => context.push('/kesif'),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        KunMetrics.gutterCard,
                        12,
                        KunMetrics.gutterCard,
                        0,
                      ),
                      children: [
                        DividedCard(
                          children: [
                            for (final (saved, verse) in items)
                              _SavedRow(
                                key: ValueKey(saved.verseId),
                                saved: saved,
                                verse: verse,
                                onRemove: () => ref
                                    .read(savedRepositoryProvider)
                                    .remove(saved.verseId),
                                onOpen: () =>
                                    context.push('/ayet/${saved.verseId}'),
                              ),
                          ],
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KunMetrics.gutterText,
                10,
                KunMetrics.gutterText,
                12,
              ),
              child: Text(
                'Kayıtlar cihazda tutulur · dışa aktarılabilir',
                style: context.type
                    .caption(t.textTertiary, size: 11)
                    .copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedRow extends ConsumerWidget {
  const _SavedRow({
    required this.saved,
    required this.verse,
    required this.onRemove,
    required this.onOpen,
    super.key,
  });

  final SavedVerse saved;
  final VerseWithTranslation verse;
  final VoidCallback onRemove;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final catId = saved.sourceCategoryId;

    return Dismissible(
      key: ValueKey('dismiss-${saved.verseId}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
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
        onTap: onOpen,
        child: Container(
          color: t.surfaceRaised,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    verse.verse.reference.toUpperCase(),
                    style: context.type
                        .meta(t.accent, size: 11.5, weight: FontWeight.w700)
                        .copyWith(letterSpacing: 11.5 * 0.05),
                  ),
                  const Spacer(),
                  if (catId != null) _CategoryPill(categoryId: catId),
                  const SizedBox(width: 8),
                  Icon(KunIcons.chevron, size: 14, color: t.textTertiary),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                verse.translation.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.type
                    .body(t.textPrimary, size: 16)
                    .copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends ConsumerWidget {
  const _CategoryPill({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final cat = ref.watch(categoryNameProvider(categoryId)).value;
    if (cat == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: t.accentSoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(cat, style: context.type.caption(t.accent, size: 11)),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
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
          '$label · $count',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.type
              .listRow(selected ? t.onAccent : t.textSecondary, size: 14.5)
              .copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab({required this.categories});

  final List<(String, String)> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    if (categories.isEmpty) {
      return Center(
        child: KunStateView.empty(
          title: 'Kaydedilmiş konu yok',
          description:
              'Bir kategoriyi açıp sağ üstteki işareti kullan; buraya düşer.',
          actionLabel: 'Konulara git',
          onAction: () => context.push('/kesif'),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KunMetrics.gutterCard,
        12,
        KunMetrics.gutterCard,
        0,
      ),
      children: [
        DividedCard(
          children: [
            for (final (id, name) in categories)
              KunListRow(
                key: ValueKey('cat-$id'),
                title: Text(name, style: context.type.listRow(t.textPrimary)),
                subtitle: Text(id, style: context.type.meta(t.textTertiary)),
                trailing: Icon(
                  KunIcons.chevron,
                  size: 14,
                  color: t.textTertiary,
                ),
                onTap: () => context.push('/kategori/$id'),
              ),
          ],
        ),
      ],
    );
  }
}
