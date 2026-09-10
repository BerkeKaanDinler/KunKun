/// Kapsamı kod silmeden yönetmek için — mimari brief · Özellik bayrakları.
///
/// Kapalı bir özelliğin ekrandaki davranışı **tek yerden** yönetilir;
/// her ekranda ayrı koşul yazılmaz. Bkz. `ui/feature_gate.dart`.
class Features {
  const Features._();

  /// Ses tedariki bitince açılır.
  ///
  /// `false` iken (mimari brief · "Ses kapalıyken ne görünür"):
  /// · alt çalar çubuğu **hiç çizilmez** (Ü1)
  /// · ana sayfadaki oynat butonu çizilmez, kart yalnızca oka dallanır
  /// · ayet odak ekranındaki oynat butonu çizilir ama pasiftir
  /// · Ayarlar'daki SES grubu gizlenir
  static const bool audio = false;

  static const bool ads = false;

  /// Aşama 3. `false` iken Kaydedilenler tek sekme kalır, sekme çubuğu gizlenir.
  /// Ü2: Notlar ekranı bu turda kodlanmaz.
  static const bool notes = false;

  /// Arayüz var; fixture ile kısa liste.
  static const bool sequential = true;

  /// Ü4: hero yerinde kalır. 99 isim verisi gelmediği için içerik
  /// "veri bekleniyor" durumunda çizilir — uydurulmaz.
  static const bool asmaulHusna = true;

  /// Aşama 1'de tam kodlanır.
  static const bool dhikr = true;

  /// Native iş — Aşama 3. Aşama 1'de widget yalnızca uygulama içi önizleme.
  static const bool lockWidget = false;

  /// Ü16 · geliştirici anahtarı. Yayın derlemesinde bölüm görünmez.
  static const bool devTools = true;
}
