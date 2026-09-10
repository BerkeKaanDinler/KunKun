import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/result.dart';
import '../../domain/models/models.dart';
import 'repositories.dart';

/// Fixture katmanı — repository arayüzünün **ikinci implementasyonu**.
///
/// Aşama 2'de `Drift*` sınıfları aynı arayüzü uygular ve yalnızca provider
/// bağlantısı değişir; ekranlar hangisiyle çalıştığını bilmez.
///
/// İçerik politikası (Ü6–Ü10): metinler yer tutucudur, künyeler sentetiktir,
/// çevirmenler açıkça sahtedir. Arapça alan boştur — uydurulmaz.
class FixtureData {
  FixtureData._(this.verses, this.translators, this.translations);

  final List<Verse> verses;
  final List<Translator> translators;

  /// verseId → translatorId → metin
  final Map<String, Map<String, String>> translations;

  static FixtureData? _cache;

  static Future<FixtureData> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/fixtures/verses.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final translators = [
      for (final t in json['translators'] as List)
        Translator(
          id: t['id'] as String,
          slug: t['slug'] as String,
          name: t['name'] as String,
          workTitle: t['workTitle'] as String,
          edition: t['edition'] as String?,
          year: t['year'] as int?,
          licenseNote: t['licenseNote'] as String?,
          sortOrder: t['sortOrder'] as int? ?? 0,
        ),
    ];

    final verses = <Verse>[];
    final translations = <String, Map<String, String>>{};
    for (final v in json['verses'] as List) {
      final id = v['id'] as String;
      verses.add(
        Verse(
          id: id,
          surahNumber: v['surahNumber'] as int,
          ayahNumber: v['ayahNumber'] as int,
          surahName: v['surahName'] as String,
          // Uydurma Arapça üretilmez; veri yoksa null.
          textAr: v['textAr'] as String?,
        ),
      );
      translations[id] = {
        for (final e in (v['translations'] as Map).entries)
          e.key as String: e.value as String,
      };
    }
    return _cache = FixtureData._(verses, translators, translations);
  }

  /// Testler arası sızıntıyı önlemek için.
  static void resetCache() {
    _cache = null;
    FixtureTaxonomy._cache = null;
  }
}

/// Aile · kategori · eşleşme verisi.
///
/// Aile ve kategori **adları gerçektir** (brief taksonomisi, 16 × 160).
/// Sahte olan yalnızca eşleşmelerdir (Ü10).
class FixtureTaxonomy {
  FixtureTaxonomy._(
    this.families,
    this.categories,
    this.byCategory,
    this.byVerse,
  );

  final List<Family> families;
  final List<Category> categories;

  /// categoryId → verseId listesi (relevance sırasında)
  final Map<String, List<String>> byCategory;

  /// verseId → categoryId listesi
  final Map<String, List<String>> byVerse;

  static FixtureTaxonomy? _cache;

  static Future<FixtureTaxonomy> load() async {
    if (_cache != null) return _cache!;
    final famJson =
        jsonDecode(await rootBundle.loadString('assets/fixtures/families.json'))
            as Map<String, dynamic>;
    final mapJson =
        jsonDecode(
              await rootBundle.loadString(
                'assets/fixtures/verse_categories.json',
              ),
            )
            as Map<String, dynamic>;

    final families = [
      for (final f in famJson['families'] as List)
        Family(
          code: f['code'] as String,
          axis: f['axis'] == 'hayattan' ? Axis2.hayattan : Axis2.kurandan,
          name: f['name'] as String,
          description: f['description'] as String?,
          sortOrder: f['sortOrder'] as int,
        ),
    ];
    final categories = [
      for (final c in famJson['categories'] as List)
        Category(
          id: c['id'] as String,
          familyCode: c['familyCode'] as String,
          slug: c['slug'] as String,
          name: c['name'] as String,
          description: c['description'] as String?,
          sortOrder: c['sortOrder'] as int,
        ),
    ];

    final byCategory = <String, List<String>>{};
    final byVerse = <String, List<String>>{};
    for (final m in mapJson['mappings'] as List) {
      final v = m['verseId'] as String;
      final c = m['categoryId'] as String;
      (byCategory[c] ??= []).add(v);
      (byVerse[v] ??= []).add(c);
    }
    return _cache = FixtureTaxonomy._(
      families,
      categories,
      byCategory,
      byVerse,
    );
  }
}

class FixtureCategoryRepository implements CategoryRepository {
  FixtureCategoryRepository({this.failEverything = false});

  final bool failEverything;

  Err<T> _forced<T>() => const Err(KunFailure(KunFailureKind.forced));

  @override
  Future<Result<List<Family>>> families(Axis2 axis) async {
    if (failEverything) return _forced();
    final t = await FixtureTaxonomy.load();
    return Ok(t.families.where((f) => f.axis == axis).toList());
  }

  @override
  Future<Result<List<Category>>> categoriesOf(String familyCode) async {
    if (failEverything) return _forced();
    final t = await FixtureTaxonomy.load();
    return Ok(t.categories.where((c) => c.familyCode == familyCode).toList());
  }

  @override
  Future<Result<List<CategoryGroup>>> discover(Axis2 axis) async {
    if (failEverything) return _forced();
    final t = await FixtureTaxonomy.load();
    final groups = <CategoryGroup>[];
    for (final f in t.families.where((f) => f.axis == axis)) {
      groups.add(
        CategoryGroup(
          family: f,
          entries: [
            for (final c in t.categories.where((c) => c.familyCode == f.code))
              CategoryEntry(
                category: c,
                // 0 olabilir — boş kategori durumu kasıtlıdır.
                verseCount: t.byCategory[c.id]?.length ?? 0,
              ),
          ],
        ),
      );
    }
    return Ok(groups);
  }

  @override
  Future<Result<Category>> categoryById(String id) async {
    if (failEverything) return _forced();
    final t = await FixtureTaxonomy.load();
    final c = t.categories.where((e) => e.id == id).firstOrNull;
    if (c == null) return const Err(KunFailure(KunFailureKind.notFound));
    return Ok(c);
  }
}

class FixtureVerseRepository implements VerseRepository {
  FixtureVerseRepository({this.failEverything = false});

  /// Ü16 · Ayarlar › geliştirici › "hata modunu zorla".
  final bool failEverything;

  Err<T> _forced<T>() => const Err(KunFailure(KunFailureKind.forced));

  VerseWithTranslation _pack(FixtureData d, Verse v, String? translatorId) {
    final tr = d.translators.firstWhere(
      (t) => t.id == translatorId,
      orElse: () => d.translators.first,
    );
    return VerseWithTranslation(
      verse: v,
      translator: tr,
      translation: Translation(
        verseId: v.id,
        translatorId: tr.id,
        text: d.translations[v.id]?[tr.id] ?? '',
      ),
    );
  }

  @override
  Future<Result<List<SurahGroup>>> surahs() async {
    if (failEverything) return _forced();
    final d = await FixtureData.load();
    final byNumber = <int, List<Verse>>{};
    for (final v in d.verses) {
      (byNumber[v.surahNumber] ??= []).add(v);
    }
    final numbers = byNumber.keys.toList()..sort();
    return Ok([
      for (final n in numbers)
        SurahGroup(
          number: n,
          name: byNumber[n]!.first.surahName,
          // Arapça sûre adı ve nüzul yeri fixture'da yok — uydurulmaz.
          nameAr: null,
          revelation: null,
          verses: [
            for (final v
                in byNumber[n]!
                  ..sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber)))
              _pack(d, v, null),
          ],
        ),
    ]);
  }

  @override
  Future<Result<List<VerseWithTranslation>>> sequential({
    int offset = 0,
    int limit = 50,
  }) async {
    if (failEverything) return _forced();
    final d = await FixtureData.load();
    final slice = d.verses.skip(offset).take(limit).toList();
    return Ok([for (final v in slice) _pack(d, v, null)]);
  }

  @override
  Future<Result<VerseWithTranslation>> verseById(
    String verseId, {
    String? translatorId,
  }) async {
    if (failEverything) return _forced();
    final d = await FixtureData.load();
    final v = d.verses.where((e) => e.id == verseId).firstOrNull;
    if (v == null) return const Err(KunFailure(KunFailureKind.notFound));
    return Ok(_pack(d, v, translatorId));
  }

  @override
  Future<Result<List<VerseWithTranslation>>> allTranslations(
    String verseId,
  ) async {
    if (failEverything) return _forced();
    final d = await FixtureData.load();
    final v = d.verses.where((e) => e.id == verseId).firstOrNull;
    if (v == null) return const Err(KunFailure(KunFailureKind.notFound));
    return Ok([for (final t in d.translators) _pack(d, v, t.id)]);
  }

  @override
  Future<Result<List<Translator>>> translators() async {
    if (failEverything) return _forced();
    return Ok((await FixtureData.load()).translators);
  }

  /// Günün ayeti havuzu — kategorilere bağlı ayetler.
  /// Kategori eşleşmeleri Bölüm 4'te gelecek; şimdilik bütün fixture ayetleri.
  @override
  Future<Result<List<String>>> dailyPoolVerseIds() async {
    if (failEverything) return _forced();
    final t = await FixtureTaxonomy.load();
    // Havuz kategorilere bağlı ayetlerden — tüm Kur'an'dan değil.
    return Ok(t.byVerse.keys.toList()..sort());
  }

  @override
  Future<Result<List<VerseWithTranslation>>> versesInCategory(
    String categoryId,
  ) async {
    if (failEverything) return _forced();
    final d = await FixtureData.load();
    final t = await FixtureTaxonomy.load();
    final ids = t.byCategory[categoryId] ?? const <String>[];
    final byId = {for (final v in d.verses) v.id: v};
    return Ok([
      for (final id in ids)
        if (byId[id] != null) _pack(d, byId[id]!, null),
    ]);
  }

  @override
  Future<Result<List<Category>>> categoriesOfVerse(String verseId) async {
    if (failEverything) return _forced();
    final t = await FixtureTaxonomy.load();
    final ids = t.byVerse[verseId] ?? const <String>[];
    final byId = {for (final c in t.categories) c.id: c};
    return Ok([
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ]);
  }
}

/// Ü4 · 99 isim verisi **gelmedi**. Boş liste döner; hero "veri bekleniyor"
/// durumunda çizilir. İçerik uydurulmaz.
class FixtureAsmaulHusnaRepository implements AsmaulHusnaRepository {
  const FixtureAsmaulHusnaRepository();

  @override
  Future<Result<List<AsmaulHusnaEntry>>> all() async => const Ok([]);
}
