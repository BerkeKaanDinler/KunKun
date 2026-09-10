import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/result.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repositories.dart';
import '../../ui/glass.dart';
import '../../ui/icons.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../ui/states.dart';
import '../../ui/surfaces.dart';
import '../verse/verse_screen.dart';

class ArabicVisible extends Notifier<bool> {
  @override
  bool build() => true;
  void hide() => state = false;
}

final arabicVisibleProvider = NotifierProvider<ArabicVisible, bool>(
  ArabicVisible.new,
);

/// 10 · Karşılaştırma — `Temiz Secilen Temalar.dc.html` · `5`
///
/// Geri · 27 px "Karşılaştırma" · ayet künyesi + "N meal · aynı ayet" ·
/// Arapça kartı (çarpı ile gizlenir) · meal kartları alt alta (seçili olanda
/// aksan kenar + aksan nokta) · dipnot · altta cam varsayılan çubuğu.
///
/// **Arapça kartı yalnızca veri varsa çizilir** — fixture'da Arapça yok,
/// uydurulmaz.
class CompareScreen extends ConsumerWidget {
  const CompareScreen({required this.verseId, super.key});

  final String verseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final async = ref.watch(verseTranslationsProvider(verseId));
    final selected = ref.watch(selectedTranslatorProvider);
    final arabicVisible = ref.watch(arabicVisibleProvider);

    return ColoredBox(
      color: t.surface,
      child: Padding(
        padding: EdgeInsets.only(
          top: media.padding.top > KunMetrics.screenTop
              ? media.padding.top
              : KunMetrics.screenTop,
          bottom: KunMetrics.screenBottomOnboarding + media.padding.bottom,
        ),
        child: switch (async.value) {
          null => const SizedBox.shrink(),
          final Err<List<VerseWithTranslation>> e => Center(
            child: KunStateView.fromFailure(
              e.failure,
              onRetry: () => ref.invalidate(verseTranslationsProvider(verseId)),
            ),
          ),
          final Ok<List<VerseWithTranslation>> ok => _Body(
            items: ok.value,
            selected: selected.clamp(0, ok.value.length - 1),
            arabicVisible: arabicVisible,
          ),
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.items,
    required this.selected,
    required this.arabicVisible,
  });

  final List<VerseWithTranslation> items;
  final int selected;
  final bool arabicVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final verse = items.first.verse;
    final showArabic = arabicVisible && verse.textAr != null;

    return Column(
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
            'Karşılaştırma',
            style: context.type
                .sectionTitle(t.textPrimary)
                .copyWith(letterSpacing: 27 * -0.02),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KunMetrics.gutterCard,
            6,
            KunMetrics.gutterCard,
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  verse.reference,
                  style: context.type
                      .listRow(t.textPrimary, size: 17)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${items.length} meal · aynı ayet',
                style: context.type.caption(t.textSecondary, size: 12),
              ),
            ],
          ),
        ),
        if (showArabic)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KunMetrics.gutterCard,
              11,
              KunMetrics.gutterCard,
              0,
            ),
            child: OpaqueCard(
              sunken: true,
              radius: t.radiusLg,
              padding: const EdgeInsets.fromLTRB(15, 9, 15, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          ref.read(arabicVisibleProvider.notifier).hide(),
                      child: SizedBox(
                        width: KunMetrics.minTouch,
                        height: 26,
                        child: Icon(
                          KunIcons.close,
                          size: 18,
                          color: t.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      verse.textAr!,
                      textAlign: TextAlign.right,
                      style: context.type
                          .arabicText(t.textPrimary, size: 21)
                          .copyWith(height: 1.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              KunMetrics.gutterCard,
              10,
              KunMetrics.gutterCard,
              KunMetrics.v16,
            ),
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 9),
                _MealCard(
                  item: items[i],
                  letter: String.fromCharCode(65 + i),
                  selected: i == selected,
                  onSelect: () =>
                      ref.read(selectedTranslatorProvider.notifier).select(i),
                ),
              ],
              const SizedBox(height: 9),
              Text(
                'Farklar çeviri tercihinden gelir; '
                'künyeler Ayarlar › Kaynaklar altında.',
                style: context.type
                    .caption(t.textTertiary, size: 11)
                    .copyWith(height: 1.55),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: GlassSurface.fixed(
            layer: GlassLayer.base,
            radius: t.radiusMd,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Meal ${String.fromCharCode(65 + selected)} varsayılan',
                    style: context.type
                        .listRow(t.textPrimary, size: 14)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  'Değiştir',
                  style: context.type
                      .caption(t.accent, size: 13.5)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.item,
    required this.letter,
    required this.selected,
    required this.onSelect,
  });

  final VerseWithTranslation item;
  final String letter;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: t.surfaceRaised,
          border: Border.all(color: selected ? t.accent : t.border, width: 1),
          borderRadius: BorderRadius.circular(t.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: selected ? t.accent : t.track,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'MEAL $letter',
                    style: context.type
                        .meta(
                          t.textPrimary,
                          size: 12.5,
                          weight: FontWeight.w700,
                        )
                        .copyWith(letterSpacing: 12.5 * 0.06),
                  ),
                ),
                const SizedBox(width: 9),
                // Lisans şartı — çevirmen künyesi her kartta görünür.
                Flexible(
                  child: Text(
                    item.translator.name,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.caption(t.textTertiary, size: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.translation.text,
              style: context.type
                  .body(t.textPrimary, size: 15)
                  .copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
