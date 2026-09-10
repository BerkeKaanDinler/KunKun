import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/result.dart';
import '../../domain/models/models.dart';
import '../local/json_store.dart';
import 'repositories.dart';

/// Zikir verisi.
///
/// **Hazır set sabittir** — `assets/fixtures/dhikr.json` içindeki dört adım
/// (33 · 33 · 33 + kapanışta 1) okunur; yazma yolu yoktur, kullanıcı metni,
/// anlamı veya sayıyı değiştiremez.
///
/// Serbest zikirler ve sayaçlar kullanıcı verisidir → JSON snapshot (Ü15).
/// **Yalnızca cihazda saklanır, yedeklenmez.**
class DhikrFixture {
  DhikrFixture._(this.presets, this.customExamples);

  final List<DhikrPreset> presets;
  final List<CustomDhikr> customExamples;

  static DhikrFixture? _cache;

  static Future<DhikrFixture> load() async {
    if (_cache != null) return _cache!;
    final json =
        jsonDecode(await rootBundle.loadString('assets/fixtures/dhikr.json'))
            as Map<String, dynamic>;
    final presets = [
      for (final p in json['presets'] as List)
        DhikrPreset(
          slug: p['slug'] as String,
          nameTr: p['nameTr'] as String,
          textAr: p['textAr'] as String,
          meaning: p['meaning'] as String,
          targetCount: p['targetCount'] as int,
          stepOrder: p['stepOrder'] as int,
        ),
    ];
    final examples = <CustomDhikr>[];
    var i = 0;
    for (final c in json['customExamples'] as List) {
      examples.add(
        CustomDhikr(
          id: 'ornek-${i + 1}',
          name: c['name'] as String,
          textAr: c['textAr'] as String?,
          meaning: c['meaning'] as String?,
          sortOrder: i,
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
      i++;
    }
    return _cache = DhikrFixture._(presets, examples);
  }

  static void resetCache() => _cache = null;
}

class JsonDhikrRepository implements DhikrRepository {
  JsonDhikrRepository(this._store, {this.failEverything = false});

  final JsonStore _store;
  final bool failEverything;

  static const String _customKey = 'custom_dhikr';
  static const String _statsKey = 'daily_stats';

  final _customController = StreamController<List<CustomDhikr>>.broadcast();

  Err<T> _forced<T>() => const Err(KunFailure(KunFailureKind.forced));

  static String _dayKey(DateTime now) {
    final d = now.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}'
        '-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<Result<List<DhikrPreset>>> presets() async {
    if (failEverything) return _forced();
    return Ok((await DhikrFixture.load()).presets);
  }

  List<CustomDhikr> _readCustom() {
    final raw = _store.read<List<dynamic>>(_customKey);
    if (raw == null) return const [];
    final out = <CustomDhikr>[];
    for (final e in raw) {
      if (e is! Map) continue;
      out.add(
        CustomDhikr(
          id: e['id'] as String,
          name: e['name'] as String,
          textAr: e['textAr'] as String?,
          meaning: e['meaning'] as String?,
          sortOrder: e['sortOrder'] as int? ?? 0,
          vibrateEvery33: e['vibrateEvery33'] as bool? ?? true,
          createdAt:
              DateTime.tryParse(e['createdAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    }
    out.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return out;
  }

  Future<void> _writeCustom(List<CustomDhikr> items) async {
    await _store.write(_customKey, [
      for (final c in items)
        {
          'id': c.id,
          'name': c.name,
          if (c.textAr != null) 'textAr': c.textAr,
          if (c.meaning != null) 'meaning': c.meaning,
          'sortOrder': c.sortOrder,
          'vibrateEvery33': c.vibrateEvery33,
          'createdAt': c.createdAt.toIso8601String(),
        },
    ]);
    _customController.add(items);
  }

  @override
  Future<Result<List<CustomDhikr>>> customList() async {
    if (failEverything) return _forced();
    final stored = _store.read<List<dynamic>>(_customKey);
    // İlk açılışta örnek kayıtlar gösterilir; kullanıcı dokununca kendi
    // listesi oluşur ve örnekler bir daha görünmez.
    if (stored == null) return Ok((await DhikrFixture.load()).customExamples);
    return Ok(_readCustom());
  }

  @override
  Future<Result<void>> addCustom(CustomDhikr dhikr) async {
    if (failEverything) return _forced();
    final items = List<CustomDhikr>.from(
      (await customList()).valueOrNull ?? const [],
    )..add(dhikr);
    for (var i = 0; i < items.length; i++) {
      items[i] = CustomDhikr(
        id: items[i].id,
        name: items[i].name,
        textAr: items[i].textAr,
        meaning: items[i].meaning,
        sortOrder: i,
        vibrateEvery33: items[i].vibrateEvery33,
        createdAt: items[i].createdAt,
      );
    }
    await _writeCustom(items);
    return const Ok(null);
  }

  @override
  Future<Result<void>> removeCustom(String id) async {
    if (failEverything) return _forced();
    final items = List<CustomDhikr>.from(
      (await customList()).valueOrNull ?? const [],
    )..removeWhere((c) => c.id == id);
    await _writeCustom(items);
    return const Ok(null);
  }

  @override
  Future<Result<void>> reorderCustom(List<String> idsInOrder) async {
    if (failEverything) return _forced();
    final byId = {
      for (final c in (await customList()).valueOrNull ?? const <CustomDhikr>[])
        c.id: c,
    };
    final items = <CustomDhikr>[];
    for (var i = 0; i < idsInOrder.length; i++) {
      final c = byId[idsInOrder[i]];
      if (c == null) continue;
      items.add(
        CustomDhikr(
          id: c.id,
          name: c.name,
          textAr: c.textAr,
          meaning: c.meaning,
          sortOrder: i,
          vibrateEvery33: c.vibrateEvery33,
          createdAt: c.createdAt,
        ),
      );
    }
    await _writeCustom(items);
    return const Ok(null);
  }

  /// Gün toplamı `daily_stats`'e yazılır; **seri buradan türetilir**,
  /// ayrı sayaç tutulmaz (Ü13).
  @override
  Future<Result<void>> recordCount({
    required bool isPreset,
    required int delta,
  }) async {
    if (failEverything) return _forced();
    final day = _dayKey(DateTime.now());
    final raw = Map<String, dynamic>.from(
      _store.read<Map<String, dynamic>>(_statsKey) ?? const {},
    );
    final row = Map<String, dynamic>.from(
      (raw[day] as Map?)?.cast<String, dynamic>() ?? const {},
    );
    row['total'] = (row['total'] as int? ?? 0) + delta;
    row[isPreset ? 'preset' : 'custom'] =
        (row[isPreset ? 'preset' : 'custom'] as int? ?? 0) + delta;
    raw[day] = row;
    await _store.write(_statsKey, raw);
    return const Ok(null);
  }

  @override
  Future<Result<List<DailyStat>>> dailyStats({int lastDays = 30}) async {
    if (failEverything) return _forced();
    final raw = _store.read<Map<String, dynamic>>(_statsKey) ?? const {};
    final out = <DailyStat>[];
    for (final e in raw.entries) {
      final row = (e.value as Map?)?.cast<String, dynamic>() ?? const {};
      out.add(
        DailyStat(
          day: e.key,
          totalCount: row['total'] as int? ?? 0,
          presetCount: row['preset'] as int? ?? 0,
          customCount: row['custom'] as int? ?? 0,
        ),
      );
    }
    out.sort((a, b) => a.day.compareTo(b.day));
    return Ok(out);
  }

  @override
  Stream<List<CustomDhikr>> watchCustom() async* {
    yield (await customList()).valueOrNull ?? const [];
    yield* _customController.stream;
  }
}
