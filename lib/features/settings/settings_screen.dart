import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/features.dart';
import '../../core/theme/kun_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/themes/themes.dart';
import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repository_providers.dart';
import '../../ui/feature_gate.dart';
import '../../ui/metrics.dart';
import '../../ui/nav_bar.dart';
import '../../ui/settings_row.dart';
import '../../ui/surfaces.dart';
import '../onboarding/onboarding_controller.dart';

/// Kullanıcı tercihleri — Ü15 · JSON snapshot.
class ReadingPrefs extends Notifier<({bool showArabic, String textSize})> {
  static const String _arabicKey = 'pref_show_arabic';
  static const String _sizeKey = 'pref_text_size';

  @override
  ({bool showArabic, String textSize}) build() {
    final s = ref.read(jsonStoreProvider);
    return (
      showArabic: s.read<bool>(_arabicKey) ?? true,
      textSize: s.read<String>(_sizeKey) ?? 'Normal',
    );
  }

  void setShowArabic(bool v) {
    ref.read(jsonStoreProvider).write(_arabicKey, v);
    state = (showArabic: v, textSize: state.textSize);
  }
}

final readingPrefsProvider =
    NotifierProvider<ReadingPrefs, ({bool showArabic, String textSize})>(
      ReadingPrefs.new,
    );

/// 11 · Ayarlar · okuma, ses, widget — `Temiz Secilen Temalar.dc.html` · `6`
///
/// **Ü1:** `audio == false` iken SES grubu **gizlenir**, boş grup bırakılmaz.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final prefs = ref.watch(readingPrefsProvider);
    final theme = ref.watch(themeControllerProvider);
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
                    title: 'Okuma',
                    rows: [
                      SettingsRow(
                        label: 'Ana meal',
                        description: translators.isEmpty
                            ? 'Veri bekleniyor'
                            : translators.first.name,
                        onTap: () {},
                      ),
                      SettingsRow(
                        label: 'Arapça metni göster',
                        description: 'Arapça metin mealin altında görünür',
                        switchValue: prefs.showArabic,
                        onSwitch: (v) => ref
                            .read(readingPrefsProvider.notifier)
                            .setShowArabic(v),
                      ),
                      SettingsRow(
                        label: 'Metin boyutu',
                        description: 'Küçük · Normal · Büyük · Çok büyük',
                        value: prefs.textSize,
                        onTap: () {},
                      ),
                      // Tasarımda bu satır "Açık · Koyu · Sistem" diyor;
                      // brief altı temanın değiştiricisini istiyor. Satır
                      // altı temanın seçicisini açıyor.
                      SettingsRow(
                        label: 'Tema',
                        description: '6 tema · ${theme.label}',
                        value: theme.isDark ? 'Koyu' : 'Açık',
                        onTap: () => _openThemePicker(context, ref),
                      ),
                    ],
                  ),
                  // Ü1 · ses kapalıyken bu grup hiç çizilmez.
                  if (FeatureGate.showAudioSettings)
                    SettingsGroup(
                      title: 'Ses',
                      footnote:
                          'Ses mekanizması kesinleşmedi; '
                          'netleşince ses seçimi bu gruba eklenir.',
                      rows: [
                        SettingsRow(
                          label: 'Okuma hızı',
                          description: 'Varsayılan 1×',
                          value: '1×',
                          onTap: () {},
                        ),
                      ],
                    ),
                  SettingsGroup(
                    title: 'Widget',
                    rows: [
                      SettingsRow(
                        label: 'Ana ekran widget\'ı',
                        description:
                            'Günün ayetini ana ekranında göster · ÖNİZLEME',
                        onTap: () => context.push('/widget/ana-ekran'),
                      ),
                      SettingsRow(
                        label: 'Kilit ekranı widget\'ı',
                        description: 'Native iş Aşama 3\'te · ÖNİZLEME',
                        onTap: () => context.push('/widget/kilit'),
                      ),
                    ],
                  ),
                  // Tasarımda Ayarlar iki sayfa; ikinciye geçiş satırı
                  // kendi grubunda durur, boşlukta asılı kalmaz.
                  SettingsGroup(
                    title: 'Diğer',
                    rows: [
                      SettingsRow(
                        label: 'Kayıtlar, kişisel, hakkında',
                        description: 'Dışa aktar · isim · kaynaklar',
                        onTap: () => context.push('/ayarlar/2'),
                      ),
                    ],
                  ),
                  if (Features.devTools) ...[
                    const SizedBox(height: KunMetrics.v20),
                    SettingsGroup(
                      title: 'Geliştirici',
                      footnote: 'Yayın derlemesinde bu bölüm görünmez.',
                      rows: [
                        SettingsRow(
                          label: 'Hata modunu zorla',
                          description:
                              'Repository\'ler hata döner — '
                              'her ekranın hata durumu gezilebilir',
                          switchValue: ref.watch(forceErrorProvider),
                          onSwitch: (v) =>
                              ref.read(forceErrorProvider.notifier).set(v),
                        ),
                        SettingsRow(
                          label: 'Tema galerisi',
                          onTap: () => context.push('/dev/themes'),
                        ),
                        SettingsRow(
                          label: 'Blur bench · 40 kart',
                          onTap: () => context.push('/dev/blur-bench'),
                        ),
                        SettingsRow(
                          label: 'Giriş akışını sıfırla',
                          onTap: () {
                            ref.read(onboardingProvider.notifier).reset();
                            context.go('/');
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openThemePicker(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KunMetrics.gutterCard),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: KunMetrics.v12),
                child: Text(
                  'Tema',
                  style: context.type.sectionTitle(t.textPrimary),
                ),
              ),
              DividedCard(
                children: [
                  for (final id in KunThemeId.values)
                    Consumer(
                      builder: (context, ref, _) => SettingsRow(
                        label: id.label,
                        description: kunThemeOf(id).tokens.glassBlur == 0
                            ? 'opak · blur yok'
                            : 'cam · blur 20',
                        value: ref.watch(themeControllerProvider).id == id
                            ? 'Seçili'
                            : null,
                        onTap: () {
                          ref.read(themeControllerProvider.notifier).select(id);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
