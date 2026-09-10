import 'package:flutter/widgets.dart';

/// Tasarım dökümündeki 17 semantik token.
///
/// `md/00-tasarim-sistemi.md` `:root` bloğu 17 token adı + 3 yarıçap değeri
/// listeler. Tema tabloları yarıçapı tek satırda gösterip `--glass-blur`'ü
/// atladığı için sayım orada da 17'ye çıkıyor. Kanonik okuma `:root`:
///
///   16 renk + glassBlur = 17 token · radiusLg/Md/Sm = ayrı ölçü üçlüsü
///
/// Bileşenler **her zaman** bu adları kullanır; hiçbir yerde hex sabit yazılmaz.
@immutable
class KunTokens {
  const KunTokens({
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.border,
    required this.divider,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.track,
    required this.heroSurface,
    required this.danger,
    required this.glassFill,
    required this.glassBorder,
    required this.glassBlur,
    required this.radiusLg,
    required this.radiusMd,
    required this.radiusSm,
  });

  /// Ekran zemini.
  final Color surface;

  /// Opak liste kartı, panel.
  final Color surfaceRaised;

  /// Girinti, arama alanı, boş durum.
  final Color surfaceSunken;

  /// Opak kart kenarı.
  final Color border;

  /// Liste satır ayracı — son satırda kullanılmaz.
  final Color divider;

  /// Birincil buton, aktif durum, Arapça metin.
  final Color accent;

  /// Aksan zeminli rozet, seçili chip.
  final Color accentSoft;

  /// Aksan üstündeki metin ve ikon. Aksan zemine **yalnızca** bu yazılır.
  final Color onAccent;

  /// Başlık, gövde.
  final Color textPrimary;

  /// Alt metin, açıklama.
  final Color textSecondary;

  /// Künye, dipnot, pasif ikon.
  final Color textTertiary;

  /// Boş boncuk, boş grafik çubuğu, kapalı switch.
  final Color track;

  /// Ana sayfa "Bugünün ismi" ve istatistik seri kartı.
  final Color heroSurface;

  /// Silme, geri alınamaz işlem.
  final Color danger;

  /// Cam kart dolgusu. Kâğıt indeks'te opak yüzey değeri.
  final Color glassFill;

  /// Cam kart kenarı.
  final Color glassBorder;

  /// Cam bulanıklığı, mantıksal px.
  ///
  /// **0 ise cam kod yolu hiç çalışmaz**, opak yüzeye düşülür. Kâğıt indeks
  /// teması zaten 0; performans düşürmesi de bu değeri sıfırlayarak yapılır.
  /// Yoğun katman / iç içe kart / çalar çubuğu türevleri için
  /// [GlassLayer] kullanılır.
  final double glassBlur;

  /// Hero ve birincil kart.
  final double radiusLg;

  /// Liste kartı.
  final double radiusMd;

  /// Buton, alan.
  final double radiusSm;

  bool get isGlass => glassBlur > 0;
}

/// Cam yüzeyin kullanım yeri kademeleri — `md/00` · T9.
///
/// Bunlar **token değildir**, doğrudan yazılan kullanım yeri değerleridir.
/// `glassBlur == 0` iken hepsi 0 kabul edilir ve opak yola geçilir
/// (çarpan kullanılsaydı 0 durumunda yuvarlama bozulurdu).
enum GlassLayer {
  /// Standart cam kart · `--glass-blur`
  base(null),

  /// İç içe kart (kart içinde kart) · 18
  nested(18),

  /// Yoğun katman, yapışkan başlık · 22
  dense(22),

  /// Alt çalar çubuğu, kilit ekranı widget'ı · 24
  bar(24);

  const GlassLayer(this._px);

  final double? _px;

  double resolve(KunTokens tokens) =>
      tokens.glassBlur == 0 ? 0 : (_px ?? tokens.glassBlur);
}
