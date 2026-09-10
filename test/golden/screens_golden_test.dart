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
import 'package:kun/data/repositories/fixture_repositories.dart';
import 'package:kun/features/category/category_screen.dart';
import 'package:kun/features/compare/compare_screen.dart';
import 'package:kun/features/discover/discover_screen.dart';
import 'package:kun/features/verse/verse_screen.dart';
import 'package:kun/features/onboarding/onboarding_controller.dart';

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

/// Ekranlar `context.pop()` ve `context.push()` çağırdığı için gerçek router
/// gerekiyor.
Future<void> _pump(WidgetTester tester, KunThemeId id, String location) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(402 * 2, 874 * 2);
  addTearDown(tester.view.reset);

  final theme = kunThemeOf(id);
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(path: '/kesif', builder: (_, _) => const DiscoverScreen()),
      GoRoute(
        path: '/kategori/:id',
        builder: (_, s) => CategoryScreen(categoryId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ayet/:id',
        builder: (_, s) => VerseScreen(verseId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/karsilastir/:id',
        builder: (_, s) => CompareScreen(verseId: s.pathParameters['id']!),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        jsonStoreProvider.overrideWithValue(
          JsonStore.inMemory({kOnboardingDoneKey: true, kUserNameKey: 'Elif'}),
        ),
      ],
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
  await tester.pumpAndSettle();
}

void main() {
  late FixtureTaxonomy taxonomy;

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
    FixtureData.resetCache();
    await FixtureData.load();
    taxonomy = await FixtureTaxonomy.load();
  });

  for (final id in [KunThemeId.gece, KunThemeId.kagit]) {
    testWidgets('keşif · ${id.slug}', (tester) async {
      await _pump(tester, id, '/kesif');
      await expectLater(
        find.byType(DiscoverScreen),
        matchesGoldenFile('images/kesif_${id.slug}.png'),
      );
    });

    testWidgets('kategori · dolu · ${id.slug}', (tester) async {
      final full = taxonomy.categories.firstWhere(
        (c) => (taxonomy.byCategory[c.id] ?? const []).length >= 4,
      );
      await _pump(tester, id, '/kategori/${full.id}');
      await expectLater(
        find.byType(CategoryScreen),
        matchesGoldenFile('images/kategori_${id.slug}.png'),
      );
    });

    testWidgets('kategori · boş · ${id.slug}', (tester) async {
      final empty = taxonomy.categories.firstWhere(
        (c) => (taxonomy.byCategory[c.id] ?? const []).isEmpty,
      );
      await _pump(tester, id, '/kategori/${empty.id}');
      await expectLater(
        find.byType(CategoryScreen),
        matchesGoldenFile('images/kategori_bos_${id.slug}.png'),
      );
    });

    testWidgets('ayet odak · ${id.slug}', (tester) async {
      await _pump(tester, id, '/ayet/F01:01');
      await expectLater(
        find.byType(VerseScreen),
        matchesGoldenFile('images/ayet_${id.slug}.png'),
      );
    });

    testWidgets('karşılaştırma · ${id.slug}', (tester) async {
      await _pump(tester, id, '/karsilastir/F01:01');
      await expectLater(
        find.byType(CompareScreen),
        matchesGoldenFile('images/karsilastirma_${id.slug}.png'),
      );
    });
  }
}
