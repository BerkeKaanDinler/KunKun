import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kun/app.dart';
import 'package:kun/core/theme/theme_controller.dart';
import 'package:kun/data/local/json_store.dart';
import 'package:kun/data/repositories/fixture_repositories.dart';
import 'package:kun/features/category/category_screen.dart';
import 'package:kun/features/discover/discover_screen.dart';
import 'package:kun/features/home/home_screen.dart';
import 'package:kun/features/onboarding/onboarding_controller.dart';
import 'package:kun/ui/states.dart';

/// **Kural:** `testWidgets` gövdesinde varlık okumak (`rootBundle`) testi asar
/// — fake-async gerçek I/O'yu ilerletmez ve `pumpAndSettle` hiç dönmez.
/// Fixture'lar `setUpAll` içinde gerçek async ile bir kez yüklenir; testler
/// yalnızca önbellekten okur ve cache **sıfırlanmaz**.
Future<void> _tick(WidgetTester tester, [int frames = 6]) async {
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
  late FixtureTaxonomy taxonomy;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FixtureData.resetCache();
    await FixtureData.load();
    taxonomy = await FixtureTaxonomy.load();
  });

  group('Bölüm 4 · fixture taksonomisi', () {
    test('16 aile · 160 kategori · 70/90', () {
      expect(taxonomy.families.length, 16);
      expect(taxonomy.categories.length, 160);
      expect(
        taxonomy.categories
            .where((c) => 'ABCDEFM'.contains(c.familyCode))
            .length,
        70,
      );
      expect(
        taxonomy.categories
            .where((c) => 'GHIJKLNOP'.contains(c.familyCode))
            .length,
        90,
      );
    });

    test('kategori kodları A01–P10 biçiminde', () {
      final re = RegExp(r'^[A-P]\d{2}$');
      for (final c in taxonomy.categories) {
        expect(re.hasMatch(c.id), isTrue, reason: c.id);
      }
    });

    test('Ü10 · ~20 kategori kasıtlı boş, P ailesi seyrek', () {
      final empty = taxonomy.categories
          .where((c) => (taxonomy.byCategory[c.id] ?? const []).isEmpty)
          .length;
      expect(empty, inInclusiveRange(15, 30));

      for (final name in ['Fil', 'Karınca', 'Örümcek']) {
        final c = taxonomy.categories.firstWhere((e) => e.name == name);
        final n = (taxonomy.byCategory[c.id] ?? const []).length;
        expect(n, inInclusiveRange(1, 3), reason: name);
      }
    });

    test('günün ayeti havuzu kategorilere bağlı ayetlerden gelir', () {
      expect(taxonomy.byVerse.keys, isNotEmpty);
      for (final vid in taxonomy.byVerse.keys) {
        expect(taxonomy.byVerse[vid], isNotEmpty);
      }
    });
  });

  group('Bölüm 4 · gezinme', () {
    testWidgets('ana sayfa → keşif → kategori', (tester) async {
      await _boot(tester);
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('Ayetler'));
      await _tick(tester);
      expect(find.byType(DiscoverScreen), findsOneWidget);

      // T8 · açılışta Hayattan seçili, ilk aile "Zor duygular".
      expect(find.text('Zor duygular'), findsOneWidget);

      await tester.tap(find.text('Kaygı'));
      await _tick(tester);
      expect(find.byType(CategoryScreen), findsOneWidget);
    });

    testWidgets('eksen chipi Kur\'an\'dan tarafına geçirir', (tester) async {
      await _boot(tester);
      await tester.tap(find.text('Ayetler'));
      await _tick(tester);

      await tester.tap(find.text("Kur'an'dan"));
      await _tick(tester);

      expect(find.text("Allah'ı tanımak"), findsOneWidget);
      expect(find.text('Zor duygular'), findsNothing);
    });

    testWidgets('boş kategori boş durumu gösterir', (tester) async {
      final emptyCat = taxonomy.categories.firstWhere(
        (c) => (taxonomy.byCategory[c.id] ?? const []).isEmpty,
      );

      final c = await _boot(tester);
      c.read(routerProvider).push('/kategori/${emptyCat.id}');
      await _tick(tester);

      expect(find.byType(KunStateView), findsOneWidget);
      expect(find.text(KunStateCopy.category.title), findsOneWidget);
    });
  });
}
