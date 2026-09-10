// Dış dünyaya bağlanan her şey bir arayüz arkasındadır.
// V1'de çoğu boş (NoOp) implementasyondur.

/// Ses. Formatı belli değil: TTS · gömülü dosya · indirilen paket.
/// Üçü de bu arayüzü uygular. V1 → NoOp, kontroller pasif.
abstract interface class AudioPort {
  bool get isAvailable;
  Stream<AudioState> get state;
  Future<void> play(String verseId);
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
}

class AudioState {
  const AudioState({
    this.playing = false,
    this.verseId,
    this.position = Duration.zero,
    this.duration,
  });
  final bool playing;
  final String? verseId;
  final Duration position;
  final Duration? duration;
}

/// Reklam. V1 → NoOp, hiç çağrılmaz. Sonra AdMob adaptörü.
abstract interface class AdsPort {
  bool get isEnabled;
  Future<void> preload();
}

/// Paylaşım · RepaintBoundary → PNG → share_plus. Aşama 3.
abstract interface class SharePort {
  bool get isAvailable;
  Future<void> shareVerseImage({
    required String verseId,
    required String translatorCredit,
  });
}

/// Widget köprüsü · home_widget. Aşama 3'te native.
abstract interface class WidgetPort {
  bool get isAvailable;
  Future<void> pushDailyVerse({
    required String verseId,
    required String surahRef,
  });
  Future<void> pushDhikrCount({required int count, required int? target});
}

/// Titreşim.
abstract interface class HapticsPort {
  /// Her zikir sayımında.
  Future<void> tick();

  /// Hedef tamamlanınca.
  Future<void> success();

  Future<void> selection();
}

/// Saat. Test için sahte saatle değiştirilir; deterministik seçim buna bağlı.
abstract interface class ClockPort {
  DateTime now();
}
