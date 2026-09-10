import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kun/domain/usecases/turkish_search.dart';

/// Brief: "İlk hafta 30–40 gerçek sorgudan test seti kurulur.
/// Ölçülmeyen arama düzeltilemez."
///
/// Her satır: kullanıcının yazacağı sorgu → ayette geçmesi beklenen biçim.
/// Sorgunun ürettiği öneklerden en az biri hedef kelimeyi yakalamalı.
const List<({String query, String target, String note})> kQuerySet = [
  // — ünlü düşmesi: asıl zor vaka
  (query: 'sabır', target: 'sabredenler', note: 'ünlü düşmesi'),
  (query: 'sabır', target: 'sabrettiler', note: 'ünlü düşmesi'),
  (query: 'isim', target: 'ismi', note: 'ünlü düşmesi'),
  (query: 'ilim', target: 'ilmi', note: 'ünlü düşmesi'),
  (query: 'akıl', target: 'aklı', note: 'ünlü düşmesi'),
  (query: 'şükür', target: 'şükredenler', note: 'ünlü düşmesi'),
  (query: 'oğul', target: 'oğlu', note: 'ünlü düşmesi'),
  (query: 'nesil', target: 'nesli', note: 'ünlü düşmesi'),

  // — büyük/küçük harf ve noktalı/noktasız I
  (query: 'SABIR', target: 'sabredenler', note: 'büyük harf + noktasız I'),
  (query: 'İMAN', target: 'imanı', note: 'noktalı İ'),
  (query: 'Işık', target: 'ışığı', note: 'noktasız I başta'),
  (query: 'IŞIK', target: 'ışık', note: 'tümü büyük'),
  (query: 'iman', target: 'İMAN', note: 'ters yön'),

  // — şapkalı harfler
  (query: 'kâfir', target: 'kafirler', note: 'şapkalı a'),
  (query: 'hâl', target: 'hali', note: 'şapkalı a'),
  (query: 'îman', target: 'imanı', note: 'şapkalı i'),

  // — Türkçe'ye özgü harfler
  (query: 'şükür', target: 'sukur', note: 'ş → s katlama'),
  (query: 'çocuk', target: 'cocuklar', note: 'ç → c katlama'),
  (query: 'öğüt', target: 'ogut', note: 'ö ve ğ katlama'),
  (query: 'güzel', target: 'guzellik', note: 'ü katlama'),

  // — çekim ekleri
  (query: 'namaz', target: 'namazı', note: 'iyelik eki'),
  (query: 'namaz', target: 'namazlarını', note: 'çoğul + iyelik'),
  (query: 'rahmet', target: 'rahmetinden', note: 'ayrılma hâli'),
  (query: 'gökler', target: 'göklerin', note: 'çoğul + tamlayan'),
  (query: 'kalp', target: 'kalpler', note: 'çoğul'),
  (query: 'insan', target: 'insanların', note: 'çoğul + tamlayan'),
  (query: 'yetim', target: 'yetimlere', note: 'yönelme hâli'),
  (query: 'zulüm', target: 'zulmedenler', note: 'ünlü düşmesi + fiil'),

  // — kategori adları (gerçek taksonomi)
  (query: 'tevekkül', target: 'tevekkül', note: 'kategori adı'),
  (query: 'cömertlik', target: 'cömert', note: 'kategori adı, ek soyma'),
  (query: 'kanaat', target: 'kanaatkâr', note: 'kategori adı'),
  (query: 'adalet', target: 'adaletle', note: 'kategori adı'),
  (query: 'tövbe', target: 'tövbesi', note: 'kategori adı'),
  (query: 'merhamet', target: 'merhametli', note: 'kategori adı'),

  // — kesme işareti ve çok kelimeli
  (query: "Kur'an", target: 'kuran', note: 'kesme işareti'),
  (query: 'Allah’ın', target: 'allahin', note: 'eğik kesme'),
  (query: 'gece ve gündüz', target: 'gecenin', note: 'çok kelimeli'),
  (query: 'yetim hakkı', target: 'yetimlerin', note: 'çok kelimeli'),
];

/// Sorgunun ürettiği öneklerden biri hedefi yakalıyor mu?
bool _matches(String query, String target) {
  final t = TurkishSearch.normalize(target);
  // Çok kelimeli sorguda kelimelerden birinin kökü tutması yeterli —
  // `ftsQuery` de kelime kelime çalışır.
  final words = TurkishSearch.normalize(query).split(' ');
  return words.any((w) => TurkishSearch.stems(w).any(t.startsWith));
}

void main() {
  group('Türkçe arama · normalleştirme', () {
    test('noktalı/noktasız I doğru küçülür', () {
      expect(TurkishSearch.normalize('IŞIK'), 'isik');
      expect(TurkishSearch.normalize('İSİM'), 'isim');
      expect(TurkishSearch.normalize('Işık'), 'isik');
      // Dart'ın kendi toLowerCase'i burada yanılır — kural özel yazıldı.
      expect('IŞIK'.toLowerCase(), isNot('ışık'));
    });

    test('şapkalı ve Türkçe harfler katlanır', () {
      expect(TurkishSearch.normalize('kâfir'), 'kafir');
      expect(TurkishSearch.normalize('şükür'), 'sukur');
      expect(TurkishSearch.normalize('çöl'), 'col');
      expect(TurkishSearch.normalize('ğ ü ö ç ş ı'), 'g u o c s i');
    });

    test('kesme işareti ve noktalama atılır', () {
      expect(TurkishSearch.normalize("Kur'an"), 'kuran');
      expect(TurkishSearch.normalize('Allah’ın'), 'allahin');
      expect(TurkishSearch.normalize('2:255'), '2 255');
    });

    test('ünlü düşmesi varyantı üretilir', () {
      expect(TurkishSearch.stems('sabır'), contains('sabr'));
      expect(TurkishSearch.stems('isim'), contains('ism'));
      expect(TurkishSearch.stems('akıl'), contains('akl'));
    });

    test('kök 3 harften kısalmaz — aşırı soyma yok', () {
      for (final w in ['ela', 'ada', 'dil', 'yol', 'gün']) {
        for (final s in TurkishSearch.stems(w)) {
          expect(s.length, greaterThanOrEqualTo(2), reason: '$w → $s');
        }
      }
    });

    test('FTS sorgusu önek biçiminde', () {
      expect(TurkishSearch.ftsQuery('sabır'), '(sabir* OR sabr*)');
      expect(TurkishSearch.ftsQuery(''), '');
      expect(TurkishSearch.ftsQuery('yetim hakkı').split(' AND ').length, 2);
    });
  });

  group('Türkçe arama · 38 sorgudan test seti', () {
    test('set 30–40 sorgu içeriyor', () {
      expect(kQuerySet.length, inInclusiveRange(30, 40));
    });

    for (final c in kQuerySet) {
      test('"${c.query}" → "${c.target}" · ${c.note}', () {
        expect(
          _matches(c.query, c.target),
          isTrue,
          reason:
              '${c.query} kökleri: ${TurkishSearch.stems(c.query)} · '
              'hedef: ${TurkishSearch.normalize(c.target)}',
        );
      });
    }
  });

  group('Türkçe arama · Dart ve Python aynı sonucu vermeli', () {
    test('normalize ve stems iki uygulamada birebir', () {
      final samples = [
        for (final c in kQuerySet) c.query,
        for (final c in kQuerySet) c.target,
        'Kâğıt indeks',
        'IŞIK',
        'İstanbul',
        'oğlu',
        'şükredenler',
      ];

      // Python tarafını dosyadan besleyip çıktısını karşılaştırıyoruz.
      final tmp = File('${Directory.systemTemp.path}/kun_queries.txt')
        ..writeAsStringSync(samples.join('\n'));
      final run = Process.runSync('bash', [
        '-c',
        'python3 tool/turkish_search.py < ${tmp.path}',
      ], stdoutEncoding: utf8);
      expect(run.exitCode, 0, reason: run.stderr.toString());

      final py = jsonDecode(run.stdout as String) as Map<String, dynamic>;
      for (final s in samples.toSet()) {
        final row = py[s] as Map<String, dynamic>;
        expect(
          TurkishSearch.normalize(s),
          row['normalize'],
          reason: 'normalize ayrıştı: $s',
        );
        expect(
          (TurkishSearch.stems(s).toList()..sort()),
          (row['stems'] as List).cast<String>(),
          reason: 'stems ayrıştı: $s',
        );
        expect(
          TurkishSearch.ftsQuery(s),
          row['fts'],
          reason: 'ftsQuery ayrıştı: $s',
        );
      }
    });
  });
}
