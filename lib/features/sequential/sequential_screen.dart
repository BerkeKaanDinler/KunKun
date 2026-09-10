import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/features.dart';
import '../../core/result.dart';
import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/repository_providers.dart';
import '../../ui/icons.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../ui/states.dart';
import '../../ui/surfaces.dart';

final surahsProvider = FutureProvider<Result<List<SurahGroup>>>(
  (ref) => ref.watch(verseRepositoryProvider).surahs(),
);

/// Açık sûre — tasarımda ilk sûre açık gelir.
class ExpandedSurah extends Notifier<int?> {
  @override
  int? build() => 1;

  void toggle(int number) => state = state == number ? null : number;
}

final expandedSurahProvider = NotifierProvider<ExpandedSurah, int?>(
  ExpandedSurah.new,
);

/// 6 · Tüm ayetler · sırayla — `Temiz Secilen Temalar.dc.html` · `6c`
///
/// Düz ayet listesi **değil**: sûre listesi, ilk sûre açık. Sûre kartında
/// numara rozeti, ad, "N ayet · Mekke", Arapça ad; açık sûrede ayet satırları.
///
/// **Ü1:** sağ üstteki 38 px oynat düğmesi ve alt çalar çubuğu çizilmez.
/// **Ü8:** arama placeholder'ı nötrleştirildi.
class SequentialScreen extends ConsumerWidget {
  const SequentialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final async = ref.watch(surahsProvider);
    final expanded = ref.watch(expandedSurahProvider);

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
              // Ü1 · baştan sesli okuma düğmesi ses kapalıyken çizilmez.
              trailing: Features.audio
                  ? Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: t.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(KunIcons.play, size: 16, color: t.onAccent),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KunMetrics.gutterText,
                4,
                KunMetrics.gutterText,
                0,
              ),
              child: Text(
                'Tüm ayetler',
                style: context.type.screenTitle(t.textPrimary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KunMetrics.gutterText,
                8,
                KunMetrics.gutterText,
                0,
              ),
              child: Text(
                Features.audio
                    ? 'Fâtiha\'dan Nâs\'a, sırayla. Sağ üstteki düğme birinci '
                          'ayetten itibaren sesli okur.'
                    : 'Fâtiha\'dan Nâs\'a, sırayla.',
                style: context.type
                    .caption(t.textSecondary, size: 13)
                    .copyWith(height: 1.5),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                KunMetrics.gutterCard,
                14,
                KunMetrics.gutterCard,
                0,
              ),
              child: SearchField(hint: 'Sûre veya ayet ara'),
            ),
            Expanded(
              child: switch (async.value) {
                null => const SizedBox.shrink(),
                Err<List<SurahGroup>>() => Center(
                  child: KunStateView.error(
                    title: KunStateCopy.sequentialError.title,
                    description: KunStateCopy.sequentialError.body,
                    onAction: () => ref.invalidate(surahsProvider),
                  ),
                ),
                final Ok<List<SurahGroup>> ok => ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    KunMetrics.gutterCard,
                    14,
                    KunMetrics.gutterCard,
                    KunMetrics.v16,
                  ),
                  itemCount: ok.value.length,
                  itemBuilder: (context, i) => Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 9),
                    child: _SurahCard(
                      group: ok.value[i],
                      expanded: ok.value[i].number == expanded,
                      onToggle: () => ref
                          .read(expandedSurahProvider.notifier)
                          .toggle(ok.value[i].number),
                    ),
                  ),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  const _SurahCard({
    required this.group,
    required this.expanded,
    required this.onToggle,
  });

  final SurahGroup group;
  final bool expanded;
  final VoidCallback onToggle;

  static const int _previewCount = 4;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final shown = expanded
        ? group.verses.take(_previewCount).toList()
        : const <VerseWithTranslation>[];
    final remaining = group.verses.length - shown.length;

    return OpaqueCard(
      radius: t.radiusLg > 8 ? 16 : t.radiusMd,
      padding: EdgeInsets.fromLTRB(15, 14, 15, expanded ? 4 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.only(bottom: expanded ? 12 : 0),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: expanded ? t.accent : t.glassFill,
                      borderRadius: BorderRadius.circular(
                        t.radiusLg > 8 ? 10 : 3,
                      ),
                    ),
                    child: Text(
                      '${group.number}',
                      style: context.type
                          .meta(
                            expanded ? t.onAccent : t.accent,
                            size: 13,
                            weight: FontWeight.w700,
                          )
                          .copyWith(letterSpacing: 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          group.name,
                          style: context.type.cardTitle(
                            t.textPrimary,
                            size: expanded ? 17 : 16.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // Nüzul yeri fixture'da yok; sayı gerçek.
                          group.revelation == null
                              ? '${group.verses.length} ayet'
                              : '${group.verses.length} ayet · ${group.revelation}',
                          style: context.type.caption(
                            t.textTertiary,
                            size: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arapça sûre adı — veri yoksa hiç çizilmez, uydurulmaz.
                  if (group.nameAr != null) ...[
                    const SizedBox(width: 12),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        group.nameAr!,
                        style: context.type.arabicText(
                          expanded ? t.accent : t.textSecondary,
                          size: expanded ? 18 : 17,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  Icon(
                    expanded ? KunIcons.close : KunIcons.chevron,
                    size: 16,
                    color: t.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          for (var i = 0; i < shown.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(top: BorderSide(color: t.border, width: 1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.glassFill,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${shown[i].verse.ayahNumber}',
                      style: context.type
                          .meta(t.accent, size: 11.5, weight: FontWeight.w600)
                          .copyWith(letterSpacing: 0),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      shown[i].translation.text,
                      style: context.type
                          .body(t.textPrimary, size: 15)
                          .copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          if (expanded && remaining > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: t.divider, width: 1)),
              ),
              child: Row(
                children: [
                  Opacity(
                    opacity: 0.72,
                    child: Text(
                      'Kalan $remaining ayeti göster',
                      style: context.type
                          .listRow(t.textPrimary, size: 13.5)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Icon(KunIcons.chevron, size: 14, color: t.textSecondary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
