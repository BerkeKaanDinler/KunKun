import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens_ext.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/usecases/streak.dart';
import '../../ui/buttons.dart';
import '../../ui/glass.dart';
import '../../ui/metrics.dart';
import '../../ui/icons.dart';
import '../../ui/nav_bar.dart';
import '../../ui/tasbih_ring.dart';
import 'dhikr_session.dart';

/// Z2 / Z3 / Z4 / Z6 · Sayaç ekranı.
///
/// Tek ekran dört durumu karşılar:
/// · **Z2** hazır sayaç — hedef 33, 306 px halka
/// · **Z3** hedef tamamlandı — 266 px halka, üç kolonlu şerit, sonraki adım
/// · **Z4** set akışı — 4 sütunlu adımlayıcı, 274 px halka
/// · **Z6** serbest sayaç — hedef yok, kesikli dış çember, tur künyesi
class DhikrCounterScreen extends ConsumerWidget {
  const DhikrCounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final media = MediaQuery.of(context);
    final s = ref.watch(dhikrSessionProvider);
    final session = ref.read(dhikrSessionProvider.notifier);

    final ringSize = s.completed ? 266.0 : (s.isPreset ? 274.0 : 306.0);

    return ColoredBox(
      color: t.surface,
      child: Padding(
        padding: EdgeInsets.only(
          top: media.padding.top > KunMetrics.screenTop
              ? media.padding.top
              : KunMetrics.screenTop,
          bottom: KunMetrics.screenBottomCounter + media.padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackRow(
              onBack: () => context.pop(),
              label: '',
              trailing: Text(
                s.completed ? 'TAMAMLANDI' : s.badge,
                style: context.type
                    .meta(s.isPreset ? t.textTertiary : t.accent, size: 11.5)
                    .copyWith(letterSpacing: 11.5 * 0.1),
              ),
            ),

            // Hazır set akışında 4 sütunlu adımlayıcı (Z4).
            if (s.isPreset && s.presets.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KunMetrics.gutterCard,
                  12,
                  KunMetrics.gutterCard,
                  0,
                ),
                child: _Stepper(state: s),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
              child: Column(
                children: [
                  if (s.textAr != null)
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        s.textAr!,
                        textAlign: TextAlign.center,
                        style: context.type.arabicText(
                          t.textPrimary,
                          size: s.isPreset ? 34 : 30,
                        ),
                      ),
                    ),
                  if (s.meaning != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      s.meaning!,
                      textAlign: TextAlign.center,
                      style: context.type
                          .body(t.textSecondary, size: 14)
                          .copyWith(height: 1.5),
                    ),
                  ] else if (!s.isPreset) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Kendi zikrin · sınırsız sayar',
                      textAlign: TextAlign.center,
                      style: context.type.body(t.textSecondary, size: 14),
                    ),
                  ],
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: TasbihRing(
                  count: s.count,
                  target: s.target,
                  designSize: ringSize,
                  dashedOuter: !s.isPreset,
                  caption: s.completed
                      ? 'TAMAMLANDI'
                      : s.isPreset
                      ? '${s.title.toUpperCase()} · ${s.target ?? 0}'
                      : '${s.round}. TUR · SINIRSIZ',
                  onTap: s.completed ? null : () => session.tick(),
                ),
              ),
            ),

            if (s.completed)
              _CompletedBlock(state: s)
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 6, 30, 0),
                child: Text(
                  s.isPreset
                      ? 'Halkaya dokunarak say · her dokunuşta hafif titreşim'
                      : 'Sınırsız sayar; halka her 33\'te başa döner, '
                            'sıfırlamak sana bağlı',
                  textAlign: TextAlign.center,
                  style: context.type.caption(t.textTertiary),
                ),
              ),
              // Z4 · sıradaki adımı önceden gösteren cam satır.
              if (s.isPreset && !s.isLastStep)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KunMetrics.gutterCard,
                    12,
                    KunMetrics.gutterCard,
                    0,
                  ),
                  child: _NextStepRow(state: s),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KunMetrics.gutterCard,
                  16,
                  KunMetrics.gutterCard,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SmallButton(
                        label: 'Sıfırla',
                        onTap: session.reset,
                      ),
                    ),
                    const SizedBox(width: 9),
                    if (s.isPreset && !s.isLastStep)
                      Expanded(
                        child: _SmallButton(
                          label: 'Sonraki',
                          onTap: session.nextStep,
                        ),
                      )
                    else
                      Expanded(
                        child: _SmallButton(
                          label: s.isPreset ? 'Seti bitir' : 'Bitir',
                          onTap: () => context.pop(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Z4 · 4 sütunlu adımlayıcı — tamamlanan `--accent` %55, aktif tam opak,
/// bekleyen `--track`.
class _Stepper extends StatelessWidget {
  const _Stepper({required this.state});

  final DhikrSessionState state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        for (var i = 0; i < state.presets.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < state.stepIndex
                        ? t.accent.withValues(alpha: 0.55)
                        : i == state.stepIndex
                        ? t.accent
                        : t.track,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                // Ad ve sayı alt alta: tek satırda dört sütuna sığmıyor,
                // metin ölçeği büyüdüğünde hiç sığmıyordu.
                Text(
                  state.presets[i].nameTr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type
                      .meta(
                        i == state.stepIndex ? t.textPrimary : t.textTertiary,
                        size: 10,
                        weight: i == state.stepIndex
                            ? FontWeight.w700
                            : FontWeight.w400,
                      )
                      .copyWith(letterSpacing: 0),
                ),
                Text(
                  '${state.presets[i].targetCount}',
                  style: context.type
                      .meta(
                        i == state.stepIndex ? t.accent : t.textTertiary,
                        size: 10,
                        weight: FontWeight.w700,
                      )
                      .copyWith(letterSpacing: 0),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Z3 · hedef tamamlandı bloğu.
class _CompletedBlock extends ConsumerWidget {
  const _CompletedBlock({required this.state});

  final DhikrSessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final stats = ref.watch(dailyStatsProvider).value ?? const [];
    final today = StreakCalculator.dayKey(DateTime.now());
    final todayTotal = stats
        .where((e) => e.day == today)
        .fold<int>(0, (a, b) => a + b.totalCount);
    final total = stats.fold<int>(0, (a, b) => a + b.totalCount);
    final streak = StreakCalculator.compute(stats, now: DateTime.now());
    final session = ref.read(dhikrSessionProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              Text(
                'Hedef tamamlandı',
                textAlign: TextAlign.center,
                style: context.type
                    .sectionTitle(t.textPrimary)
                    .copyWith(letterSpacing: 27 * -0.02),
              ),
              const SizedBox(height: 9),
              Text(
                '${state.title} · ${state.target} · '
                '${_stepLabel(state.stepIndex, state.presets.length)}',
                textAlign: TextAlign.center,
                style: context.type
                    .body(t.textSecondary, size: 15)
                    .copyWith(height: 1.55),
              ),
            ],
          ),
        ),
        const SizedBox(height: KunMetrics.v16),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KunMetrics.gutterCard,
          ),
          child: GlassSurface.fixed(
            radius: t.radiusMd,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(value: '$todayTotal', label: 'bugün'),
                _Divider(),
                _Stat(value: '${streak.current}', label: 'gün seri'),
                _Divider(),
                _Stat(value: '$total', label: 'toplam', accent: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: KunMetrics.v20),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KunMetrics.gutterCard,
          ),
          child: Column(
            children: [
              if (!state.isLastStep)
                PrimaryButton(
                  label:
                      'Sonraki adım · '
                      '${state.presets[state.stepIndex + 1].nameTr} '
                      '${state.presets[state.stepIndex + 1].targetCount}',
                  onPressed: session.nextStep,
                )
              else
                PrimaryButton(
                  label: 'Seti bitir',
                  onPressed: () => context.pop(),
                ),
              const SizedBox(height: 9),
              SecondaryButton(
                label: 'Sıfırla ve baştan başla',
                onPressed: () {
                  session.startPreset(state.presets);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.accent = false});

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.type.cardTitle(
            accent ? t.accent : t.textPrimary,
            size: 19,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: context.type.caption(t.textSecondary, size: 11)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 26, color: context.tokens.glassBorder);
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: GlassSurface(
        radius: t.radiusLg > 8 ? 16 : t.radiusSm,
        minHeight: KunMetrics.secondaryButtonHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.type
              .listRow(t.textPrimary, size: 14.5)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// "Setin ilk adımı" / "2. adım" / "Setin son adımı"
String _stepLabel(int index, int total) {
  if (index == 0) return 'Setin ilk adımı';
  if (index == total - 1) return 'Setin son adımı';
  return '${index + 1}. adım';
}

/// Z4 · "SONRAKİ · Allahu Ekber · 33 / otomatik" cam satırı.
class _NextStepRow extends StatelessWidget {
  const _NextStepRow({required this.state});

  final DhikrSessionState state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final next = state.presets[state.stepIndex + 1];
    return GlassSurface.fixed(
      radius: t.radiusLg > 8 ? 18 : t.radiusMd,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.glassFill,
              border: Border.all(color: t.glassBorder, width: 1),
              shape: BoxShape.circle,
            ),
            child: Icon(KunIcons.skipNext, size: 16, color: t.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SONRAKİ',
                  style: context.type
                      .meta(t.textTertiary, size: 11, weight: FontWeight.w600)
                      .copyWith(letterSpacing: 11 * 0.12),
                ),
                const SizedBox(height: 3),
                Text(
                  '${next.nameTr} · ${next.targetCount}',
                  style: context.type.body(t.textPrimary, size: 15.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'otomatik',
            style: context.type.caption(t.textSecondary, size: 13),
          ),
        ],
      ),
    );
  }
}
