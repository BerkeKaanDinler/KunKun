import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kun/core/theme/kun_theme.dart';
import 'package:kun/core/theme/theme_controller.dart';
import 'package:kun/core/theme/themes/themes.dart';
import 'package:kun/data/local/json_store.dart';
import 'package:kun/features/onboarding/intro_screen.dart';
import 'package:kun/features/onboarding/name_screen.dart';
import 'package:kun/features/home/home_screen.dart';
import 'package:kun/features/onboarding/onboarding_controller.dart';
import 'package:kun/features/onboarding/splash_screen.dart';

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

Future<void> _pumpScreen(
  WidgetTester tester,
  KunThemeId id,
  Widget screen, {
  Map<String, dynamic>? seed,
}) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(402 * 2, 874 * 2);
  addTearDown(tester.view.reset);

  final theme = kunThemeOf(id);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        jsonStoreProvider.overrideWithValue(JsonStore.inMemory(seed)),
      ],
      child: MediaQuery(
        data: const MediaQueryData(
          size: Size(402, 874),
          devicePixelRatio: 2,
          padding: EdgeInsets.only(top: 59, bottom: 34),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: KunThemeScope(
            theme: theme,
            child: DefaultTextStyle(
              style: theme.typography.body(theme.tokens.textPrimary),
              child: screen,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Açılış ekranı için gerçek router'lı harness.
Future<void> _pumpRouted(WidgetTester tester, KunThemeId id) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(402 * 2, 874 * 2);
  addTearDown(tester.view.reset);

  final theme = kunThemeOf(id);
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/tanitim', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(path: '/ana', builder: (_, _) => const SizedBox.shrink()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [jsonStoreProvider.overrideWithValue(JsonStore.inMemory())],
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
  await tester.pump();
}

void main() {
  setUpAll(() async {
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
  });

  // Varsayılan tema ve opak tema — cam/opak iki kod yolunu da kapsar.
  for (final id in [KunThemeId.gece, KunThemeId.kagit]) {
    testWidgets('açılış · ${id.slug}', (tester) async {
      // Açılış kendiliğinden yönlenir; izole harness yerine gerçek router
      // gerekir, yoksa zamanlayıcı "No GoRouter found" ile patlar.
      await _pumpRouted(tester, id);
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('images/onb_acilis_${id.slug}.png'),
      );
      // Bekleyen zamanlayıcı kalmasın.
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
    });

    testWidgets('tanıtım 1 · ${id.slug}', (tester) async {
      await _pumpScreen(tester, id, const IntroScreen(step: 0));
      await expectLater(
        find.byType(IntroScreen),
        matchesGoldenFile('images/onb_tanitim1_${id.slug}.png'),
      );
    });

    testWidgets('tanıtım 2 · ${id.slug}', (tester) async {
      await _pumpScreen(tester, id, const IntroScreen(step: 1));
      await expectLater(
        find.byType(IntroScreen),
        matchesGoldenFile('images/onb_tanitim2_${id.slug}.png'),
      );
    });

    testWidgets('ana sayfa · ${id.slug}', (tester) async {
      await _pumpScreen(
        tester,
        id,
        const HomeScreen(),
        seed: {kOnboardingDoneKey: true, kUserNameKey: 'Elif'},
      );
      await tester.pump();
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('images/home_${id.slug}.png'),
      );
    });

    testWidgets('isim · ${id.slug}', (tester) async {
      await _pumpScreen(tester, id, const NameScreen());
      await expectLater(
        find.byType(NameScreen),
        matchesGoldenFile('images/onb_isim_${id.slug}.png'),
      );
    });
  }

  testWidgets('isim ekranı %135 metin ölçeğinde taşmıyor', (tester) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(402 * 2, 874 * 2);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [jsonStoreProvider.overrideWithValue(JsonStore.inMemory())],
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(402, 874),
            devicePixelRatio: 2,
            padding: EdgeInsets.only(top: 59, bottom: 34),
            textScaler: TextScaler.linear(1.35),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: KunThemeScope(
              theme: kunThemeGece,
              child: DefaultTextStyle(
                style: kunThemeGece.typography.body(
                  kunThemeGece.tokens.textPrimary,
                ),
                child: const NameScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(NameScreen),
      matchesGoldenFile('images/onb_isim_gece_135.png'),
    );
  });
}
