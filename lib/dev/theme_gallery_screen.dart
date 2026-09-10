import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/kun_theme.dart';
import '../core/theme/theme_controller.dart';
import '../core/theme/themes/themes.dart';
import '../core/theme/tokens_ext.dart';
import '../ui/atoms.dart';
import '../ui/buttons.dart';
import '../ui/glass.dart';
import '../ui/icons.dart';
import '../ui/metrics.dart';
import '../ui/screen_scaffold.dart';
import '../ui/states.dart';
import '../ui/surfaces.dart';

/// Bölüm 1 teslim ekranı — 6 tema, 18 token ve bütün temel bileşenler.
/// Ayarlar ekranı geldiğinde tema değiştirici oraya taşınır.
class ThemeGalleryScreen extends ConsumerWidget {
  const ThemeGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final theme = context.kunTheme;
    final glass = ref.watch(glassPolicyProvider);

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KunMetrics.gutterText,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tema', style: context.type.screenTitle(t.textPrimary)),
                const SizedBox(height: KunMetrics.v9),
                Text(
                  '${theme.label} · ${theme.isDark ? 'koyu' : 'açık'} · '
                  'blur ${t.glassBlur.toStringAsFixed(0)}',
                  style: context.type.caption(t.textSecondary, size: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: KunMetrics.v20),

          // --- tema seçici
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KunMetrics.gutterCard,
            ),
            child: DividedCard(
              children: [
                for (final id in KunThemeId.values)
                  KunListRow(
                    title: Text(
                      id.label,
                      style: context.type.listRow(t.textPrimary),
                    ),
                    subtitle: Text(
                      kunThemeOf(id).tokens.glassBlur == 0
                          ? 'opak · blur yok'
                          : 'cam · blur 20',
                      style: context.type.caption(t.textSecondary),
                    ),
                    trailing: id == theme.id
                        ? Icon(KunIcons.check, size: 20, color: t.accent)
                        : const SizedBox(width: 20),
                    onTap: () =>
                        ref.read(themeControllerProvider.notifier).select(id),
                  ),
              ],
            ),
          ),
          const SizedBox(height: KunMetrics.v20),

          _Section('Yüzeyler'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KunMetrics.gutterCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassSurface.fixed(
                  radius: t.radiusLg,
                  padding: const EdgeInsets.all(KunMetrics.v16),
                  child: Text(
                    'GlassSurface.fixed — sabit yüzey, blur çizilir',
                    style: context.type.body(t.textPrimary),
                  ),
                ),
                const SizedBox(height: KunMetrics.v12),
                GlassSurface(
                  padding: const EdgeInsets.all(KunMetrics.v16),
                  child: Text(
                    'GlassSurface — liste kartı, yarı saydam düz renk, blur yok',
                    style: context.type.body(t.textPrimary),
                  ),
                ),
                const SizedBox(height: KunMetrics.v12),
                OpaqueCard(
                  padding: const EdgeInsets.all(KunMetrics.v16),
                  child: Text(
                    'OpaqueCard',
                    style: context.type.body(t.textPrimary),
                  ),
                ),
                const SizedBox(height: KunMetrics.v12),
                Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: t.heroSurface,
                    borderRadius: BorderRadius.circular(
                      t.radiusLg > 8 ? 26 : 4,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'hero-surface',
                    style: context.type.meta(const Color(0xFFFFFFFF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KunMetrics.v20),

          _Section('Tipografi'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KunMetrics.gutterText,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ekran başlığı 34',
                  style: context.type.screenTitle(t.textPrimary),
                ),
                Text(
                  'Bölüm başlığı 27',
                  style: context.type.sectionTitle(t.textPrimary),
                ),
                Text(
                  'Kart başlığı 19',
                  style: context.type.cardTitle(t.textPrimary),
                ),
                Text(
                  'Liste satırı 16.5',
                  style: context.type.listRow(t.textPrimary),
                ),
                Text(
                  'Gövde 15 · line-height 1.5',
                  style: context.type.body(t.textPrimary),
                ),
                Text(
                  'Alt metin 12.5',
                  style: context.type.caption(t.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'KÜNYE · JETBRAINS MONO',
                  style: context.type.meta(t.textTertiary),
                ),
                const SizedBox(height: 4),
                Text('4.312', style: context.type.counter(t.textPrimary)),
                const SizedBox(height: 4),
                // Arapça: yalnızca tasarım dökümünden gelen gerçek metin.
                // Uydurma Arapça üretilmez.
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    'سُبْحَانَ اللّٰهِ',
                    style: context.type.arabicText(t.accent, size: 30),
                  ),
                ),
                Text(
                  'Amiri · md/11-zikir-ekranlari.md kaynaklı',
                  style: context.type.meta(t.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: KunMetrics.v20),

          _Section('Bileşenler'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KunMetrics.gutterCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PrimaryButton(label: 'Birincil buton', onPressed: _noop),
                const SizedBox(height: KunMetrics.v12),
                const SecondaryButton(label: 'İkincil buton', onPressed: _noop),
                const SizedBox(height: KunMetrics.v14),
                Row(
                  children: [
                    const KunBadge('HEDEF 33'),
                    const SizedBox(width: 8),
                    const KunBadge.soft('12'),
                    const SizedBox(width: 8),
                    const KunBadge('∞', accented: true),
                    const Spacer(),
                    _SwitchDemo(),
                  ],
                ),
                const SizedBox(height: KunMetrics.v14),
                const _TabsDemo(),
                const SizedBox(height: KunMetrics.v14),
                const _ChipsDemo(),
              ],
            ),
          ),
          const SizedBox(height: KunMetrics.v20),

          _Section('Boş ve hata durumu'),
          KunStateView.empty(
            title: KunStateCopy.saved.title,
            description: KunStateCopy.saved.body,
            actionLabel: KunStateCopy.saved.action,
            onAction: _noop,
          ),
          const SizedBox(height: KunMetrics.v12),
          KunStateView.error(
            title: KunStateCopy.sequentialError.title,
            description: KunStateCopy.sequentialError.body,
            onAction: _noop,
          ),
          const SizedBox(height: KunMetrics.v20),

          _Section('Performans'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KunMetrics.gutterCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OpaqueCard(
                  padding: const EdgeInsets.all(KunMetrics.v16),
                  child: Text(
                    'Cam politikası: ${glass.name}',
                    style: context.type.body(t.textPrimary),
                  ),
                ),
                const SizedBox(height: KunMetrics.v12),
                SecondaryButton(
                  label: 'Blur bench · 40 kart',
                  onPressed: () => context.push('/dev/blur-bench'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

class _Section extends StatelessWidget {
  const _Section(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      KunMetrics.gutterText,
      0,
      KunMetrics.gutterText,
      KunMetrics.v9,
    ),
    child: SectionHeader(label),
  );
}

class _SwitchDemo extends StatefulWidget {
  @override
  State<_SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<_SwitchDemo> {
  bool _v = true;

  @override
  Widget build(BuildContext context) =>
      KunSwitch(value: _v, onChanged: (v) => setState(() => _v = v));
}

class _TabsDemo extends StatefulWidget {
  const _TabsDemo();

  @override
  State<_TabsDemo> createState() => _TabsDemoState();
}

class _TabsDemoState extends State<_TabsDemo> {
  int _i = 0;

  @override
  Widget build(BuildContext context) => KunTabs(
    labels: const ['Hazır zikirler', 'Serbest'],
    index: _i,
    onChanged: (i) => setState(() => _i = i),
  );
}

class _ChipsDemo extends StatefulWidget {
  const _ChipsDemo();

  @override
  State<_ChipsDemo> createState() => _ChipsDemoState();
}

class _ChipsDemoState extends State<_ChipsDemo> {
  int _i = 0;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    // T8 · iki chip, eksen seçici; açılışta Hayattan seçili.
    // Tasarım "iki öğeyle taşma olmaz" diyor ama %135 metin ölçeğinde
    // 402 px genişlikte taşıyor — dökümün izin verdiği yatay kaydırma
    // bu yüzden zorunlu, isteğe bağlı değil.
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        KunChip(
          label: 'Hayattan',
          selected: _i == 0,
          onTap: () => setState(() => _i = 0),
        ),
        const SizedBox(width: 8),
        KunChip(
          label: "Kur'an'dan",
          selected: _i == 1,
          onTap: () => setState(() => _i = 1),
        ),
      ],
    ),
  );
}
