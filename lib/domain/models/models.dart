import 'package:flutter/foundation.dart';

/// Kararlı ID stratejisi (mimari brief):
/// · Ayet: `sure:ayet` — ör. `2:255`. İnsan okunur, sabit.
/// · Aile: tek harf kodu A–P.
/// · Kategori: `A01`–`P10` + slug.
///
/// **Başlık, çeviri metni veya sıra numarası asla foreign key olarak
/// kullanılmaz.** Kategori adı değişebilir, kodu değişmez.

/// Ekseni belirler — Keşif ekranının iki chip'i (T8).
enum Axis2 {
  /// "Hayattan" · 7 aile · 70 kategori. Açılışta seçili gelen eksen.
  hayattan('Hayattan'),

  /// "Kur'an'dan" · 9 aile · 90 kategori.
  kurandan("Kur'an'dan");

  const Axis2(this.label);

  final String label;
}

@immutable
class Family {
  const Family({
    required this.code,
    required this.axis,
    required this.name,
    required this.sortOrder,
    this.description,
  });

  /// 'A'..'P' — veritabanında birincil anahtar.
  final String code;
  final Axis2 axis;
  final String name;
  final String? description;
  final int sortOrder;
}

@immutable
class Category {
  const Category({
    required this.id,
    required this.familyCode,
    required this.slug,
    required this.name,
    required this.sortOrder,
    this.description,
  });

  /// `A01`–`P10`.
  final String id;
  final String familyCode;
  final String slug;
  final String name;
  final String? description;
  final int sortOrder;
}

/// Ayet. Kategoriler buna `sure:ayet` referansıyla bağlanır, meal metnine değil.
@immutable
class Verse {
  const Verse({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    this.textAr,
    this.juz,
    this.page,
  });

  /// `sure:ayet`.
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;

  /// Arapça metin. **Veri yoksa null** — uydurulmaz, yer tutucu bırakılır.
  final String? textAr;

  final int? juz;
  final int? page;

  /// Ekranda gösterilen künye.
  String get reference => '$surahName · $surahNumber:$ayahNumber';
}

@immutable
class Translator {
  const Translator({
    required this.id,
    required this.slug,
    required this.name,
    required this.workTitle,
    this.edition,
    this.year,
    this.licenseNote,
    this.sortOrder = 0,
  });

  final String id;
  final String slug;

  /// Lisans şartı: ayet ekranında ve paylaşım görselinde **görünür** olmalı.
  final String name;
  final String workTitle;
  final String? edition;
  final int? year;
  final String? licenseNote;
  final int sortOrder;

  String get credit =>
      edition == null ? '$name · $workTitle' : '$name · $workTitle · $edition';
}

@immutable
class Translation {
  const Translation({
    required this.verseId,
    required this.translatorId,
    required this.text,
  });

  final String verseId;
  final String translatorId;
  final String text;
}

/// Kategori–ayet eşleşmesi. **Editoryaldir, dinî hüküm değildir** —
/// uygulamada bu açıkça belirtilir.
@immutable
class VerseCategory {
  const VerseCategory({
    required this.verseId,
    required this.categoryId,
    this.relevanceScore = 0,
    this.contextWarning,
  });

  final String verseId;
  final String categoryId;
  final int relevanceScore;
  final String? contextWarning;
}

/// Hazır zikir · **sabittir**. Metin, anlam ve sayı kullanıcı tarafından
/// değiştirilemez, silinemez.
@immutable
class DhikrPreset {
  const DhikrPreset({
    required this.slug,
    required this.nameTr,
    required this.textAr,
    required this.meaning,
    required this.targetCount,
    required this.stepOrder,
  });

  final String slug;
  final String nameTr;
  final String textAr;
  final String meaning;
  final int targetCount;
  final int stepOrder;
}

/// Serbest zikir — kullanıcının kendi kaydı. **Hedef yoktur, sayaç durmaz.**
/// Yalnızca cihazda saklanır, yedeklenmez.
@immutable
class CustomDhikr {
  const CustomDhikr({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
    this.textAr,
    this.meaning,
    this.vibrateEvery33 = true,
  });

  final String id;
  final String name;
  final String? textAr;
  final String? meaning;
  final int sortOrder;
  final bool vibrateEvery33;
  final DateTime createdAt;
}

/// Esmâ-i Hüsnâ kaydı · ana sayfa hero'su bunu kullanır.
@immutable
class AsmaulHusnaEntry {
  const AsmaulHusnaEntry({
    required this.orderIndex,
    required this.nameTr,
    required this.nameAr,
    required this.transliteration,
    required this.meaning,
  });

  final int orderIndex;
  final String nameTr;
  final String nameAr;
  final String transliteration;
  final String meaning;
}

@immutable
class SavedVerse {
  const SavedVerse({
    required this.verseId,
    required this.savedAt,
    this.sourceCategoryId,
  });

  /// **Yalnızca referans tutulur — metin asla kopyalanmaz.**
  /// Meal güncellendiğinde kullanıcının kayıtları otomatik güncel kalır.
  final String verseId;
  final DateTime savedAt;
  final String? sourceCategoryId;
}

/// Gün başına zikir toplamı. Seri bunun üzerinden **türetilir**,
/// ayrı sayaç tutulmaz (Ü13).
@immutable
class DailyStat {
  const DailyStat({
    required this.day,
    required this.totalCount,
    required this.presetCount,
    required this.customCount,
  });

  /// Yerel tarih, `yyyy-MM-dd`.
  final String day;
  final int totalCount;
  final int presetCount;
  final int customCount;
}
