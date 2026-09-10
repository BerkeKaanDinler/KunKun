import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Aşama 1'in kalıcılık katmanı — Ü15 kararı.
///
/// `user.db` (Drift) Aşama 2'ye ait. O gelene kadar kullanıcı tarafındaki veri
/// (kaydedilenler, serbest zikirler, sayaçlar, tercihler) tek bir JSON
/// dosyasında tutulur. Repository arayüzleri bunu bilmez; Aşama 2'de yalnızca
/// bu sınıfın yerine Drift implementasyonu geçer.
///
/// content.db tarafı **buraya hiç yazmaz** — iki veritabanı ayrımı korunur.
class JsonStore {
  JsonStore._(this._file, this._data);

  final File _file;
  Map<String, dynamic> _data;
  Future<void>? _pendingWrite;
  bool _dirty = false;

  static const String _fileName = 'kun_user_v1.json';

  static Future<JsonStore> open() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/$_fileName');
    Map<String, dynamic> data = {};
    if (file.existsSync()) {
      try {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) data = decoded;
      } on FormatException {
        // Bozuk dosya sessizce sıfırlanır; kullanıcı verisi kritik değil,
        // uygulamanın açılamaması kritiktir.
        data = {};
      } on FileSystemException {
        data = {};
      }
    }
    return JsonStore._(file, data);
  }

  /// Test ve dev için bellek içi örnek — dosyaya hiç dokunmaz.
  factory JsonStore.inMemory([Map<String, dynamic>? seed]) =>
      JsonStore._(File('/dev/null'), seed ?? <String, dynamic>{});

  T? read<T>(String key) {
    final v = _data[key];
    return v is T ? v : null;
  }

  /// Yazma **bloke etmez**: değer bellekte anında görünür, diske yazma
  /// 120 ms geciktirilir. Debounce future'ı beklenirse fake-async testlerde
  /// kilitlenme olur; diske indiğinden emin olmak için [flush] kullanılır.
  Future<void> write(String key, Object? value) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
    unawaited(_scheduleFlush());
  }

  /// Yazmalar toplanır; her tuşa basışta diske gitmez.
  Future<void> _scheduleFlush() {
    _dirty = true;
    return _pendingWrite ??= Future<void>.delayed(
      const Duration(milliseconds: 120),
      () async {
        _pendingWrite = null;
        if (!_dirty) return;
        _dirty = false;
        if (_file.path == '/dev/null') return;
        try {
          await _file.parent.create(recursive: true);
          await _file.writeAsString(jsonEncode(_data), flush: true);
        } on FileSystemException {
          // Diske yazılamıyorsa oturum içinde çalışmaya devam edilir.
        }
      },
    );
  }

  Future<void> flush() async {
    await _pendingWrite;
    if (_dirty) {
      _pendingWrite = null;
      await _scheduleFlush();
      await _pendingWrite;
    }
  }
}
