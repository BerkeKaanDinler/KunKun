import 'package:flutter/widgets.dart';

import '../core/theme/tokens_ext.dart';
import 'metrics.dart';

/// Rozet — hedef sayısı, ∞, sure künyesi. JetBrains Mono 11.5.
class KunBadge extends StatelessWidget {
  const KunBadge(this.text, {this.accented = false, super.key}) : _soft = false;

  /// T10 · `--accent-soft` zemin, üstüne yazı **`--accent`** olur
  /// (`--on-accent` değil — yumuşak zemin şeffaf bir aksan tintidir).
  /// Yeri: Kaydedilenler sekme sayacı, kategori ayet sayısı.
  const KunBadge.soft(this.text, {super.key}) : accented = true, _soft = true;

  final String text;

  /// Serbest zikirdeki `∞` gibi aksan renkli kullanımlar.
  final bool accented;

  final bool _soft;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _soft ? t.accentSoft : t.glassFill,
        border: Border.all(color: t.glassBorder, width: 1),
        borderRadius: BorderRadius.circular(t.radiusLg > 8 ? 8 : 3),
      ),
      child: Text(
        text,
        style: context.type.meta(
          accented ? t.accent : t.textSecondary,
          size: 11.5,
        ),
      ),
    );
  }
}

/// Bölüm künyesi · 11 px / .12em büyük harf.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {this.trailing, super.key});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: KunMetrics.v9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: context.type.meta(t.textTertiary),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Sekme çubuğu — Hazır zikirler | Serbest, Ayetler | Notlar.
///
/// **Tek sekme kalırsa çubuk hiç çizilmez** (mimari brief · kapalı özellikler).
class KunTabs extends StatelessWidget {
  const KunTabs({
    required this.labels,
    required this.index,
    required this.onChanged,
    super.key,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (labels.length < 2) return const SizedBox.shrink();
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.accentSoft,
        borderRadius: BorderRadius.circular(t.radiusLg > 8 ? 12 : 4),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: KunMetrics.minTouch - 6,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // Cam temalarda seçim yükseltilmiş yüzeyle anlatılır.
                    // Kâğıt indeks'te yükseltme ve gölge yok — seçim aksanla
                    // olur (md/05: aktif sekme `--accent` + `--on-accent`).
                    color: i == index
                        ? (t.isGlass ? t.surfaceRaised : t.accent)
                        : null,
                    borderRadius: BorderRadius.circular(
                      t.radiusLg > 8 ? 10 : 3,
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: context.type
                        .listRow(
                          i == index
                              ? (t.isGlass ? t.textPrimary : t.onAccent)
                              : t.textSecondary,
                          size: 15,
                        )
                        .copyWith(
                          fontWeight: i == index
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Chip — Keşif eksen seçici (T8: chip'ler eksen seçicidir).
class KunChip extends StatelessWidget {
  const KunChip({
    required this.label,
    required this.selected,
    this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: KunMetrics.minTouch - 8),
        padding: const EdgeInsets.symmetric(horizontal: KunMetrics.v14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? t.accent : t.accentSoft,
          borderRadius: BorderRadius.circular(t.radiusLg > 8 ? 10 : 3),
        ),
        child: Text(
          label,
          style: context.type.listRow(
            selected ? t.onAccent : t.textSecondary,
            size: 15,
          ),
        ),
      ),
    );
  }
}

/// Switch · 51 × 31, topuz 25.
class KunSwitch extends StatelessWidget {
  const KunSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = onChanged != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged!(!value) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: SizedBox(
          width: KunMetrics.minTouch,
          height: KunMetrics.minTouch,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: 51,
              height: 31,
              decoration: BoxDecoration(
                color: value ? t.accent : t.track,
                borderRadius: BorderRadius.circular(999),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
