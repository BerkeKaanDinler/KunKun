import 'package:flutter/widgets.dart';

import '../core/features.dart';
import '../core/theme/tokens_ext.dart';
import 'icons.dart';
import 'metrics.dart';

/// Kapalı özelliklerin ekrandaki davranışı **tek yerden** yönetilir.
/// Hiçbir ekran `Features.audio` koşulunu kendi içinde yazmaz.
class FeatureGate {
  const FeatureGate._();

  /// Alt çalar çubuğu · Ü1 / T7 · `audio == false` iken **hiç çizilmez**;
  /// boşalan ~76 px kaydırma alanına katılır, pasif çubuk gösterilmez.
  ///
  /// Etkilenen dört ekran: Tüm ayetler · Keşif · Kategori · Karşılaştırma.
  /// **Ayet odak bunun dışındadır** — bkz. [verseFocusBar].
  static Widget? audioBar(Widget Function() build) =>
      Features.audio ? build() : null;

  /// Ayet odak ekranının alt çubuğu · T7 istisnası.
  ///
  /// Bu çubuk bir çalar değil, **ayet gezinme çubuğudur**. Ses kapalıyken
  /// çubuk kaybolmaz; yalnızca ortadaki oynat butonu düşer, gezinme okları
  /// kalır. Ses açıkken oynat butonu aralarına girer.
  static Widget verseFocusBar({
    required Widget previous,
    required Widget next,
    required Widget Function() playButton,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [previous, if (Features.audio) playButton(), next],
    );
  }

  /// Ana sayfa "Tüm ayetler" kartındaki yuvarlak oynat butonu —
  /// `audio == false` iken **çizilmez**, kart yalnızca oka dallanır.
  static Widget? homePlayButton(Widget Function() build) =>
      Features.audio ? build() : null;

  /// Ayarlar'daki SES grubu — `false` iken gizlenir, boş grup bırakılmaz.
  static bool get showAudioSettings => Features.audio;

  /// Kaydedilenler sekmeleri.
  ///
  /// Gerçek tasarımdaki ikinci sekme **"Konular"** (kaydedilen kategoriler),
  /// `md/10` iskeletinin dediği "Notlar" değil. Notlar Aşama 3'te ayrı bir
  /// sekme olarak eklenir; `notes == false` iken çizilmez (Ü2).
  static List<String> get savedTabs => [
    'Ayetler',
    'Konular',
    if (Features.notes) 'Notlar',
  ];

  /// Ana sayfa "Tüm ayetler" kartı — kapalıysa ana sayfa iki karta dallanır.
  static bool get showSequentialCard => Features.sequential;

  /// Widget ekranlarına giriş · Ü5 · Ayarlar › WIDGET grubundan,
  /// satırlar ÖNİZLEME künyesiyle.
  static bool get showWidgetSettings => true;
}

/// Ses kapalıyken ayet odak ekranında **çizilen ama pasif** oynat butonu.
/// Dokununca kısa bir bilgi metni gösterilir (mimari brief).
class DimmedPlayButton extends StatelessWidget {
  const DimmedPlayButton({
    required this.onTap,
    this.size = KunMetrics.minTouch,
    super.key,
  });

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      enabled: false,
      label: 'Oynat — ses kaydı henüz eklenmedi',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: KunMetrics.minTouch,
          height: KunMetrics.minTouch,
          child: Center(
            child: Opacity(
              opacity: 0.4,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: t.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  KunIcons.play,
                  color: t.onAccent,
                  size: size * 0.45,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
