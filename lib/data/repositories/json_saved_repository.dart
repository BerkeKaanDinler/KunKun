import 'dart:async';

import '../../core/result.dart';
import '../../domain/models/models.dart';
import '../local/json_store.dart';
import 'repositories.dart';

/// Kaydedilenler — **gerçek kullanıcı verisi**, Ü15 gereği JSON snapshot'ta.
///
/// Referans bütünlüğü kuralı: yalnızca `verseId` tutulur, **metin asla
/// kopyalanmaz**. Meal güncellendiğinde kayıtlar otomatik güncel kalır.
/// Aşama 2'de yerini `DriftSavedRepository` (user.db) alır.
class JsonSavedRepository implements SavedRepository {
  JsonSavedRepository(this._store, {this.failEverything = false});

  final JsonStore _store;
  final bool failEverything;

  static const String _key = 'saved_verses';

  final _controller = StreamController<List<SavedVerse>>.broadcast();

  Err<T> _forced<T>() => const Err(KunFailure(KunFailureKind.forced));

  List<SavedVerse> _read() {
    final raw = _store.read<List<dynamic>>(_key) ?? const [];
    final out = <SavedVerse>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final id = e['verseId'];
      final at = e['savedAt'];
      if (id is! String || at is! String) continue;
      final parsed = DateTime.tryParse(at);
      if (parsed == null) continue;
      out.add(
        SavedVerse(
          verseId: id,
          savedAt: parsed,
          sourceCategoryId: e['sourceCategoryId'] as String?,
        ),
      );
    }
    // En yeni üstte.
    out.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return out;
  }

  Future<void> _write(List<SavedVerse> items) async {
    await _store.write(_key, [
      for (final s in items)
        {
          'verseId': s.verseId,
          'savedAt': s.savedAt.toIso8601String(),
          if (s.sourceCategoryId != null)
            'sourceCategoryId': s.sourceCategoryId,
        },
    ]);
    _controller.add(items);
  }

  @override
  Future<Result<List<SavedVerse>>> all() async {
    if (failEverything) return _forced();
    return Ok(_read());
  }

  @override
  Future<Result<bool>> isSaved(String verseId) async {
    if (failEverything) return _forced();
    return Ok(_read().any((s) => s.verseId == verseId));
  }

  @override
  Future<Result<void>> save(String verseId, {String? sourceCategoryId}) async {
    if (failEverything) return _forced();
    final items = _read();
    if (items.any((s) => s.verseId == verseId)) return const Ok(null);
    items.insert(
      0,
      SavedVerse(
        verseId: verseId,
        savedAt: DateTime.now(),
        sourceCategoryId: sourceCategoryId,
      ),
    );
    await _write(items);
    return const Ok(null);
  }

  @override
  Future<Result<void>> remove(String verseId) async {
    if (failEverything) return _forced();
    final items = _read()..removeWhere((s) => s.verseId == verseId);
    await _write(items);
    return const Ok(null);
  }

  // ---------------------------------------------------------- kategoriler

  static const String _catKey = 'saved_categories';

  final _catController = StreamController<List<String>>.broadcast();

  List<String> _readCategories() {
    final raw = _store.read<List<dynamic>>(_catKey) ?? const [];
    return [
      for (final e in raw)
        if (e is String) e,
    ];
  }

  @override
  Future<Result<List<String>>> savedCategories() async {
    if (failEverything) return _forced();
    return Ok(_readCategories());
  }

  @override
  Future<Result<bool>> isCategorySaved(String categoryId) async {
    if (failEverything) return _forced();
    return Ok(_readCategories().contains(categoryId));
  }

  @override
  Future<Result<void>> saveCategory(String categoryId) async {
    if (failEverything) return _forced();
    final items = _readCategories();
    if (items.contains(categoryId)) return const Ok(null);
    final next = [categoryId, ...items];
    await _store.write(_catKey, next);
    _catController.add(next);
    return const Ok(null);
  }

  @override
  Future<Result<void>> removeCategory(String categoryId) async {
    if (failEverything) return _forced();
    final next = _readCategories()..remove(categoryId);
    await _store.write(_catKey, next);
    _catController.add(next);
    return const Ok(null);
  }

  @override
  Stream<List<String>> watchCategories() async* {
    yield _readCategories();
    yield* _catController.stream;
  }

  @override
  Stream<List<SavedVerse>> watch() async* {
    yield _read();
    yield* _controller.stream;
  }
}
