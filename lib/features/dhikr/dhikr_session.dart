import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ports/port_providers.dart';
import '../../data/repositories/repository_providers.dart';
import '../../domain/models/models.dart';

/// Çalışan zikir oturumu.
///
/// **Hazır taraf:** sayaç hedefte durur, tamamlandı durumuna geçer, sıradaki
/// adıma devreder. **Serbest taraf:** hedef yok, sayaç durmaz, halka her 33'te
/// başa döner (halka `count % 33` ile çizer, sayı büyümeye devam eder).
class DhikrSessionState {
  const DhikrSessionState({
    required this.isPreset,
    required this.count,
    this.presets = const [],
    this.stepIndex = 0,
    this.custom,
    this.completed = false,
  });

  final bool isPreset;
  final int count;

  /// Hazır set — dört adım, sabit.
  final List<DhikrPreset> presets;
  final int stepIndex;

  /// Serbest zikir.
  final CustomDhikr? custom;

  /// Hedefe ulaşıldı; kullanıcı "sonraki adım"ı bekliyor.
  final bool completed;

  DhikrPreset? get step =>
      isPreset && stepIndex < presets.length ? presets[stepIndex] : null;

  /// Serbest tarafta null — hedef yok.
  int? get target => isPreset ? step?.targetCount : null;

  String get title => isPreset ? (step?.nameTr ?? '') : (custom?.name ?? '');
  String? get textAr => isPreset ? step?.textAr : custom?.textAr;
  String? get meaning => isPreset ? step?.meaning : custom?.meaning;

  /// `HAZIR · 1/4 · HEDEF 33` veya `SERBEST · SINIRSIZ`
  String get badge => isPreset
      ? 'HAZIR · ${stepIndex + 1}/${presets.length} · HEDEF ${target ?? 0}'
      : 'SERBEST · SINIRSIZ';

  /// Serbest sayaçta tur numarası.
  int get round => count ~/ 33 + 1;

  bool get isLastStep => stepIndex >= presets.length - 1;

  DhikrSessionState copyWith({
    int? count,
    int? stepIndex,
    bool? completed,
    CustomDhikr? custom,
    List<DhikrPreset>? presets,
  }) => DhikrSessionState(
    isPreset: isPreset,
    count: count ?? this.count,
    presets: presets ?? this.presets,
    stepIndex: stepIndex ?? this.stepIndex,
    custom: custom ?? this.custom,
    completed: completed ?? this.completed,
  );
}

class DhikrSession extends Notifier<DhikrSessionState> {
  @override
  DhikrSessionState build() =>
      const DhikrSessionState(isPreset: true, count: 0);

  void startPreset(List<DhikrPreset> presets, {int stepIndex = 0}) {
    state = DhikrSessionState(
      isPreset: true,
      count: 0,
      presets: presets,
      stepIndex: stepIndex,
    );
  }

  void startCustom(CustomDhikr dhikr) {
    state = DhikrSessionState(isPreset: false, count: 0, custom: dhikr);
  }

  /// Bir sayım. Hedefe ulaşıldığında hazır tarafta **durur**.
  Future<void> tick() async {
    if (state.completed) return;
    final haptics = ref.read(hapticsPortProvider);
    final next = state.count + 1;
    final target = state.target;

    if (target != null && next >= target) {
      state = state.copyWith(count: target, completed: true);
      await haptics.success();
    } else {
      state = state.copyWith(count: next);
      // Serbest tarafta her 33'te çift titreşim.
      if (!state.isPreset &&
          next % 33 == 0 &&
          (state.custom?.vibrateEvery33 ?? true)) {
        await haptics.success();
      } else {
        await haptics.tick();
      }
    }

    await ref
        .read(dhikrRepositoryProvider)
        .recordCount(isPreset: state.isPreset, delta: 1);
    ref.invalidate(dailyStatsProvider);
  }

  void reset() => state = state.copyWith(count: 0, completed: false);

  /// Sıradaki adıma devret. Son adımdaysa set biter.
  void nextStep() {
    if (!state.isPreset || state.isLastStep) return;
    state = state.copyWith(
      stepIndex: state.stepIndex + 1,
      count: 0,
      completed: false,
    );
  }
}

final dhikrSessionProvider = NotifierProvider<DhikrSession, DhikrSessionState>(
  DhikrSession.new,
);
