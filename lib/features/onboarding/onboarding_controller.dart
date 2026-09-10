import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_controller.dart';

/// Giriş akışının kalıcı durumu — Ü15 · JSON snapshot.
///
/// Gizlilik: isim **yalnızca cihazda** saklanır. Hiçbir yere gönderilmez,
/// loglanmaz. İsim ekranındaki "yalnızca telefonunda saklanır" cümlesi
/// bu yüzden zorunludur (mimari brief · Gizlilik).
class OnboardingState {
  const OnboardingState({required this.completed, this.name});

  final bool completed;

  /// Kullanıcı atladıysa null.
  final String? name;

  OnboardingState copyWith({
    bool? completed,
    String? name,
    bool clearName = false,
  }) => OnboardingState(
    completed: completed ?? this.completed,
    name: clearName ? null : (name ?? this.name),
  );
}

const String kOnboardingDoneKey = 'onboarding_done';
const String kUserNameKey = 'user_name';

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final store = ref.read(jsonStoreProvider);
    return OnboardingState(
      completed: store.read<bool>(kOnboardingDoneKey) ?? false,
      name: store.read<String>(kUserNameKey),
    );
  }

  /// "Başla" — isim verildiyse kaydedilir.
  void finish({String? name}) {
    final trimmed = name?.trim();
    final clean = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    final store = ref.read(jsonStoreProvider);
    store.write(kOnboardingDoneKey, true);
    store.write(kUserNameKey, clean);
    state = OnboardingState(completed: true, name: clean);
  }

  /// "Şimdilik atla" — isim yazılmaz.
  void skip() => finish();

  /// Geliştirici bölümü: akışı baştan gezebilmek için.
  void reset() {
    final store = ref.read(jsonStoreProvider);
    store.write(kOnboardingDoneKey, null);
    store.write(kUserNameKey, null);
    state = const OnboardingState(completed: false);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
