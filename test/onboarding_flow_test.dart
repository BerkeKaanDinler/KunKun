import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kun/app.dart';
import 'package:kun/core/theme/theme_controller.dart';
import 'package:kun/data/local/json_store.dart';
import 'package:kun/features/home/home_screen.dart';
import 'package:kun/features/onboarding/intro_screen.dart';
import 'package:kun/features/onboarding/name_screen.dart';
import 'package:kun/features/onboarding/onboarding_controller.dart';
import 'package:kun/features/onboarding/splash_screen.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Map<String, dynamic>? seed,
}) async {
  final store = JsonStore.inMemory(seed);
  final container = ProviderContainer(
    overrides: [jsonStoreProvider.overrideWithValue(store)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const KunApp()),
  );
  await tester.pump();
  return container;
}

void main() {
  group('Bölüm 2 · giriş akışı', () {
    testWidgets('açılış → tanıtım 1 → tanıtım 2 → isim → ana', (tester) async {
      await _pump(tester);
      expect(find.byType(SplashScreen), findsOneWidget);

      // Açılış kendiliğinden ilerler.
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(find.byType(IntroScreen), findsOneWidget);
      expect(find.text('Hissettiğin duyguya göre ayetler'), findsOneWidget);

      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();
      expect(find.text('Dinle, kaydet, mealleri karşılaştır'), findsOneWidget);

      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();
      expect(find.byType(NameScreen), findsOneWidget);

      await tester.tap(find.text('Başla'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('gizlilik cümlesi zorunlu — isim ekranında görünür', (
      tester,
    ) async {
      await _pump(tester, seed: {kOnboardingDoneKey: false});
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('yalnızca telefonunda saklanır'),
        findsOneWidget,
        reason: 'Mimari brief · Gizlilik — bu cümle kaldırılamaz',
      );
    });

    testWidgets('"Atla" çalışır ve isim yazılmaz', (tester) async {
      final c = await _pump(tester);
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Atla'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      final state = c.read(onboardingProvider);
      expect(state.completed, isTrue);
      expect(state.name, isNull);
    });

    testWidgets(
      'isim girilirse kaydedilir ve ana sayfada selamlamada görünür',
      (tester) async {
        final c = await _pump(tester);
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Devam'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Devam'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(EditableText), '  Berke  ');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Başla'));
        await tester.pumpAndSettle();

        // Baştaki/sondaki boşluk kırpılır.
        expect(c.read(onboardingProvider).name, 'Berke');
        expect(find.textContaining('Berke'), findsOneWidget);
      },
    );

    testWidgets('akış tamamlandıysa açılış doğrudan ana sayfaya gider', (
      tester,
    ) async {
      await _pump(
        tester,
        seed: {kOnboardingDoneKey: true, kUserNameKey: 'Taha'},
      );
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      expect(find.byType(IntroScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.textContaining('Taha'), findsOneWidget);
    });

    testWidgets('sıfırlama akışı baştan gezilebilir yapar', (tester) async {
      final c = await _pump(tester, seed: {kOnboardingDoneKey: true});
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      c.read(onboardingProvider.notifier).reset();
      // JsonStore yazmayı 120 ms geciktirir; zamanlayıcı boşa çıkmalı.
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(c.read(onboardingProvider).completed, isFalse);
    });
  });
}
