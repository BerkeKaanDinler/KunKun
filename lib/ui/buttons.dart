import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';
import 'glass.dart';
import 'metrics.dart';

/// Birincil buton / aksan kart. Aksan zemin üzerine **daima** `onAccent`.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.fullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = onPressed != null;
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          width: fullWidth ? double.infinity : null,
          constraints: const BoxConstraints(
            minHeight: KunMetrics.primaryButtonHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: KunMetrics.v20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: t.accent,
            borderRadius: BorderRadius.circular(t.radiusSm),
            boxShadow: enabled ? context.shadows.primaryButton : const [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.type.cardTitle(t.onAccent, size: 17),
          ),
        ),
      ),
    );
  }
}

/// İkincil buton — cam kart değerleri, min 52 px.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    this.onPressed,
    this.fullWidth = true,
    this.labelColor,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;

  /// T6 · boş durum aksiyonunda `--accent`, hata onarımında `--text-primary`.
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = onPressed != null;
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: GlassSurface(
          radius: t.radiusSm,
          width: fullWidth ? double.infinity : null,
          // Döküm `min-height: 52px` der — sabit yükseklik değil.
          // Sabitlenirse büyük metin ölçeğinde etiket taşar.
          minHeight: KunMetrics.secondaryButtonHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: KunMetrics.v20,
            vertical: KunMetrics.v12,
          ),
          child: Text(
            textAlign: TextAlign.center,
            label,
            style: context.type.listRow(labelColor ?? t.textPrimary, size: 16),
          ),
        ),
      ),
    );
  }
}

/// 44 × 44 dokunma hedefli ikon butonu — **bu ölçü sabittir**.
class KunIconButton extends StatelessWidget {
  const KunIconButton({
    required this.icon,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: KunMetrics.minTouch,
          height: KunMetrics.minTouch,
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: onPressed == null ? t.textTertiary : t.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
