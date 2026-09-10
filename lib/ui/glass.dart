import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';
import '../core/theme/tokens_ext.dart';

/// Cam yüzey kalitesi.
enum GlassMode {
  /// Kare süresi izlenir; kötüleşirse [off]'a düşülür.
  auto,

  /// Blur her zaman açık (sabit yüzeylerde).
  full,

  /// Blur hiç çizilmez — yarı saydam düz renk. Kâğıt indeks'in kod yolu.
  off,
}

/// Mimari brief · "Cam efekti Flutter'da pahalıdır — en önemli uyarı".
///
/// Uygulanan strateji:
/// · blur **yalnızca sabit yüzeylerde** (alt çubuk, hero, alt sheet)
/// · kaydırılan liste kartları yarı saydam **düz renk** — blur yok
/// · her blur katmanı [RepaintBoundary] ile izole
/// · cihaz sınıfına göre düşürme: kötü kare süresinde blur kapanır
///
/// Ölçüm kötü çıkarsa **çağrı yerleri değil, yalnızca bu karar** değişir.
class GlassPolicy extends Notifier<GlassMode> {
  static const int _windowSize = 120;
  static const double _rasterBudgetMs = 14.0;
  static const double _badFrameRatio = 0.2;

  final List<double> _raster = <double>[];
  bool _downgraded = false;
  bool _listening = false;

  @override
  GlassMode build() {
    ref.onDispose(_stopListening);
    return GlassMode.auto;
  }

  void set(GlassMode mode) {
    _downgraded = false;
    _raster.clear();
    state = mode;
    if (mode == GlassMode.auto) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  /// Otomatik düşürmeyi çalıştırır. `main` içinde bir kez çağrılır.
  void startAutoProbe() {
    if (state == GlassMode.auto) _startListening();
  }

  void _startListening() {
    if (_listening) return;
    _listening = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void _stopListening() {
    if (!_listening) return;
    _listening = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
  }

  void _onTimings(List<FrameTiming> timings) {
    if (_downgraded || state != GlassMode.auto) return;
    for (final t in timings) {
      _raster.add(t.rasterDuration.inMicroseconds / 1000.0);
    }
    if (_raster.length < _windowSize) return;

    final bad = _raster.where((ms) => ms > _rasterBudgetMs).length;
    final ratio = bad / _raster.length;
    _raster.clear();

    if (ratio > _badFrameRatio) {
      // Histerezis: oturum içinde geri yükseltme yok, titreşim olmasın.
      _downgraded = true;
      _stopListening();
      state = GlassMode.off;
      debugPrint(
        '[KUN] Cam düşürüldü — kötü kare oranı %${(ratio * 100).round()}',
      );
    }
  }

  /// Bench ekranı için ham veri.
  bool get isDowngraded => _downgraded;
}

final glassPolicyProvider = NotifierProvider<GlassPolicy, GlassMode>(
  GlassPolicy.new,
);

/// Cam yüzey.
///
/// Varsayılan yapıcı **blur çizmez** — kaydırılan liste kartları içindir.
/// [GlassSurface.fixed] yalnızca sabit yüzeyler için blur çizer.
class GlassSurface extends ConsumerWidget {
  const GlassSurface({
    required this.child,
    this.layer = GlassLayer.base,
    this.radius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.minHeight,
    this.alignment,
    super.key,
  }) : _blurEligible = false;

  /// Sabit yüzey — alt çalar çubuğu, hero, alt sheet.
  /// Kaydırılan liste içinde **kullanılmaz**.
  const GlassSurface.fixed({
    required this.child,
    this.layer = GlassLayer.base,
    this.radius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.minHeight,
    this.alignment,
    super.key,
  }) : _blurEligible = true;

  final Widget child;
  final GlassLayer layer;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  /// Dökümdeki `min-height` — içerik büyürse yüzey uzar, taşmaz.
  final double? minHeight;
  final AlignmentGeometry? alignment;
  final bool _blurEligible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final mode = ref.watch(glassPolicyProvider);
    final r = radius ?? t.radiusMd;

    // Blur üç koşulun hepsi sağlanırsa çizilir.
    final blurPx = layer.resolve(t);
    final blur = _blurEligible && blurPx > 0 && mode != GlassMode.off;

    final border = BoxDecoration(
      color: t.glassFill,
      border: Border.all(color: t.glassBorder, width: 1),
      borderRadius: BorderRadius.circular(r),
      // Gölge blur'a değil temaya aittir — açık cam temada opak yolda da kalır.
      boxShadow: context.shadows.glass,
    );

    Widget content = Container(
      width: width,
      height: height,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight!),
      alignment: alignment,
      padding: padding,
      decoration: border,
      child: child,
    );

    if (blur) {
      final sigma = blurPx / 2; // CSS blur(px) ≈ 2σ
      content = RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: content,
          ),
        ),
      );
    }

    return margin == null ? content : Padding(padding: margin!, child: content);
  }
}
