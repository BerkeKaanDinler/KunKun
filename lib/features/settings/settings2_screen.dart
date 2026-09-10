import 'package:flutter/material.dart' show Navigator, showModalBottomSheet;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ports/port_providers.dart';
import '../../core/theme/tokens_ext.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/repositories/repository_providers.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../ui/settings_row.dart';
import '../onboarding/onboarding_controller.dart';

/// 12 · Ayarlar · kayıtlar, kişisel, hakkında —
/// `Temiz Secilen Temalar.dc.html` · `6b`
///
/// **Ü3 çözüldü:** gerçek tasarımda "geçmiş" satırı yok; grup adı
/// KAYDEDİLENLER ve yalnızca dışa/içe aktarma var. `md/10` iskeletinin
/// "KAYITLAR (kaydedilenler, geçmiş, dışa aktar)" satırı tasarımda yok.
///
/// Dışa/içe aktarma Aşama 3 — satırlar çizilir ama pasiftir.
class Settings2Screen extends ConsumerWidget {
  const Settings2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final saved = ref.watch(savedListProvider).value ?? const [];
    final name = ref.watch(onboardingProvider).name;
    final shareAvailable = ref.watch(sharePortProvider).isAvailable;

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
                'Ayarlar',
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
                    title: 'Kaydedilenler',
                    footnote: 'Dışa ve içe aktarma Aşama 3\'te gelecek.',
                    rows: [
                      SettingsRow(
                        label: 'Dışa aktar',
                        description: '${saved.length} ayet kayıtlı',
                        enabled: shareAvailable,
                        onTap: () {},
                      ),
                      SettingsRow(
                        label: 'İçe aktar',
                        description:
                            'Birleştir ya da üzerine yaz — '
                            'dosya seçildikten sonra sorulur',
                        enabled: shareAvailable,
                        onTap: () {},
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: 'Kişisel',
                    rows: [
                      SettingsRow(
                        label: 'İsim',
                        description: name ?? 'Belirtilmedi',
                        onTap: () => context.push('/isim'),
                      ),
                      SettingsRow(
                        label: 'Verileri temizle',
                        description: 'Önce dışa aktarman önerilir',
                        danger: true,
                        onTap: () => _confirmWipe(context, ref),
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: 'Hakkında',
                    rows: [
                      SettingsRow(
                        label: 'Kaynaklar ve lisanslar',
                        description:
                            'Çevirmenler, meal sürümleri, '
                            'Arapça metnin kaynağı',
                        onTap: () => context.push('/kaynaklar'),
                      ),
                      const SettingsRow(
                        label: 'Uygulama hakkında',
                        description: 'Sürüm 0.1 · Aşama 1 · fixture verisi',
                      ),
                      const SettingsRow(
                        label: 'Geri bildirim gönder',
                        description: 'İçerik hatası bildirmek için',
                        enabled: false,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: KunMetrics.v9),
                    child: Text(
                      'Analytics ve çökme raporlama yok. Dinî metin, arama '
                      'sorgusu ve zikir içeriği hiçbir koşulda loglanmaz.',
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

  static void _confirmWipe(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KunMetrics.gutterCard),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verileri temizle',
                style: context.type.sectionTitle(t.textPrimary),
              ),
              const SizedBox(height: KunMetrics.v9),
              Text(
                'Kaydedilen ayetler, isim ve tercihler silinir. '
                'Bu işlem geri alınamaz.',
                style: context.type.body(t.textSecondary),
              ),
              const SizedBox(height: KunMetrics.v20),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final store = ref.read(jsonStoreProvider);
                  for (final k in ['saved_verses', 'user_name']) {
                    await store.write(k, null);
                  }
                  ref.read(onboardingProvider.notifier).reset();
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                },
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: KunMetrics.primaryButtonHeight,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.danger,
                    borderRadius: BorderRadius.circular(t.radiusSm),
                  ),
                  child: Text(
                    'Sil',
                    style: context.type.cardTitle(
                      const Color(0xFFFFFFFF),
                      size: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
