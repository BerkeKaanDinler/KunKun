import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kun/core/theme/kun_theme.dart';
import 'package:kun/core/theme/theme_controller.dart';
import 'package:kun/core/theme/themes/themes.dart';
import 'package:kun/data/local/json_store.dart';
import 'package:kun/dev/theme_gallery_screen.dart';
import 'package:kun/ui/metrics.dart';

/// Altı temanın tam sayfa render'ı. Simülatörde kaydırma otomatikleştirilemediği
/// için görsel doğrulama buradan yapılır; aynı zamanda Bölüm 2+ için regresyon
/// koruması olur.
///
/// Güncellemek için: `flutter test --update-goldens test/golden`
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

  for (final id in KunThemeId.values) {
    testWidgets('tema galerisi · ${id.slug}', (tester) async {
      // Tasarım genişliği 402 px; yükseklik içeriği tam alacak kadar uzun.
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(402 * 2, 2600 * 2);
      addTearDown(tester.view.reset);

      final store = JsonStore.inMemory({kThemePrefKey: id.slug});
      final theme = kunThemeOf(id);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [jsonStoreProvider.overrideWithValue(store)],
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(402, 2600),
              devicePixelRatio: 2,
              padding: EdgeInsets.only(top: 59, bottom: 34),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: KunThemeScope(
                theme: theme,
                child: DefaultTextStyle(
                  style: theme.typography.body(theme.tokens.textPrimary),
                  child: const ThemeGalleryScreen(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ThemeGalleryScreen),
        matchesGoldenFile('images/gallery_${id.slug}.png'),
      );
    });
  }

  testWidgets('metin ölçeği %135 · varsayılan tema bozulmuyor', (tester) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(402 * 2, 3200 * 2);
    addTearDown(tester.view.reset);

    final store = JsonStore.inMemory({kThemePrefKey: KunThemeId.gece.slug});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [jsonStoreProvider.overrideWithValue(store)],
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(402, 3200),
            devicePixelRatio: 2,
            padding: EdgeInsets.only(top: 59, bottom: 34),
            textScaler: TextScaler.linear(KunMetrics.textScaleMax),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: KunThemeScope(
              theme: kunThemeGece,
              child: DefaultTextStyle(
                style: kunThemeGece.typography.body(
                  kunThemeGece.tokens.textPrimary,
                ),
                child: const ThemeGalleryScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Taşma varsa test burada hata verir.
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(ThemeGalleryScreen),
      matchesGoldenFile('images/gallery_gece_135.png'),
    );
  });
}
