import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kun/app.dart';
import 'package:kun/core/theme/theme_controller.dart';
import 'package:kun/data/local/json_store.dart';
import 'package:kun/data/repositories/fixture_repositories.dart';
import 'package:kun/data/repositories/repository_providers.dart';
import 'package:kun/features/saved/saved_screen.dart';
import 'package:kun/features/sequential/sequential_screen.dart';
import 'package:kun/features/onboarding/onboarding_controller.dart';
import 'package:kun/ui/states.dart';

Future<void> _tick(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<ProviderContainer> _boot(WidgetTester tester) async {
  final container = ProviderContainer(
    overrides: [
      jsonStoreProvider.overrideWithValue(
        JsonStore.inMemory({kOnboardingDoneKey: true, kUserNameKey: 'Elif'}),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const KunApp()),
  );
  await tester.pump(const Duration(milliseconds: 1200));
  await _tick(tester);
  return container;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FixtureData.resetCache();
    await FixtureData.load();
    await FixtureTaxonomy.load();
  });

  group('Bölüm 5 · kaydedilenler', () {
    testWidgets('boşken boş durum gösterir', (tester) async {
      final c = await _boot(tester);
      c.read(routerProvider).push('/kaydedilenler');
      await _tick(tester);

      expect(find.byType(SavedScreen), findsOneWidget);
      expect(find.text(KunStateCopy.saved.title), findsOneWidget);
    });

    testWidgets('kaydetme yalnızca verseId yazar, metin kopyalanmaz', (
      tester,
    ) async {
      final c = await _boot(tester);
      final repo = c.read(savedRepositoryProvider);
      await repo.save('F01:01', sourceCategoryId: 'A01');
      await tester.pump(const Duration(milliseconds: 200));

      final store = c.read(jsonStoreProvider);
      final raw = store.read<List<dynamic>>('saved_verses')!;
      expect(raw.length, 1);
      final row = raw.first as Map;
      expect(row['verseId'], 'F01:01');
      expect(row['sourceCategoryId'], 'A01');
      // Referans bütünlüğü: metin alanı hiç yazılmaz.
      expect(row.containsKey('text'), isFalse);
      expect(row.keys.length, 3);
    });

    testWidgets('kaydedilen ayet listede görünür ve silinebilir', (
      tester,
    ) async {
      final c = await _boot(tester);
      await c.read(savedRepositoryProvider).save('F01:01');
      await tester.pump(const Duration(milliseconds: 200));

      c.read(routerProvider).push('/kaydedilenler');
      await _tick(tester);
      expect(find.text(KunStateCopy.saved.title), findsNothing);

      await c.read(savedRepositoryProvider).remove('F01:01');
      await tester.pump(const Duration(milliseconds: 200));
      await _tick(tester);
      expect(find.text(KunStateCopy.saved.title), findsOneWidget);
    });

    testWidgets('aynı ayet iki kez kaydedilmez', (tester) async {
      final c = await _boot(tester);
      final repo = c.read(savedRepositoryProvider);
      await repo.save('F01:01');
      await repo.save('F01:01');
      await tester.pump(const Duration(milliseconds: 200));
      expect((await repo.all()).valueOrNull!.length, 1);
    });
  });

  group('Bölüm 5 · tüm ayetler', () {
    testWidgets('sûre listesi çizilir, ilk sûre açık gelir', (tester) async {
      final c = await _boot(tester);
      c.read(routerProvider).push('/tum-ayetler');
      await _tick(tester);

      expect(find.byType(SequentialScreen), findsOneWidget);
      expect(find.text('Örnek sûre 1'), findsOneWidget);
      // Açık sûrede "kalan N ayeti göster" satırı var (6 ayet, 4 gösterilir).
      expect(find.textContaining('Kalan'), findsOneWidget);
    });

    testWidgets('Ü8 · arama placeholderı nötr', (tester) async {
      final c = await _boot(tester);
      c.read(routerProvider).push('/tum-ayetler');
      await _tick(tester);
      expect(find.text('Sûre veya ayet ara'), findsOneWidget);
      expect(find.textContaining('2:255'), findsNothing);
    });
  });
}
