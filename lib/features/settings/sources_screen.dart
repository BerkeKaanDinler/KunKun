import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repository_providers.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../ui/settings_row.dart';

/// Kaynaklar ve lisanslar.
///
/// Lisans şartı: çevirmen adı ve meal sürümü **görünür** olmalı. Ayrıca
/// zorunlu build kontrollerinden biri "lisans kaydı tamlığı" — bu ekran
/// o kaydın kullanıcıya bakan yüzü.
class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final translators = ref.watch(translatorsProvider).value ?? const [];

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
                'Kaynaklar',
                style: context.type.screenTitle(t.textPrimary),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  KunMetrics.gutterCard,
                  KunMetrics.v20,
                  KunMetrics.gutterCard,
                  KunMetrics.v16,
                ),
                children: [
                  SettingsGroup(
                    title: 'Mealler',
                    footnote:
                        'Aşama 1 fixture verisi — gerçek meal ve lisans '
                        'bilgisi tedarik edilmedi.',
                    rows: [
                      for (final tr in translators)
                        SettingsRow(
                          label: tr.name,
                          description:
                              '${tr.workTitle}'
                              '${tr.edition == null ? '' : ' · ${tr.edition}'}'
                              '${tr.licenseNote == null ? '' : ' · ${tr.licenseNote}'}',
                        ),
                    ],
                  ),
                  SettingsGroup(
                    title: 'Arapça metin',
                    rows: const [
                      SettingsRow(
                        label: 'Kaynak belirlenmedi',
                        description:
                            'Arapça metin tedarik edilmedi; '
                            'uygulamada yer tutucu bırakıldı',
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: 'Fontlar',
                    footnote: 'Dördü de SIL Open Font License 1.1.',
                    rows: const [
                      SettingsRow(
                        label: 'Amiri',
                        description: 'Khaled Hosny · Arapça metin',
                      ),
                      SettingsRow(
                        label: 'JetBrains Mono',
                        description: 'JetBrains s.r.o. · künyeler ve sayaçlar',
                      ),
                      SettingsRow(
                        label: 'Libre Franklin',
                        description: 'Impallari Type · Kâğıt indeks gövde',
                      ),
                      SettingsRow(
                        label: 'Spectral',
                        description: 'Production Type · Kâğıt indeks başlık',
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: KunMetrics.v9),
                    child: Text(
                      'Kategori eşleşmeleri editoryaldir, dinî hüküm değildir.',
                      style: context.type
                          .caption(t.textTertiary, size: 11.5)
                          .copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
