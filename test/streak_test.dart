import 'package:flutter_test/flutter_test.dart';
import 'package:kun/domain/models/models.dart';
import 'package:kun/domain/usecases/streak.dart';

DailyStat s(String day, int n) =>
    DailyStat(day: day, totalCount: n, presetCount: n, customCount: 0);

void main() {
  final now = DateTime(2026, 9, 9);

  group('Ü13 · seri kuralı', () {
    test('veri yoksa seri 0', () {
      expect(StreakCalculator.compute([], now: now).current, 0);
    });

    test('bir günün sayılması için en az 1 zikir yeterli', () {
      final r = StreakCalculator.compute([s('2026-09-09', 1)], now: now);
      expect(r.current, 1);
    });

    test('sıfır zikirli gün seriyi kırar', () {
      final r = StreakCalculator.compute([
        s('2026-09-07', 5),
        s('2026-09-08', 0),
        s('2026-09-09', 3),
      ], now: now);
      expect(r.current, 1);
      expect(r.longest, 1);
    });

    test('kesintisiz günler sayılır', () {
      final r = StreakCalculator.compute([
        s('2026-09-07', 2),
        s('2026-09-08', 9),
        s('2026-09-09', 1),
      ], now: now);
      expect(r.current, 3);
    });

    test('dün biten seri hâlâ canlıdır, bugün henüz zikir yoksa', () {
      final r = StreakCalculator.compute([
        s('2026-09-07', 2),
        s('2026-09-08', 9),
      ], now: now);
      expect(r.current, 2);
    });

    test('iki gün önce biten seri kırılmıştır ama en uzun korunur', () {
      final r = StreakCalculator.compute([
        s('2026-09-05', 2),
        s('2026-09-06', 9),
        s('2026-09-07', 4),
      ], now: now);
      expect(r.current, 0);
      expect(r.longest, 3);
    });

    test('cihaz saati geriye alınırsa seri ne kırılır ne şişer', () {
      final stats = [
        s('2026-09-07', 2),
        s('2026-09-08', 9),
        s('2026-09-09', 1),
      ];
      final ileri = StreakCalculator.compute(stats, now: now);
      // Kullanıcı saati bir gün geri alır; geçmiş satırlar silinmez.
      final geri = StreakCalculator.compute(stats, now: DateTime(2026, 9, 8));
      expect(ileri.current, 3);
      expect(geri.current, 3);
    });

    test('sırasız gelen kayıtlar doğru hesaplanır', () {
      final r = StreakCalculator.compute([
        s('2026-09-09', 1),
        s('2026-09-07', 2),
        s('2026-09-08', 9),
      ], now: now);
      expect(r.current, 3);
    });
  });
}
