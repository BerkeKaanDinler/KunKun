import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';
import 'metrics.dart';

/// Opak liste kartı / panel. Liste kartı **her temada opaktır** — blur çizmez.
class OpaqueCard extends StatelessWidget {
  const OpaqueCard({
    required this.child,
    this.radius,
    this.padding,
    this.sunken = false,
    super.key,
  });

  final Widget child;
  final double? radius;
  final EdgeInsetsGeometry? padding;

  /// Girinti, arama alanı, boş durum yüzeyi.
  final bool sunken;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: sunken ? t.surfaceSunken : t.surfaceRaised,
        border: Border.all(color: t.border, width: 1),
        borderRadius: BorderRadius.circular(radius ?? t.radiusLg),
      ),
      child: child,
    );
  }
}

/// Satırları ayraçla bölen opak kart. **Son satırda ayraç yok.**
class DividedCard extends StatelessWidget {
  const DividedCard({required this.children, this.radius, super.key});

  final List<Widget> children;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Container(height: 1, color: t.divider));
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? t.radiusLg),
      child: OpaqueCard(
        radius: radius,
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}

/// Liste satırı · minimum 60 px, dokunma hedefi 44 × 44 korunur.
class KunListRow extends StatelessWidget {
  const KunListRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: KunMetrics.listRowMinHeight),
      child: Padding(
        padding:
            padding ??
            const EdgeInsets.symmetric(
              horizontal: KunMetrics.gutterCard,
              vertical: KunMetrics.v12,
            ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: KunMetrics.v12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    subtitle!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: KunMetrics.v12),
              trailing!,
            ],
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}
