import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Tema kimlikleri. Bu adlar kalıcı tercihte saklanır — **değiştirilmez**.
enum KunThemeId {
  yesim('yesim', 'Cam · gece yeşimi'),
  murekkep('murekkep', 'Cam · mürekkep moru'),
  bakir('bakir', 'Cam · kömür + bakır'),
  gece('gece', 'Cam · gece'),
  kagit('kagit', 'Kâğıt indeks'),
  yesimAcik('yesim-acik', 'Cam · yeşim (açık)');

  const KunThemeId(this.slug, this.label);

  final String slug;
  final String label;

  static KunThemeId? fromSlug(String? slug) {
    for (final id in KunThemeId.values) {
      if (id.slug == slug) return id;
    }
    return null;
  }
}

/// Tipografi ölçeği — `md/00-tasarim-sistemi.md`.
///
/// Ölçek bütün temalarda birebir aynıdır; yalnızca Kâğıt indeks başlıklarda
/// Spectral serif ve gövdede Libre Franklin kullanır. Künyeler her temada
/// JetBrains Mono, Arapça her temada Amiri.
@immutable
class KunTypography {
  const KunTypography({
    this.bodyFamily,
    this.headingFamily,
    this.headingWeight = FontWeight.w700,
    this.titleLetterSpacing = -0.02,
  });

  /// `null` → sistem fontu (beş tema).
  final String? bodyFamily;
  final String? headingFamily;
  final FontWeight headingWeight;
  final double titleLetterSpacing;

  static const String mono = 'JetBrainsMono';
  static const String arabic = 'Amiri';

  /// Ekran başlığı · 34
  TextStyle screenTitle(Color c) => TextStyle(
    fontFamily: headingFamily,
    fontSize: 34,
    fontWeight: headingWeight,
    letterSpacing: 34 * titleLetterSpacing,
    height: 1.12,
    color: c,
    decoration: TextDecoration.none,
  );

  /// Bölüm başlığı · 27
  TextStyle sectionTitle(Color c) => TextStyle(
    fontFamily: headingFamily,
    fontSize: 27,
    fontWeight: headingWeight,
    height: 1.2,
    color: c,
    decoration: TextDecoration.none,
  );

  /// Kart başlığı · 19–23
  TextStyle cardTitle(Color c, {double size = 19}) => TextStyle(
    fontFamily: bodyFamily,
    fontSize: size,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: c,
    decoration: TextDecoration.none,
  );

  /// Liste satırı · 16.5–17 / 600
  TextStyle listRow(Color c, {double size = 16.5}) => TextStyle(
    fontFamily: bodyFamily,
    fontSize: size,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: c,
    decoration: TextDecoration.none,
  );

  /// Gövde · 15–17.5 / 400 · line-height 1.5
  TextStyle body(Color c, {double size = 15}) => TextStyle(
    fontFamily: bodyFamily,
    fontSize: size,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: c,
    decoration: TextDecoration.none,
  );

  /// Alt metin · 12.5–13.5 / 400
  TextStyle caption(Color c, {double size = 12.5}) => TextStyle(
    fontFamily: bodyFamily,
    fontSize: size,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: c,
    decoration: TextDecoration.none,
  );

  /// Künye / etiket · 11–11.5 · JetBrains Mono · büyük harf · .10–.14em
  TextStyle meta(
    Color c, {
    double size = 11,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: mono,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: size * 0.12,
    height: 1.3,
    color: c,
    decoration: TextDecoration.none,
  );

  /// Sayaç rakamı · 40–52 / 700 · tabular
  ///
  /// T11: %135 metin ölçeğinde bile 52 px'i aşmaz — merkez diske sığmaz.
  /// Çağıran taraf [MediaQuery.textScaler] yerine bu sınırı kullanır.
  static const double counterMaxPx = 52;

  TextStyle counter(Color c, {double size = 46}) => TextStyle(
    fontFamily: bodyFamily,
    fontSize: size,
    fontWeight: FontWeight.w700,
    height: 1.05,
    color: c,
    fontFeatures: const [FontFeature.tabularFigures()],
    decoration: TextDecoration.none,
  );

  /// Arapça · liste 15 · sayaç 30–34 · renk daima `--accent`
  ///
  /// Minimum 14 px: harekeler daha küçük puntoda okunmaz.
  TextStyle arabicText(Color accent, {double size = 15}) {
    // Amiri'nin dikey metrikleri Latin fontlardan geniş (tasarım cevabı T3):
    // sayaç boyunda 1.5, liste boyunda 1.45.
    final s = size < 14 ? 14.0 : size;
    return TextStyle(
      fontFamily: arabic,
      fontSize: s,
      fontWeight: FontWeight.w400,
      height: s >= 30 ? 1.5 : 1.45,
      color: accent,
      decoration: TextDecoration.none,
    );
  }
}

/// Dökümdeki çözülmüş gölge değerleri. Tema başına değişir; Kâğıt indeks'te yok.
@immutable
class KunShadows {
  const KunShadows({this.primaryButton = const [], this.glass = const []});

  final List<BoxShadow> primaryButton;
  final List<BoxShadow> glass;
}

@immutable
class KunTheme {
  const KunTheme({
    required this.id,
    required this.tokens,
    required this.typography,
    required this.shadows,
    required this.brightness,
    required this.logoAsset,
  });

  final KunThemeId id;
  final KunTokens tokens;
  final KunTypography typography;
  final KunShadows shadows;
  final Brightness brightness;

  /// Tema varyantlı yuvarlak logo (`logo/yuvarlak/`), tasarım teslimatından.
  final String logoAsset;

  String get label => id.label;
  bool get isDark => brightness == Brightness.dark;
}
