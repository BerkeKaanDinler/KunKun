import '../models/models.dart';

/// Ü13 · Seri (streak) kuralı — dört madde, uydurulmadı, karar kaydı:
///
/// 1. Bir günün sayılması için **en az 1 zikir** yeterli.
/// 2. Gün sınırı **yerel saat gece yarısı**.
/// 3. Seri `daily_stats` üzerinden **türetilir**, ayrı sayaç tutulmaz.
/// 4. Cihaz saati geri alınırsa geçmiş satırlar **asla silinmez**, yalnızca
///    yeni gün eklenmez — seri ne kırılır ne şişer.
class StreakResult {
  const StreakResult({required this.current, required this.longest});

  /// Kesintisiz gün sayısı — bugün veya dün sayılmışsa devam eder.
  final int current;

  /// Seri kırılınca eski değer burada saklanır.
  final int longest;
}

class StreakCalculator {
  const StreakCalculator._();

  static const int minCountForDay = 1;

  static String dayKey(DateTime local) {
    final d = local.toLocal();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static DateTime _parse(String key) {
    final p = key.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  /// [stats] sırasız gelebilir.
  static StreakResult compute(List<DailyStat> stats, {required DateTime now}) {
    final days =
        stats
            .where((s) => s.totalCount >= minCountForDay)
            .map((s) => _parse(s.day))
            .toSet()
            .toList()
          ..sort();

    if (days.isEmpty) return const StreakResult(current: 0, longest: 0);

    var longest = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      final gap = days[i].difference(days[i - 1]).inDays;
      run = gap == 1 ? run + 1 : 1;
      if (run > longest) longest = run;
    }

    // Güncel seri: son gün bugün veya dün ise geriye doğru sayılır.
    final today = DateTime(now.year, now.month, now.day);
    final last = days.last;
    final sinceLast = today.difference(last).inDays;

    var current = 0;
    if (sinceLast <= 1) {
      current = 1;
      for (var i = days.length - 1; i > 0; i--) {
        if (days[i].difference(days[i - 1]).inDays == 1) {
          current++;
        } else {
          break;
        }
      }
    }

    if (current > longest) longest = current;
    return StreakResult(current: current, longest: longest);
  }
}
