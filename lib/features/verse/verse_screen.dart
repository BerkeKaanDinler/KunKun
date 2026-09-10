import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/features.dart';
import '../../core/ports/port_providers.dart';
import '../../core/result.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/models/models.dart';
import '../../ui/atoms.dart';
import '../../ui/glass.dart';
import '../../ui/icons.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../ui/save_button.dart';
import '../../ui/states.dart';
import '../../ui/surfaces.dart';

final verseTranslationsProvider =
    FutureProvider.family<Result<List<VerseWithTranslation>>, String>(
      (ref, id) => ref.watch(verseRepositoryProvider).allTranslations(id),
    );

final verseCategoriesProvider =
    FutureProvider.family<Result<List<Category>>, String>(
      (ref, id) => ref.watch(verseRepositoryProvider).categoriesOfVerse(id),
    );

class SelectedTranslator extends Notifier<int> {
  @override
  int build() => 0;
  void select(int i) => state = i;
}

final selectedTranslatorProvider = NotifierProvider<SelectedTranslator, int>(
  SelectedTranslator.new,
);

class ShowArabic extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final showArabicProvider = NotifierProvider<ShowArabic, bool>(ShowArabic.new);

/// 9 · Ayet odak — `Temiz Secilen Temalar.dc.html` · `4`
///
/// Geri · 27 px künye · meal chip'leri + "Karşılaştır" · 26 px ayet metni ·
/// "Arapçasını göster" · çevirmen künyesi · kategori çipleri ·
/// altta cam eylem çubuğu (blur 24): Sesli oku · Kaydet · Paylaş · Kopyala.
class VerseScreen extends ConsumerWidget {
  const VerseScreen({required this.verseId, super.key});

  final String verseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final async = ref.watch(verseTranslationsProvider(verseId));
    final cats = ref.watch(verseCategoriesProvider(verseId)).value;
    final selected = ref.watch(selectedTranslatorProvider);
    final showArabic = ref.watch(showArabicProvider);

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
            showArabic: showArabic,
            categories: switch (cats) {
              final Ok<List<Category>> c => c.value,
              _ => const [],
            },
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
    required this.showArabic,
    required this.categories,
  });

  final List<VerseWithTranslation> items;
  final int selected;
  final bool showArabic;
  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final current = items[selected];

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
            current.verse.reference,
            style: context.type
                .sectionTitle(t.textPrimary)
                .copyWith(letterSpacing: 27 * -0.02),
          ),
        ),
        Expanded(
          child: ListView(
            // Alt eylem çubuğuna ve başlığa yapışmasın: kaydırılan içerik
            // kelime ortasında kesildiğinde nefes payı kalsın.
            padding: const EdgeInsets.fromLTRB(
              KunMetrics.gutterCard,
              12,
              KunMetrics.gutterCard,
              KunMetrics.v20,
            ),
            children: [
              // Meal seçici + Karşılaştır
              //
              // Chip'ler yatay kaydırılabilir: tasarımda üç meal var ve
              // "Karşılaştır" ile birlikte 402 px'e sığmıyor (taşma ölçüldü).
              // Meal sayısı arttıkça da büyüyecek bir satır bu.
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < items.length; i++) ...[
                            if (i > 0) const SizedBox(width: 6),
                            _TranslatorChip(
                              label: 'Meal ${String.fromCharCode(65 + i)}',
                              selected: i == selected,
                              onTap: () => ref
                                  .read(selectedTranslatorProvider.notifier)
                                  .select(i),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        context.push('/karsilastir/${current.verse.id}'),
                    child: Text(
                      'Karşılaştır',
                      style: context.type
                          .caption(t.accent, size: 13.5)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              OpaqueCard(
                radius: t.radiusLg,
                padding: const EdgeInsets.all(17),
                child: Text(
                  current.translation.text,
                  style: context.type
                      .body(t.textPrimary, size: 26)
                      .copyWith(height: 1.42),
                ),
              ),
              const SizedBox(height: 11),
              // Arapça — veri yoksa satır pasif kalır, metin uydurulmaz.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: current.verse.textAr == null
                    ? null
                    : () => ref.read(showArabicProvider.notifier).toggle(),
                child: Opacity(
                  opacity: current.verse.textAr == null ? 0.45 : 1,
                  child: OpaqueCard(
                    sunken: true,
                    radius: t.radiusLg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Arapçasını göster',
                            style: context.type
                                .listRow(t.textPrimary, size: 14.5)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Icon(
                          showArabic ? KunIcons.close : KunIcons.chevron,
                          size: 18,
                          color: t.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showArabic && current.verse.textAr != null) ...[
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    current.verse.textAr!,
                    textAlign: TextAlign.right,
                    style: context.type.arabicText(t.accent, size: 30),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Lisans şartı: çevirmen adı ve meal sürümü görünür olmalı.
              Text(
                current.translator.credit,
                style: context.type
                    .caption(t.textTertiary, size: 11.5)
                    .copyWith(height: 1.5),
              ),
              const SizedBox(height: 12),
              SectionHeader('Bu ayetin kategorileri'),
              if (categories.isEmpty)
                Text(
                  'Bu ayet henüz bir kategoriye bağlı değil',
                  style: context.type.caption(t.textTertiary),
                )
              else
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final c in categories)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.push('/kategori/${c.id}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: t.surfaceRaised,
                            border: Border.all(color: t.border, width: 1),
                            borderRadius: BorderRadius.circular(
                              t.radiusLg > 8 ? 10 : t.radiusSm,
                            ),
                          ),
                          child: Text(
                            c.name,
                            style: context.type.caption(
                              t.textPrimary,
                              size: 13.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
              Text(
                'Kategori eşleşmeleri editoryaldir, dinî hüküm değildir.',
                style: context.type.caption(t.textTertiary, size: 11.5),
              ),
            ],
          ),
        ),
        // Eylem çubuğu — sabit yüzey, blur 24.
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: GlassSurface.fixed(
            layer: GlassLayer.bar,
            radius: t.radiusLg,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
            child: Row(
              children: [
                // Ü1 · ses kapalıyken çizilir ama pasiftir.
                _Action(
                  icon: KunIcons.play,
                  label: 'Sesli oku',
                  enabled: Features.audio,
                  disabledInfo: 'Ses kaydı henüz eklenmedi',
                ),
                _SaveAction(verseId: current.verse.id),
                _Action(
                  icon: KunIcons.share,
                  label: 'Paylaş',
                  enabled: ref.watch(sharePortProvider).isAvailable,
                  disabledInfo: 'Paylaşım görseli Aşama 3\'te gelecek',
                ),
                _Action(icon: KunIcons.copy, label: 'Kopyala'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TranslatorChip extends StatelessWidget {
  const _TranslatorChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? t.accent : null,
          border: selected ? null : Border.all(color: t.border, width: 1),
          borderRadius: BorderRadius.circular(t.radiusLg > 8 ? 10 : t.radiusSm),
        ),
        child: Text(
          label,
          style: context.type
              .caption(selected ? t.onAccent : t.textSecondary, size: 13.5)
              .copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    this.enabled = true,
    this.disabledInfo,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final String? disabledInfo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled
            ? () {}
            : () => _showInfo(context, disabledInfo ?? 'Henüz kullanılamıyor'),
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: KunMetrics.minTouch),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: t.textSecondary),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: context.type.caption(t.textSecondary, size: 10.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showInfo(BuildContext context, String message) {
    final t = context.tokens;
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 24,
        right: 24,
        bottom: 110,
        child: IgnorePointer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: t.surfaceRaised,
              border: Border.all(color: t.border, width: 1),
              borderRadius: BorderRadius.circular(t.radiusSm),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: context.type.caption(t.textPrimary, size: 13),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future<void>.delayed(const Duration(seconds: 2), entry.remove);
  }
}

/// Alt çubuktaki Kaydet eylemi — [SaveButton] ile aynı durumu paylaşır.
class _SaveAction extends ConsumerWidget {
  const _SaveAction({required this.verseId});

  final String verseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final saved = (ref.watch(savedListProvider).value ?? const []).any(
      (s) => s.verseId == verseId,
    );
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          final repo = ref.read(savedRepositoryProvider);
          if (saved) {
            await repo.remove(verseId);
          } else {
            await repo.save(verseId);
          }
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: KunMetrics.minTouch),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                saved ? KunIcons.bookmark : KunIcons.bookmarkBorder,
                size: 20,
                color: saved ? t.accent : t.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                saved ? 'Kaydedildi' : 'Kaydet',
                style: context.type.caption(
                  saved ? t.accent : t.textSecondary,
                  size: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
