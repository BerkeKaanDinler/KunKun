import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';
import '../core/theme/tokens_ext.dart';
import '../ui/atoms.dart';
import '../ui/glass.dart';
import '../ui/metrics.dart';
import '../ui/surfaces.dart';

/// Mimari brief · "İlk hafta ölçülmeli: gerçek bir orta segment Android
/// cihazda keşif ekranı **40 cam kartla** test edilir."
///
/// Üç mod yan yana ölçülür:
/// · **cam (sabit)** — 40 kartın hepsi `BackdropFilter` (kasıtlı en kötü hâl)
/// · **düz** — teslim edilen strateji: liste kartları yarı saydam düz renk
/// · **opak** — Kâğıt indeks kod yolu
///
/// Ölçülen: raster süresi (GPU) ve build+layout süresi (UI), son 120 kare.
class BlurBenchScreen extends ConsumerStatefulWidget {
  const BlurBenchScreen({super.key});

  @override
  ConsumerState<BlurBenchScreen> createState() => _BlurBenchScreenState();
}

enum _BenchMode { glassEveryCard, flatCards, opaque }

class _BlurBenchScreenState extends ConsumerState<BlurBenchScreen> {
  static const int cardCount = 40;

  _BenchMode _mode = _BenchMode.glassEveryCard;
  final List<double> _raster = [];
  final List<double> _ui = [];
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _uiTimer?.cancel();
    super.dispose();
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      _raster.add(t.rasterDuration.inMicroseconds / 1000);
      _ui.add(t.buildDuration.inMicroseconds / 1000);
    }
    while (_raster.length > 120) {
      _raster.removeAt(0);
      _ui.removeAt(0);
    }
    if (mounted) setState(() {});
  }

  void _reset() {
    _raster.clear();
    _ui.clear();
    setState(() {});
  }

  static double _p(List<double> xs, double q) {
    if (xs.isEmpty) return 0;
    final s = [...xs]..sort();
    return s[((s.length - 1) * q).round()];
  }

  double get _worstBudget => 16.67;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rasterP50 = _p(_raster, .5);
    final rasterP90 = _p(_raster, .9);
    final uiP90 = _p(_ui, .9);
    final bad = _raster.where((x) => x > _worstBudget).length;
    final badPct = _raster.isEmpty ? 0 : (bad * 100 / _raster.length).round();

    return ColoredBox(
      color: t.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KunMetrics.gutterText,
                KunMetrics.v12,
                KunMetrics.gutterText,
                KunMetrics.v12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blur bench · $cardCount kart',
                    style: context.type.cardTitle(t.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'raster p50 ${rasterP50.toStringAsFixed(1)} ms · '
                    'p90 ${rasterP90.toStringAsFixed(1)} ms · '
                    'ui p90 ${uiP90.toStringAsFixed(1)} ms · '
                    'bütçe aşan %$badPct',
                    style: context.type.meta(
                      rasterP90 > _worstBudget ? t.danger : t.accent,
                      size: 11.5,
                    ),
                  ),
                  const SizedBox(height: KunMetrics.v12),
                  Row(
                    children: [
                      for (final m in _BenchMode.values) ...[
                        KunChip(
                          label: switch (m) {
                            _BenchMode.glassEveryCard => 'cam (her kart)',
                            _BenchMode.flatCards => 'düz (teslim)',
                            _BenchMode.opaque => 'opak',
                          },
                          selected: _mode == m,
                          onTap: () {
                            setState(() => _mode = m);
                            _reset();
                          },
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: KunMetrics.gutterCard,
                  vertical: KunMetrics.v9,
                ),
                itemCount: cardCount,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: KunMetrics.v12),
                  child: _BenchCard(mode: _mode, index: i),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenchCard extends StatelessWidget {
  const _BenchCard({required this.mode, required this.index});

  final _BenchMode mode;
  final int index;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final content = Padding(
      padding: const EdgeInsets.all(KunMetrics.v16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori ${index + 1}',
            style: context.type.listRow(t.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Ölçüm kartı · yer tutucu',
            style: context.type.caption(t.textSecondary),
          ),
        ],
      ),
    );

    return switch (mode) {
      // Kasıtlı en kötü hâl: kaydırılan listede her kart ayrı blur katmanı.
      _BenchMode.glassEveryCard => GlassSurface.fixed(
        layer: GlassLayer.base,
        child: content,
      ),
      // Teslim edilen strateji.
      _BenchMode.flatCards => GlassSurface(child: content),
      _BenchMode.opaque => OpaqueCard(radius: t.radiusMd, child: content),
    };
  }
}
