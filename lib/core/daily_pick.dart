/// Ü14 · Günün ayeti ve bugünün ismi — deterministik seçim.
///
/// Kural (mimari brief):
/// · seçim tarihten türetilir, rastgele değildir
/// · aynı gün uygulama kaç kez açılırsa açılsın aynı sonucu verir
/// · uygulama ve widget aynı sonucu üretmeli → **algoritma tek yerde**
/// · yerel tarih kullanılır, gece yarısı geçişinde değişir
///
/// Aşama 3'te native widget de bu formülü çağırır; formül değişirse
/// yalnızca burası değişir.
class DailyPick {
  const DailyPick._();

  /// Havuzlar arası çakışmayı önlemek için sabit ofsetler.
  static const int _verseOffset = 0;
  static const int _nameOffset = 7;

  /// Yerel gün numarası — saat/dakika atılır, gece yarısında artar.
  static int localDayNumber(DateTime now) {
    final local = now.toLocal();
    return DateTime(
          local.year,
          local.month,
          local.day,
        ).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  static int _index(DateTime now, int poolSize, int offset) {
    if (poolSize <= 0) return -1;
    final day = localDayNumber(now) + offset;
    return ((day % poolSize) + poolSize) % poolSize;
  }

  /// Günün ayeti indeksi.
  ///
  /// Havuz **kategorilere bağlı ayetlerden** oluşur, tüm Kur'an'dan değil
  /// (mimari brief). Havuz boşsa -1 döner, çağıran boş durumu çizer.
  static int verseIndex(DateTime now, int poolSize) =>
      _index(now, poolSize, _verseOffset);

  /// Bugünün ismi indeksi (0 tabanlı). Ekranda "99 isimden N." olarak
  /// gösterilirken +1 eklenir.
  static int nameIndex(DateTime now, int poolSize) =>
      _index(now, poolSize, _nameOffset);
}
