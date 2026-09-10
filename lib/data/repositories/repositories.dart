import '../../core/result.dart';
import '../../domain/models/models.dart';

/// Repository kuralı (mimari brief):
///
/// **Feature katmanı asla Drift'e veya bir HTTP istemcisine doğrudan
/// dokunmaz.** Yalnızca bu arayüzleri tanır. Veri kaynağı yarın uzağa
/// taşınırsa yalnızca `data/` değişir, ekranlar değişmez.
///
/// Aşama 1'de `Fixture*` implementasyonları, Aşama 2'de `Drift*`
/// implementasyonları bağlanır. Ekranlar hangisiyle çalıştığını bilmez.

abstract interface class CategoryRepository {
  Future<Result<List<Family>>> families(Axis2 axis);
  Future<Result<List<Category>>> categoriesOf(String familyCode);

  /// Keşif ekranı: aile → kategoriler + her kategorinin ayet sayısı.
  Future<Result<List<CategoryGroup>>> discover(Axis2 axis);

  Future<Result<Category>> categoryById(String id);
}

class CategoryGroup {
  const CategoryGroup({required this.family, required this.entries});

  final Family family;
  final List<CategoryEntry> entries;
}

class CategoryEntry {
  const CategoryEntry({required this.category, required this.verseCount});

  final Category category;

  /// 0 olabilir — boş kategori durumu kasıtlıdır (Ü10).
  final int verseCount;
}

abstract interface class VerseRepository {
  Future<Result<List<VerseWithTranslation>>> versesInCategory(
    String categoryId,
  );
  Future<Result<VerseWithTranslation>> verseById(
    String verseId, {
    String? translatorId,
  });

  /// Karşılaştırma ekranı — bir ayetin bütün mealleri.
  Future<Result<List<VerseWithTranslation>>> allTranslations(String verseId);

  Future<Result<List<Translator>>> translators();

  /// Sûre listesi — "Tüm ayetler" ekranı düz ayet listesi değil, sûre
  /// listesidir; ilk sûre açık gelir.
  Future<Result<List<SurahGroup>>> surahs();

  /// "Tüm ayetler · sırayla". Aşama 1'de fixture'daki kısa liste.
  Future<Result<List<VerseWithTranslation>>> sequential({
    int offset = 0,
    int limit = 50,
  });

  /// Günün ayeti havuzu — **kategorilere bağlı ayetler**, tüm Kur'an değil.
  Future<Result<List<String>>> dailyPoolVerseIds();

  /// Bir ayetin bağlı olduğu kategoriler — ayet odak ekranındaki çipler.
  Future<Result<List<Category>>> categoriesOfVerse(String verseId);
}

/// Bir sûre ve ayetleri.
class SurahGroup {
  const SurahGroup({
    required this.number,
    required this.name,
    required this.verses,
    this.nameAr,
    this.revelation,
  });

  final int number;
  final String name;

  /// Arapça sûre adı. **Veri yoksa null** — uydurulmaz.
  final String? nameAr;

  /// "Mekke" / "Medine". Veri yoksa null.
  final String? revelation;

  final List<VerseWithTranslation> verses;
}

/// Ekranların gördüğü birleşik model.
class VerseWithTranslation {
  const VerseWithTranslation({
    required this.verse,
    required this.translation,
    required this.translator,
  });

  final Verse verse;

  /// Meal metni. Aşama 1'de fixture yer tutucusu.
  final Translation translation;

  /// Lisans şartı — künye ekranda görünür olmalı.
  final Translator translator;
}

abstract interface class SavedRepository {
  Future<Result<List<SavedVerse>>> all();

  /// Kaydedilen kategoriler — tasarımdaki "Konular" sekmesi.
  ///
  /// Şemada karşılığı `saved_categories(category_id, saved_at)`; ayetlerde
  /// olduğu gibi **yalnızca referans tutulur**, kategori adı kopyalanmaz.
  Future<Result<List<String>>> savedCategories();
  Future<Result<bool>> isCategorySaved(String categoryId);
  Future<Result<void>> saveCategory(String categoryId);
  Future<Result<void>> removeCategory(String categoryId);
  Stream<List<String>> watchCategories();
  Future<Result<bool>> isSaved(String verseId);
  Future<Result<void>> save(String verseId, {String? sourceCategoryId});
  Future<Result<void>> remove(String verseId);
  Stream<List<SavedVerse>> watch();
}

abstract interface class DhikrRepository {
  /// Hazır set — **sabittir**, yazma yolu yoktur.
  Future<Result<List<DhikrPreset>>> presets();

  Future<Result<List<CustomDhikr>>> customList();
  Future<Result<void>> addCustom(CustomDhikr dhikr);
  Future<Result<void>> removeCustom(String id);
  Future<Result<void>> reorderCustom(List<String> idsInOrder);

  /// Sayaç artışı. Gün toplamı `daily_stats`'e yazılır; seri buradan türetilir.
  Future<Result<void>> recordCount({
    required bool isPreset,
    required int delta,
  });

  Future<Result<List<DailyStat>>> dailyStats({int lastDays = 30});
  Stream<List<CustomDhikr>> watchCustom();
}

abstract interface class AsmaulHusnaRepository {
  /// 99 kayıt. **Veri gelmediyse boş liste döner** — uydurulmaz;
  /// hero "veri bekleniyor" durumunda çizilir (Ü4).
  Future<Result<List<AsmaulHusnaEntry>>> all();
}
