/// `md/00-tasarim-sistemi.md` · Cihaz ve çerçeve.
///
/// Tasarım 402 × 874 px üzerine çizildi. **Yatay** kenar boşlukları ve dolgular
/// korunur; yükseklikler esner, ekranlar kaydırılabilir olur.
class KunMetrics {
  const KunMetrics._();

  /// Ekran kökü üst dolgu — durum çubuğu payı.
  static const double screenTop = 58;

  /// Ekran kökü alt dolgu.
  static const double screenBottom = 22;

  /// Sayaç ekranlarında alt dolgu.
  static const double screenBottomCounter = 26;

  /// Açılış / onboarding'de alt dolgu.
  static const double screenBottomOnboarding = 34;

  /// Kart kenar boşluğu.
  static const double gutterCard = 18;

  /// Metin kenar boşluğu.
  static const double gutterText = 20;

  /// Tam genişlik listelerde kenar boşluğu.
  static const double gutterList = 14;

  /// Dikey ritim.
  static const double v9 = 9;
  static const double v12 = 12;
  static const double v14 = 14;
  static const double v16 = 16;
  static const double v20 = 20;

  /// Kart içi dolgu aralığı.
  static const double cardPadMin = 11;
  static const double cardPadMax = 22;

  /// **Sabit** — hiçbir koşulda küçülmez.
  static const double minTouch = 44;

  static const double primaryButtonHeight = 56;
  static const double secondaryButtonHeight = 52;
  static const double listRowMinHeight = 60;

  /// Ana sayfa kartındaki yuvarlak oynat butonu.
  static const double playButtonSize = 34;

  /// Metin ölçeği sınırları. Sistemde daha yükseği seçilse bile layout dağılmaz;
  /// teslim şartı olan %135 korunur.
  static const double textScaleMin = 0.85;
  static const double textScaleMax = 1.35;
}
