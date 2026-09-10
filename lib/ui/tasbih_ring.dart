import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';
import 'logo_mark.dart';

/// Tesbih halkası — `md/11-zikir-ekranlari.md` · halka geometrisi.
///
/// ```
/// kap          : size × size (306 / 274 / 266 px)
/// boncuk çapı  : 13 px (306), 12 px (274 ve 266)
/// yarıçap      : size/2 − boncuk/2 − 6
/// ilk boncuk   : −90° (saat 12), sonra 360/33 = 10.909° adımlarla saat yönünde
/// aktif boncuk : çap +3 px
/// dış çember   : inset boncuk+2
/// merkez disk  : inset boncuk+18
/// ```
///
/// T11 · dar ekranda halka ölçeklenir; **geometri birebir korunur**.
/// Boncuk 9 px'in altına inmez — bunun yerine merkez disk küçülür.
class TasbihRing extends StatefulWidget {
  const TasbihRing({
    required this.count,
    this.target,
    this.designSize = 306,
    this.dashedOuter = false,
    this.caption,
    this.onTap,
    super.key,
  });

  /// Bu turdaki sayım. 33'ün üstünde halka başa döner.
  final int count;

  /// Hedef — serbest tarafta **null** (hedef yok, sayaç durmaz).
  final int? target;

  final double designSize;

  /// Serbest sayaçta dış çember kesiklidir.
  final bool dashedOuter;

  final String? caption;
  final VoidCallback? onTap;

  static const int beadCount = 33;
  static const double stepDegrees = 360 / beadCount;

  @override
  State<TasbihRing> createState() => _TasbihRingState();
}

class _TasbihRingState extends State<TasbihRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  );

  @override
  void didUpdateWidget(TasbihRing old) {
    super.didUpdateWidget(old);
    if (widget.count != old.count) {
      _pulse
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // prefers-reduced-motion: ölçek ve dalga kapanır, renk geçişi kalır.
    final reduceMotion = media.disableAnimations;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - 36; // 2 × 18 kenar boşluğu
        final size = math.min(widget.designSize, available);
        final scale = size / widget.designSize;
        final designBead = widget.designSize >= 300 ? 13.0 : 12.0;
        var bead = (designBead * scale).roundToDouble();
        // Boncuk 9 px altına düşmez; halka küçülmez, merkez disk küçülür.
        if (bead < 9) bead = 9;
        final radius = size / 2 - bead / 2 - 6 * scale;
        final filled = widget.count % TasbihRing.beadCount;
        final activeIndex = filled == 0 && widget.count > 0
            ? TasbihRing.beadCount - 1
            : filled - 1;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Dış çember · inset boncuk+2
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(bead + 2 * scale),
                    child: _OuterCircle(dashed: widget.dashedOuter),
                  ),
                ),
                for (var i = 0; i < TasbihRing.beadCount; i++)
                  _bead(
                    context,
                    i,
                    size,
                    bead,
                    radius,
                    activeIndex,
                    reduceMotion,
                  ),
                // Merkez disk · inset boncuk+18
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(bead + 18 * scale),
                    child: _CenterDisc(
                      count: widget.count,
                      target: widget.target,
                      caption: widget.caption,
                      scale: scale,
                      // Tasarım: 306 halkada sayaç 52 / logo 62,
                      // 274 ve 266 halkada 40 / 54.
                      designNumber: widget.designSize >= 300 ? 52 : 40,
                      designLogo: widget.designSize >= 300 ? 62 : 54,
                      pulse: _pulse,
                      reduceMotion: reduceMotion,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bead(
    BuildContext context,
    int i,
    double size,
    double bead,
    double radius,
    int activeIndex,
    bool reduceMotion,
  ) {
    final t = context.tokens;
    final filled = widget.count % TasbihRing.beadCount;
    final isFilled = widget.count > 0 && (filled == 0 || i < filled);
    final isActive = i == activeIndex;
    // İlk boncuk −90°, sonra saat yönünde 10.909° adımlarla.
    final angle = (-90 + i * TasbihRing.stepDegrees) * math.pi / 180;
    final d = isActive && !reduceMotion ? bead + 3 : bead;
    final cx = size / 2 + radius * math.cos(angle);
    final cy = size / 2 + radius * math.sin(angle);

    return Positioned(
      left: cx - d / 2,
      top: cy - d / 2,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: isFilled ? t.accent : t.track,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _OuterCircle extends StatelessWidget {
  const _OuterCircle({required this.dashed});

  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CustomPaint(
      painter: _CirclePainter(color: t.border, dashed: dashed),
    );
  }
}

class _CirclePainter extends CustomPainter {
  _CirclePainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color
      ..isAntiAlias = true;
    final r = size.width / 2;
    final c = size.center(Offset.zero);
    if (!dashed) {
      canvas.drawCircle(c, r, paint);
      return;
    }
    // Serbest sayaçta kesikli çember.
    const seg = 8.0;
    const gap = 6.0;
    final circumference = 2 * math.pi * r;
    final steps = (circumference / (seg + gap)).floor();
    for (var i = 0; i < steps; i++) {
      final start = (i * (seg + gap)) / r;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        seg / r,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.color != color || old.dashed != dashed;
}

class _CenterDisc extends StatelessWidget {
  const _CenterDisc({
    required this.count,
    required this.target,
    required this.caption,
    required this.scale,
    required this.designNumber,
    required this.designLogo,
    required this.pulse,
    required this.reduceMotion,
  });

  final int count;
  final int? target;
  final String? caption;
  final double scale;
  final double designNumber;
  final double designLogo;
  final AnimationController pulse;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // T11 · sayaç rakamı 52 px'i aşmaz, merkez diske sığmalı.
    final numberSize = (designNumber * scale).clamp(24.0, 52.0);
    final logoSize = (designLogo * scale).clamp(30.0, 62.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.glassFill,
        border: Border.all(color: t.glassBorder, width: 1),
        shape: BoxShape.circle,
      ),
      // Metin ölçeği büyüdüğünde disk içeriği taşmasın; küçülerek sığar.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: pulse,
              builder: (context, child) {
                if (reduceMotion) return child!;
                // scale(1 → 1.07 → 1), 160 ms, cubic-bezier(.2,.8,.2,1)
                final v = Curves.easeOutCubic.transform(pulse.value);
                final s = 1 + 0.07 * math.sin(v * math.pi);
                return Transform.scale(scale: s, child: child);
              },
              child: LogoMark(size: logoSize),
            ),
            SizedBox(height: 5 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$count',
                  style: context.type
                      .counter(t.textPrimary, size: numberSize)
                      .copyWith(letterSpacing: numberSize * -0.03),
                ),
                // Serbest tarafta hedef payı yoktur.
                if (target != null) ...[
                  const SizedBox(width: 5),
                  Text(
                    '/ $target',
                    style: context.type
                        .listRow(t.textSecondary, size: 18 * scale)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
            if (caption != null) ...[
              SizedBox(height: 5 * scale),
              Text(
                caption!,
                textAlign: TextAlign.center,
                style: context.type
                    .meta(t.textTertiary, size: 10.5)
                    .copyWith(letterSpacing: 10.5 * 0.1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
