import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';
import 'metrics.dart';

enum ScreenBottomPad { standard, counter, onboarding }

/// Ekran kökü · `padding: 58px 0 22px`.
///
/// Yatay kenar boşlukları çağıran tarafından verilir (kart 18 · metin 20 ·
/// tam genişlik liste 14). Yükseklikler esner; içerik daima kaydırılabilir.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    required this.child,
    this.bottomPad = ScreenBottomPad.standard,
    this.scrollable = true,
    this.bottomBar,
    super.key,
  });

  final Widget child;
  final ScreenBottomPad bottomPad;
  final bool scrollable;

  /// Sabit alt yüzey — yalnızca `Features.audio` açıkken doldurulur.
  final Widget? bottomBar;

  double get _bottom => switch (bottomPad) {
    ScreenBottomPad.standard => KunMetrics.screenBottom,
    ScreenBottomPad.counter => KunMetrics.screenBottomCounter,
    ScreenBottomPad.onboarding => KunMetrics.screenBottomOnboarding,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final safeTop = media.padding.top;
    final topPad = safeTop > KunMetrics.screenTop
        ? safeTop
        : KunMetrics.screenTop;

    Widget content = Padding(
      padding: EdgeInsets.only(
        top: topPad,
        bottom: _bottom + media.padding.bottom,
      ),
      child: child,
    );

    if (scrollable) {
      content = SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: content,
      );
    }

    return ColoredBox(
      color: t.surface,
      child: Column(
        children: [
          Expanded(child: content),
          ?bottomBar,
        ],
      ),
    );
  }
}
