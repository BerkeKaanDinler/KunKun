import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';
import 'atoms.dart';
import 'icons.dart';
import 'metrics.dart';
import 'surfaces.dart';

/// Ayarlar satırı — sol etiket + alt açıklama, sağda değer / switch / ok.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.label,
    this.description,
    this.value,
    this.switchValue,
    this.onSwitch,
    this.onTap,
    this.danger = false,
    this.enabled = true,
    super.key,
  });

  final String label;
  final String? description;

  /// Sağda gösterilen metin değeri.
  final String? value;

  final bool? switchValue;
  final ValueChanged<bool>? onSwitch;
  final VoidCallback? onTap;

  /// Silme gibi geri alınamaz işlemler — etiket `--danger`.
  final bool danger;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final row = Opacity(
      opacity: enabled ? 1 : 0.45,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: KunMetrics.listRowMinHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: context.type.body(
                        danger ? t.danger : t.textPrimary,
                        size: 16,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        description!,
                        style: context.type
                            .caption(t.textTertiary, size: 12.5)
                            .copyWith(height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (value != null)
                Text(
                  value!,
                  style: context.type.body(t.textSecondary, size: 15),
                ),
              if (switchValue != null)
                KunSwitch(
                  value: switchValue!,
                  onChanged: enabled ? onSwitch : null,
                )
              else if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(KunIcons.chevron, size: 16, color: t.textTertiary),
              ],
            ],
          ),
        ),
      ),
    );
    if (onTap == null || !enabled) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}

/// Ayarlar grubu — 11 px `.12em` büyük harf künye + opak kart.
/// **Boş grup çizilmez** (mimari brief: "boş grup bırakılmaz").
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.rows,
    this.footnote,
    super.key,
  });

  final String title;
  final List<Widget> rows;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: KunMetrics.v20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title),
          DividedCard(children: rows),
          if (footnote != null) ...[
            const SizedBox(height: KunMetrics.v9),
            Text(
              footnote!,
              style: context.type
                  .caption(t.textTertiary, size: 12)
                  .copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}
