import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/theme_controller.dart';
import 'dev/blur_bench_screen.dart';
import 'dev/theme_gallery_screen.dart';
import 'features/category/category_screen.dart';
import 'features/compare/compare_screen.dart';
import 'features/dhikr/dhikr_add_screen.dart';
import 'features/dhikr/dhikr_counter_screen.dart';
import 'features/dhikr/dhikr_list_screen.dart';
import 'features/dhikr/dhikr_stats_screen.dart';
import 'features/dhikr/dhikr_widget_preview.dart';
import 'features/discover/discover_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/intro_screen.dart';
import 'features/onboarding/name_screen.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/saved/saved_screen.dart';
import 'features/settings/settings2_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/sources_screen.dart';
import 'features/widget_preview/widget_preview_screens.dart';
import 'features/sequential/sequential_screen.dart';
import 'features/verse/verse_screen.dart';
import 'ui/metrics.dart';

/// Gezinme · **alt sekme çubuğu yok**; ana sayfa kartlarla dallanır.
/// Bölüm 1'de yalnızca geliştirici ekranları bağlı; Kur'an ve zikir
/// ekranları sonraki bölümlerde eklenir.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Giriş akışı — Bölüm 2
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/tanitim', builder: (_, _) => const IntroScreen(step: 0)),
      GoRoute(
        path: '/tanitim/2',
        builder: (_, _) => const IntroScreen(step: 1),
      ),
      GoRoute(path: '/isim', builder: (_, _) => const NameScreen()),

      // Ana sayfa — Bölüm 3
      GoRoute(path: '/ana', builder: (_, _) => const HomeScreen()),

      // Keşif → Kategori — Bölüm 4
      GoRoute(path: '/kesif', builder: (_, _) => const DiscoverScreen()),
      GoRoute(
        path: '/kategori/:id',
        builder: (_, state) =>
            CategoryScreen(categoryId: state.pathParameters['id']!),
      ),

      GoRoute(
        path: '/ayet/:id',
        builder: (_, state) =>
            VerseScreen(verseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/karsilastir/:id',
        builder: (_, state) =>
            CompareScreen(verseId: state.pathParameters['id']!),
      ),

      // Liste ekranları — Bölüm 5
      GoRoute(
        path: '/tum-ayetler',
        builder: (_, _) => const SequentialScreen(),
      ),
      GoRoute(path: '/kaydedilenler', builder: (_, _) => const SavedScreen()),

      // Ayarlar ve widget önizlemeleri — Bölüm 5
      GoRoute(path: '/ayarlar', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/ayarlar/2', builder: (_, _) => const Settings2Screen()),
      GoRoute(path: '/kaynaklar', builder: (_, _) => const SourcesScreen()),
      GoRoute(
        path: '/widget/kilit',
        builder: (_, _) => const LockWidgetPreviewScreen(),
      ),
      GoRoute(
        path: '/widget/ana-ekran',
        builder: (_, _) => const HomeWidgetPreviewScreen(),
      ),

      // Zikir modülü — Bölüm 6
      GoRoute(path: '/zikir', builder: (_, _) => const DhikrListScreen()),
      GoRoute(
        path: '/zikir/sayac',
        builder: (_, _) => const DhikrCounterScreen(),
      ),
      GoRoute(path: '/zikir/ekle', builder: (_, _) => const DhikrAddScreen()),
      GoRoute(
        path: '/zikir/istatistik',
        builder: (_, _) => const DhikrStatsScreen(),
      ),
      GoRoute(
        path: '/zikir/widget',
        builder: (_, _) => const DhikrWidgetPreviewScreen(),
      ),

      // Geliştirici ekranları — Bölüm 5'te Ayarlar altına taşınacak
      GoRoute(
        path: '/dev/themes',
        builder: (_, _) => const ThemeGalleryScreen(),
      ),
      GoRoute(
        path: '/dev/blur-bench',
        builder: (_, _) => const BlurBenchScreen(),
      ),
    ],
  );
});

class KunApp extends ConsumerWidget {
  const KunApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    final router = ref.watch(routerProvider);

    return KunThemeScope(
      theme: theme,
      child: MaterialApp.router(
        title: 'KUN',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        // Material teması yalnızca metin seçimi / imleç gibi platform
        // davranışları için; bütün görsel değerler token'lardan gelir.
        theme: ThemeData(
          brightness: theme.brightness,
          scaffoldBackgroundColor: theme.tokens.surface,
          colorScheme: ColorScheme.fromSeed(
            seedColor: theme.tokens.accent,
            brightness: theme.brightness,
          ),
        ),
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            // T11 · metin ölçeği 0.85–1.35 arasına clamp'lenir.
            // Sistemde daha yükseği seçilse bile layout dağılmaz.
            data: media.copyWith(
              textScaler: media.textScaler.clamp(
                minScaleFactor: KunMetrics.textScaleMin,
                maxScaleFactor: KunMetrics.textScaleMax,
              ),
            ),
            // WidgetsApp'in varsayılan metin stili (sarı alt çizgi) yerine
            // token tabanlı taban stil. Ekranlar Material Scaffold
            // kullanmadığı için bu tek yerden verilir.
            child: DefaultTextStyle(
              style: theme.typography.body(theme.tokens.textPrimary),
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
