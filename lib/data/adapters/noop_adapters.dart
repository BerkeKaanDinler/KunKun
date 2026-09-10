import 'dart:async';

import 'package:flutter/services.dart';

import '../../core/ports/ports.dart';

/// V1 — ses tedariki bitmedi. Kontroller arayüzde var ama pasif.
class NoopAudioAdapter implements AudioPort {
  @override
  bool get isAvailable => false;

  @override
  Stream<AudioState> get state => const Stream<AudioState>.empty();

  @override
  Future<void> play(String verseId) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> seek(Duration position) async {}
}

/// V1 — hiç çağrılmaz.
class NoopAdsAdapter implements AdsPort {
  @override
  bool get isEnabled => false;

  @override
  Future<void> preload() async {}
}

/// Aşama 3.
class NoopShareAdapter implements SharePort {
  @override
  bool get isAvailable => false;

  @override
  Future<void> shareVerseImage({
    required String verseId,
    required String translatorCredit,
  }) async {}
}

/// Aşama 3 — native widget. Aşama 1'de yalnızca uygulama içi önizleme var.
class NoopWidgetAdapter implements WidgetPort {
  @override
  bool get isAvailable => false;

  @override
  Future<void> pushDailyVerse({
    required String verseId,
    required String surahRef,
  }) async {}

  @override
  Future<void> pushDhikrCount({
    required int count,
    required int? target,
  }) async {}
}

/// Gerçek implementasyon — Aşama 1'de çalışır.
class SystemHapticsAdapter implements HapticsPort {
  @override
  Future<void> tick() => HapticFeedback.lightImpact();

  @override
  Future<void> success() => HapticFeedback.mediumImpact();

  @override
  Future<void> selection() => HapticFeedback.selectionClick();
}

class SystemClockAdapter implements ClockPort {
  @override
  DateTime now() => DateTime.now();
}

/// Test için sabit saat.
class FixedClockAdapter implements ClockPort {
  FixedClockAdapter(this._now);
  DateTime _now;
  set value(DateTime v) => _now = v;

  @override
  DateTime now() => _now;
}
