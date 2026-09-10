import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';
import 'logo_mark.dart';

/// Hero yüzeyi — Tanıtım ekranları, ana sayfa "Bugünün ismi",
/// istatistik seri kartı ve widget önizlemeleri bunu kullanır.
///
/// `--hero-surface` + iki radyal katman + sağ üstte %34 opaklıkta 188 px logo.
///
/// **Kâğıt indeks istisnası** (md/05): o temada gradyan ve logo katmanı yok,
/// düz `--hero-surface`, köşe 4 px. `glassBlur == 0` bu ayrımın anahtarı.
class HeroSurface extends StatelessWidget {
  const HeroSurface({
    this.height = 196,
    this.child,
    this.padding,
    this.logoSize = 188,
    super.key,
  });

  final double height;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final flat = !t.isGlass;
    final radius = flat ? t.radiusLg : 26.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: t.heroSurface)),
            if (!flat) ...[
              // radial-gradient(80% 70% at 24% 18%, rgba(255,255,255,.16) 0 42%, transparent 74%)
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.52, -0.64),
                      radius: 0.8,
                      colors: [
                        Color(0x29FFFFFF),
                        Color(0x29FFFFFF),
                        Color(0x00FFFFFF),
                      ],
                      stops: [0, 0.42, 0.74],
                    ),
                  ),
                ),
              ),
              // radial-gradient(70% 60% at 82% 88%, rgba(0,0,0,.5) 0 40%, transparent 76%)
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.64, 0.76),
                      radius: 0.7,
                      colors: [
                        Color(0x80000000),
                        Color(0x80000000),
                        Color(0x00000000),
                      ],
                      stops: [0, 0.40, 0.76],
                    ),
                  ),
                ),
              ),
              // Sağ üstte %34 opaklıkta logo.
              Positioned(
                right: -logoSize * 0.22,
                top: -logoSize * 0.26,
                child: LogoMark(size: logoSize, opacity: 0.34),
              ),
            ],
            if (child != null)
              Positioned.fill(
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(20),
                  child: child,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Hero üstündeki metin renkleri — dökümde sabit beyaz ve beyazın alfaları.
/// Hero yüzeyi her temada koyu olduğu için token'a bağlanmaz.
class HeroText {
  const HeroText._();

  static const Color primary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xCCFFFFFF); // ~.80
  static const Color tertiary = Color(0xBDFFFFFF); // ~.74
}
