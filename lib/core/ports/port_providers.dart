import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/adapters/noop_adapters.dart';
import 'ports.dart';

/// Aşama 2/3'te yalnızca bu satırlar değişir; ekranlar değişmez.
final audioPortProvider = Provider<AudioPort>((ref) => NoopAudioAdapter());
final adsPortProvider = Provider<AdsPort>((ref) => NoopAdsAdapter());
final sharePortProvider = Provider<SharePort>((ref) => NoopShareAdapter());
final widgetPortProvider = Provider<WidgetPort>((ref) => NoopWidgetAdapter());
final hapticsPortProvider = Provider<HapticsPort>(
  (ref) => SystemHapticsAdapter(),
);
final clockPortProvider = Provider<ClockPort>((ref) => SystemClockAdapter());
