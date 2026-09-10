import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';

/// Tema varyantlı yuvarlak logo — `logo/yuvarlak/*.png`, tasarım teslimatından.
///
/// T2 kapandı: vektör kaynağı yok, PNG ile ilerleniyor (tasarım cevabı).
/// Kaynak 512 × 512; en büyük kullanım hero'da 188 pt.
class LogoMark extends StatelessWidget {
  const LogoMark({required this.size, this.opacity = 1, super.key});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      context.kunTheme.logoAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
    return opacity == 1 ? image : Opacity(opacity: opacity, child: image);
  }
}
