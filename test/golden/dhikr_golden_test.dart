import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kun/core/theme/kun_theme.dart';
import 'package:kun/core/theme/theme_controller.dart';
import 'package:kun/core/theme/themes/themes.dart';
import 'package:kun/data/local/json_store.dart';
import 'package:kun/data/repositories/dhikr_repository_impl.dart';
import 'package:kun/domain/models/models.dart';
import 'package:kun/features/dhikr/dhikr_add_screen.dart';
import 'package:kun/features/dhikr/dhikr_counter_screen.dart';
import 'package:kun/features/dhikr/dhikr_list_screen.dart';
import 'package:kun/data/repositories/repository_providers.dart';
import 'package:kun/features/dhikr/dhikr_session.dart';
import 'package:kun/features/dhikr/dhikr_stats_screen.dart';
import 'package:kun/features/dhikr/dhikr_widget_preview.dart';

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader.addFont(
      File(
        p,
      ).readAsBytes().then((b) => ByteData.view(Uint8List.fromList(b).buffer)),
    );
  }
  await loader.load();
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  KunThemeId id,
  String location, {
  void Function(ProviderContainer)? setup,
}) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(402 * 2, 874 * 2);
  addTearDown(tester.view.reset);

  final theme = kunThemeOf(id);
  final container = ProviderContainer(
    overrides: [jsonStoreProvider.overrideWithValue(JsonStore.inMemory())],
  );
  addTearDown(container.dispose);
  setup?.call(container);

  final router = GoRouter(
    initialLocation: location,
    routes: [
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
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: KunThemeScope(
        theme: theme,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: const MediaQueryData(
              size: Size(402, 874),
              devicePixelRatio: 2,
              padding: EdgeInsets.only(top: 59, bottom: 34),
            ),
            child: DefaultTextStyle(
              style: theme.typography.body(theme.tokens.textPrimary),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    ),
  );
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  return container;
}

void main() {
  late List<DhikrPreset> presets;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFont('JetBrainsMono', [
      'assets/fonts/JetBrainsMono-Regular.ttf',
      'assets/fonts/JetBrainsMono-Bold.ttf',
    ]);
    await _loadFont('LibreFranklin', [
      'assets/fonts/LibreFranklin-Regular.ttf',
      'assets/fonts/LibreFranklin-SemiBold.ttf',
      'assets/fonts/LibreFranklin-Bold.ttf',
    ]);
    await _loadFont('Spectral', ['assets/fonts/Spectral-SemiBold.ttf']);
    await _loadFont('Amiri', ['assets/fonts/Amiri-Regular.ttf']);
    DhikrFixture.resetCache();
    presets = (await DhikrFixture.load()).presets;
  });

  for (final id in [KunThemeId.gece, KunThemeId.kagit]) {
    testWidgets('Z1 hazır liste · ${id.slug}', (tester) async {
      await _pump(tester, id, '/zikir');
      await expectLater(
        find.byType(DhikrListScreen),
        matchesGoldenFile('images/z1_hazir_${id.slug}.png'),
      );
    });

    testWidgets('Z5 serbest liste · seri kartı · ${id.slug}', (tester) async {
      final c = await _pump(tester, id, '/zikir');
      c.read(dhikrTabProvider.notifier).select(1);
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await expectLater(
        find.byType(DhikrListScreen),
        matchesGoldenFile('images/z5_serbest_${id.slug}.png'),
      );
    });

    testWidgets('Z8 istatistik · dolu · ${id.slug}', (tester) async {
      final c = await _pump(tester, id, '/zikir/istatistik');
      // Sayım kaydet: seri kartı, grafik ve "EN ÇOK YAPILAN" görünsün.
      final repo = c.read(dhikrRepositoryProvider);
      for (var i = 0; i < 12; i++) {
        await repo.recordCount(isPreset: i % 3 != 0, delta: 1);
      }
      c.invalidate(dailyStatsProvider);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await expectLater(
        find.byType(DhikrStatsScreen),
        matchesGoldenFile('images/z8_istatistik_dolu_${id.slug}.png'),
      );
    });

    testWidgets('Z2 hazır sayaç · ${id.slug}', (tester) async {
      await _pump(
        tester,
        id,
        '/zikir/sayac',
        setup: (c) {
          final s = c.read(dhikrSessionProvider.notifier)..startPreset(presets);
          s.state = c.read(dhikrSessionProvider).copyWith(count: 24);
        },
      );
      await expectLater(
        find.byType(DhikrCounterScreen),
        matchesGoldenFile('images/z2_sayac_${id.slug}.png'),
      );
    });

    testWidgets('Z3 tamamlandı · ${id.slug}', (tester) async {
      await _pump(
        tester,
        id,
        '/zikir/sayac',
        setup: (c) {
          final s = c.read(dhikrSessionProvider.notifier)..startPreset(presets);
          s.state = c
              .read(dhikrSessionProvider)
              .copyWith(count: 33, completed: true);
        },
      );
      await expectLater(
        find.byType(DhikrCounterScreen),
        matchesGoldenFile('images/z3_tamamlandi_${id.slug}.png'),
      );
    });

    testWidgets('Z6 serbest sayaç · ${id.slug}', (tester) async {
      await _pump(
        tester,
        id,
        '/zikir/sayac',
        setup: (c) {
          final n = c.read(dhikrSessionProvider.notifier);
          n.startCustom(
            CustomDhikr(
              id: 'x',
              name: 'Sübhânallâhi ve bihamdihî',
              textAr: 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ',
              sortOrder: 0,
              createdAt: DateTime(2026),
            ),
          );
          n.state = c.read(dhikrSessionProvider).copyWith(count: 40);
        },
      );
      await expectLater(
        find.byType(DhikrCounterScreen),
        matchesGoldenFile('images/z6_serbest_${id.slug}.png'),
      );
    });

    testWidgets('Z7 zikir ekle · ${id.slug}', (tester) async {
      await _pump(tester, id, '/zikir/ekle');
      await expectLater(
        find.byType(DhikrAddScreen),
        matchesGoldenFile('images/z7_ekle_${id.slug}.png'),
      );
    });

    testWidgets('Z8 istatistik · boş · ${id.slug}', (tester) async {
      await _pump(tester, id, '/zikir/istatistik');
      await expectLater(
        find.byType(DhikrStatsScreen),
        matchesGoldenFile('images/z8_istatistik_bos_${id.slug}.png'),
      );
    });

    testWidgets('Z9 widget önizleme · ${id.slug}', (tester) async {
      await _pump(
        tester,
        id,
        '/zikir/widget',
        setup: (c) {
          final n = c.read(dhikrSessionProvider.notifier)..startPreset(presets);
          n.state = c.read(dhikrSessionProvider).copyWith(count: 24);
        },
      );
      await expectLater(
        find.byType(DhikrWidgetPreviewScreen),
        matchesGoldenFile('images/z9_widget_${id.slug}.png'),
      );
    });
  }
}
