import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';
import 'metrics.dart';

/// Tasarımda sabit yükseklikli, `flex:1` boşlukla dengelenen ekranlar için.
///
/// Ekran yüksekliğe sığdığında tasarımdaki gibi davranır (boşluk esner);
/// içerik taştığında (küçük cihaz, %135 metin ölçeği) kaydırılabilir olur.
/// Brief'in "yükseklikler esner, ekranlar kaydırılabilir" kuralı böyle
/// karşılanır — sabit `overflow:hidden` kopyalanmaz.
class FlexScreen extends StatelessWidget {
  const FlexScreen({
    required this.children,
    this.bottomPad = KunMetrics.screenBottom,
    super.key,
  });

  final List<Widget> children;
  final double bottomPad;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final top = media.padding.top > KunMetrics.screenTop
        ? media.padding.top
        : KunMetrics.screenTop;

    return ColoredBox(
      color: t.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: top,
                    bottom: bottomPad + media.padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
