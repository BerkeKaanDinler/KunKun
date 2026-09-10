import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kun/core/theme/theme_controller.dart';
import 'package:kun/data/local/json_store.dart';
import 'package:kun/data/repositories/dhikr_repository_impl.dart';
import 'package:kun/data/repositories/repository_providers.dart';
import 'package:kun/domain/models/models.dart';
import 'package:kun/features/dhikr/dhikr_session.dart';
import 'package:kun/ui/tasbih_ring.dart';

ProviderContainer _container([Map<String, dynamic>? seed]) {
  final c = ProviderContainer(
    overrides: [jsonStoreProvider.overrideWithValue(JsonStore.inMemory(seed))],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  late List<DhikrPreset> presets;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    DhikrFixture.resetCache();
    presets = (await DhikrFixture.load()).presets;
  });

  group('Zikir · hazır set SABİT', () {
    test('dört adım · 33 · 33 · 33 · kapanışta 1', () {
      expect(presets.length, 4);
      expect(presets.map((p) => p.targetCount).toList(), [33, 33, 33, 1]);
      expect(presets.map((p) => p.nameTr).toList(), [
        'Sübhanallah',
        'Elhamdülillah',
        'Allahu Ekber',
        'Sübhanallah',
      ]);
    });

    test('Arapça metinler harekeli ve dolu', () {
      for (final p in presets) {
        expect(p.textAr.trim(), isNotEmpty, reason: p.nameTr);
        final marks = p.textAr.runes.where((r) => r >= 0x64B && r <= 0x652);
        expect(marks, isNotEmpty, reason: '${p.nameTr} harekesiz');
      }
    });

    test('anlamlar dolu', () {
      for (final p in presets) {
        expect(p.meaning.trim(), isNotEmpty, reason: p.nameTr);
      }
    });

    test('serbest zikir eklemek hazır seti etkilemez', () async {
      final c = _container();
      final repo = c.read(dhikrRepositoryProvider);
      final before = (await repo.presets()).valueOrNull!;

      await repo.addCustom(
        CustomDhikr(
          id: 'x',
          name: 'Sübhanallah',
          textAr: 'DEĞİŞTİRİLMİŞ',
          sortOrder: 0,
          createdAt: DateTime(2026),
        ),
      );

      final after = (await repo.presets()).valueOrNull!;
      expect(after.length, before.length);
      for (var i = 0; i < after.length; i++) {
        expect(after[i].nameTr, before[i].nameTr);
        expect(after[i].textAr, before[i].textAr);
        expect(after[i].meaning, before[i].meaning);
        expect(after[i].targetCount, before[i].targetCount);
      }
    });

    test('hazır set kullanıcı deposuna hiç yazılmaz', () async {
      final c = _container();
      await c
          .read(dhikrRepositoryProvider)
          .addCustom(
            CustomDhikr(
              id: 'x',
              name: 'T',
              sortOrder: 0,
              createdAt: DateTime(2026),
            ),
          );
      // Hazır set content tarafındadır; user.db karşılığına düşmez.
      final store = c.read(jsonStoreProvider);
      expect(store.read<Object>('presets'), isNull);
      expect(store.read<Object>('dhikr_presets'), isNull);
    });
  });

  group('Zikir · oturum mantığı', () {
    test('hazır sayaç hedefte durur ve tamamlandı olur', () async {
      final c = _container();
      final s = c.read(dhikrSessionProvider.notifier);
      s.startPreset(presets);

      for (var i = 0; i < 40; i++) {
        await s.tick();
      }
      final st = c.read(dhikrSessionProvider);
      expect(st.count, 33, reason: 'hedefi aşmamalı');
      expect(st.completed, isTrue);
    });

    test('sonraki adım sayacı sıfırlar, adımı ilerletir', () async {
      final c = _container();
      final s = c.read(dhikrSessionProvider.notifier);
      s.startPreset(presets);
      for (var i = 0; i < 33; i++) {
        await s.tick();
      }
      s.nextStep();
      final st = c.read(dhikrSessionProvider);
      expect(st.stepIndex, 1);
      expect(st.count, 0);
      expect(st.completed, isFalse);
      expect(st.title, 'Elhamdülillah');
    });

    test('serbest tarafta hedef yok, sayaç durmaz', () async {
      final c = _container();
      final s = c.read(dhikrSessionProvider.notifier);
      s.startCustom(
        CustomDhikr(
          id: 'x',
          name: 'Test',
          sortOrder: 0,
          createdAt: DateTime(2026),
        ),
      );
      for (var i = 0; i < 70; i++) {
        await s.tick();
      }
      final st = c.read(dhikrSessionProvider);
      expect(st.target, isNull);
      expect(st.completed, isFalse);
      expect(st.count, 70, reason: 'sayaç durmamalı');
      expect(st.round, 3, reason: '70 = 2 tam tur + 4');
    });

    test('künye biçimi', () {
      final c = _container();
      final s = c.read(dhikrSessionProvider.notifier);
      s.startPreset(presets);
      expect(c.read(dhikrSessionProvider).badge, 'HAZIR · 1/4 · HEDEF 33');
      s.startCustom(
        CustomDhikr(
          id: 'x',
          name: 'T',
          sortOrder: 0,
          createdAt: DateTime(2026),
        ),
      );
      expect(c.read(dhikrSessionProvider).badge, 'SERBEST · SINIRSIZ');
    });

    test('sayımlar daily_stats\'e yazılır, seri oradan türetilir', () async {
      final c = _container();
      final s = c.read(dhikrSessionProvider.notifier);
      s.startPreset(presets);
      for (var i = 0; i < 5; i++) {
        await s.tick();
      }
      final stats =
          (await c.read(dhikrRepositoryProvider).dailyStats()).valueOrNull!;
      expect(stats.length, 1);
      expect(stats.first.totalCount, 5);
      expect(stats.first.presetCount, 5);
      expect(stats.first.customCount, 0);
    });
  });

  group('Zikir · serbest liste', () {
    test('ilk açılışta örnek kayıtlar gelir', () async {
      final c = _container();
      final list =
          (await c.read(dhikrRepositoryProvider).customList()).valueOrNull!;
      expect(list.length, 3);
      expect(list.first.name, 'Sübhânallâhi ve bihamdihî');
    });

    test('ekleme ve silme çalışır', () async {
      final c = _container();
      final repo = c.read(dhikrRepositoryProvider);
      await repo.addCustom(
        CustomDhikr(
          id: 'yeni',
          name: 'Yeni zikir',
          sortOrder: 0,
          createdAt: DateTime(2026),
        ),
      );
      var list = (await repo.customList()).valueOrNull!;
      expect(list.length, 4);
      await repo.removeCustom('yeni');
      list = (await repo.customList()).valueOrNull!;
      expect(list.any((e) => e.id == 'yeni'), isFalse);
    });

    test('Arapça boş bırakılırsa null kalır — uydurulmaz', () async {
      final c = _container();
      final repo = c.read(dhikrRepositoryProvider);
      await repo.addCustom(
        CustomDhikr(
          id: 'bos',
          name: 'Arapçasız',
          sortOrder: 0,
          createdAt: DateTime(2026),
        ),
      );
      final list = (await repo.customList()).valueOrNull!;
      final added = list.firstWhere((e) => e.id == 'bos');
      expect(added.textAr, isNull);
    });
  });

  group('Zikir · halka geometrisi', () {
    test('33 boncuk · −90° başlangıç · 10.909° adım', () {
      expect(TasbihRing.beadCount, 33);
      expect(TasbihRing.stepDegrees, closeTo(10.909, 0.001));
    });

    test('tasarımdaki ilk boncuk konumu birebir tutuyor', () {
      // Tasarım: size 306, boncuk 13 → left:146.5px top:6.0px
      const size = 306.0;
      const bead = 13.0;
      final radius = size / 2 - bead / 2 - 6;
      final angle = -90 * math.pi / 180;
      final cx = size / 2 + radius * math.cos(angle);
      final cy = size / 2 + radius * math.sin(angle);
      expect(cx - bead / 2, closeTo(146.5, 0.05));
      expect(cy - bead / 2, closeTo(6.0, 0.05));
    });

    test('ikinci boncuk da tasarımla aynı', () {
      // Tasarım: left:173.1px top:8.5px
      const size = 306.0;
      const bead = 13.0;
      final radius = size / 2 - bead / 2 - 6;
      final angle = (-90 + TasbihRing.stepDegrees) * math.pi / 180;
      final cx = size / 2 + radius * math.cos(angle);
      final cy = size / 2 + radius * math.sin(angle);
      expect(cx - bead / 2, closeTo(173.1, 0.1));
      expect(cy - bead / 2, closeTo(8.5, 0.1));
    });
  });
}
