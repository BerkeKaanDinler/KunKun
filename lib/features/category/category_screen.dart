import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/features.dart';
import '../../core/result.dart';
import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/models/models.dart';
import '../../ui/icons.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../ui/save_button.dart';
import '../../ui/states.dart';
import '../../ui/surfaces.dart';

final categoryProvider = FutureProvider.family<Result<Category>, String>(
  (ref, id) => ref.watch(categoryRepositoryProvider).categoryById(id),
);

final categoryVersesProvider =
    FutureProvider.family<Result<List<VerseWithTranslation>>, String>(
      (ref, id) => ref.watch(verseRepositoryProvider).versesInCategory(id),
    );

/// 8 · Kategori — `Temiz Secilen Temalar.dc.html` · `3`
///
/// Geri · 27 px kategori adı · "N ayet" hapı + süre · açıklama ·
/// ayet kartları (künye aksan, oynat + kaydet) · altta cam çalar çubuğu.
///
/// **Ü1/T7:** `audio == false` iken alt çalar çubuğu **hiç çizilmez**,
/// "sırayla dinle · N dk" satırı da düşer. Ayet kartındaki oynat ikonu da
/// çizilmez — kart yalnızca kaydet ikonu taşır.
class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final cat = ref.watch(categoryProvider(categoryId)).value;
    final versesAsync = ref.watch(categoryVersesProvider(categoryId));

    final name = switch (cat) {
      final Ok<Category> ok => ok.value.name,
      _ => '',
    };
    final description = switch (cat) {
      final Ok<Category> ok => ok.value.description,
      _ => null,
    };

    return ColoredBox(
      color: t.surface,
      child: Padding(
        padding: EdgeInsets.only(
          top: media.padding.top > KunMetrics.screenTop
              ? media.padding.top
              : KunMetrics.screenTop,
          bottom: KunMetrics.screenBottomOnboarding + media.padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackRow(
              onBack: () => context.pop(),
              trailing: _SaveCategoryButton(categoryId: categoryId),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KunMetrics.gutterText,
                4,
                KunMetrics.gutterText,
                0,
              ),
              child: Text(
                name,
                style: context.type
                    .sectionTitle(t.textPrimary)
                    .copyWith(letterSpacing: 27 * -0.02),
              ),
            ),
            // Tasarımda başlığın altında kategori açıklaması var;
            // fixture'da boş olduğu için veri gelene kadar çizilmez.
            if (description != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KunMetrics.gutterCard,
                  10,
                  KunMetrics.gutterCard,
                  0,
                ),
                child: Text(
                  description,
                  style: context.type
                      .body(t.textSecondary, size: 14)
                      .copyWith(height: 1.55),
                ),
              ),
            Expanded(
              child: switch (versesAsync.value) {
                null => const SizedBox.shrink(),
                final Err<List<VerseWithTranslation>> e => Center(
                  child: KunStateView.fromFailure(
                    e.failure,
                    onRetry: () =>
                        ref.invalidate(categoryVersesProvider(categoryId)),
                  ),
                ),
                final Ok<List<VerseWithTranslation>> ok =>
                  ok.value.isEmpty
                      ? Center(
                          child: KunStateView.empty(
                            title: KunStateCopy.category.title,
                            description: KunStateCopy.category.body,
                            actionLabel: KunStateCopy.category.action,
                            onAction: () => context.pop(),
                          ),
                        )
                      : _VerseList(verses: ok.value, categoryId: categoryId),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VerseList extends StatelessWidget {
  const _VerseList({required this.verses, required this.categoryId});

  final List<VerseWithTranslation> verses;
  final String categoryId;

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
      // Başlık üstü meta satırı listeyle birlikte kayar.
      itemCount: verses.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 1),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: t.accentSoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${verses.length} ayet',
                    style: context.type
                        .caption(t.accent, size: 12.5)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                // Ü1 · ses kapalıyken süre bilgisi de düşer.
                if (Features.audio) ...[
                  const SizedBox(width: 9),
                  Text(
                    'sırayla dinle',
                    style: context.type.caption(t.textSecondary, size: 13),
                  ),
                ],
              ],
            ),
          );
        }
        final v = verses[i - 1];
        return Padding(
          padding: const EdgeInsets.only(top: 9),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/ayet/${v.verse.id}'),
            child: OpaqueCard(
              radius: t.radiusLg,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          v.verse.reference.toUpperCase(),
                          style: context.type
                              .meta(t.accent, size: 12, weight: FontWeight.w700)
                              .copyWith(letterSpacing: 12 * 0.05),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (Features.audio) ...[
                        Icon(KunIcons.play, size: 18, color: t.accent),
                        const SizedBox(width: 14),
                      ],
                      SaveButton(
                        verseId: v.verse.id,
                        sourceCategoryId: categoryId,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    v.translation.text,
                    style: context.type
                        .body(t.textPrimary, size: 16.5)
                        .copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Kategoriyi kaydet — Kaydedilenler'in "Konular" sekmesini besler.
/// Yalnızca kategori kimliği tutulur, ad kopyalanmaz.
class _SaveCategoryButton extends ConsumerWidget {
  const _SaveCategoryButton({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final saved = (ref.watch(savedCategoriesProvider).value ?? const [])
        .contains(categoryId);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final repo = ref.read(savedRepositoryProvider);
        if (saved) {
          repo.removeCategory(categoryId);
        } else {
          repo.saveCategory(categoryId);
        }
      },
      child: SizedBox(
        width: KunMetrics.minTouch,
        height: KunMetrics.minTouch,
        child: Icon(
          saved ? KunIcons.bookmark : KunIcons.bookmarkBorder,
          size: 20,
          color: saved ? t.accent : t.textSecondary,
        ),
      ),
    );
  }
}
