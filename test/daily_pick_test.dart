import 'package:flutter_test/flutter_test.dart';
import 'package:kun/core/daily_pick.dart';

void main() {
  group('Ü14 · deterministik günün seçimi', () {
    test('aynı gün, kaç kez sorulursa sorulsun aynı sonuç', () {
      final sabah = DateTime(2026, 9, 9, 6, 30);
      final aksam = DateTime(2026, 9, 9, 23, 59);
      expect(DailyPick.verseIndex(sabah, 60), DailyPick.verseIndex(aksam, 60));
      expect(DailyPick.nameIndex(sabah, 99), DailyPick.nameIndex(aksam, 99));
    });

    test('gece yarısı geçişinde değişir', () {
      final dun = DateTime(2026, 9, 9, 23, 59);
      final bugun = DateTime(2026, 9, 10, 0, 1);
      expect(
        DailyPick.localDayNumber(bugun),
        DailyPick.localDayNumber(dun) + 1,
      );
    });

    test('sonuç her zaman havuz sınırları içinde', () {
      for (var d = 0; d < 400; d++) {
        final t = DateTime(2026, 1, 1).add(Duration(days: d));
        final i = DailyPick.verseIndex(t, 37);
        expect(i, inInclusiveRange(0, 36));
      }
    });

    test('boş havuzda -1 döner — çağıran boş durumu çizer', () {
      expect(DailyPick.verseIndex(DateTime(2026, 9, 9), 0), -1);
      expect(DailyPick.nameIndex(DateTime(2026, 9, 9), 0), -1);
    });

    test('ayet ve isim havuzları aynı gün farklı ofsetten seçilir', () {
      final t = DateTime(2026, 9, 9);
      expect(DailyPick.verseIndex(t, 99), isNot(DailyPick.nameIndex(t, 99)));
    });
  });
}
