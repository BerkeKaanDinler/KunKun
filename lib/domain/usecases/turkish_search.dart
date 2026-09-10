/// Türkçe arama · mimari brief "Türkçe arama — çözülmemiş problem".
///
/// Sorun: Türkçe sondan eklemelidir. Kullanıcı "sabır" arar, ayette
/// "sabredenler" geçer → FTS5'in Türkçe kök bulucusu olmadığı için sıfır
/// sonuç. Üstelik "sabır" → "sabr" ünlü düşmesi yaşar, yani düz önek araması
/// da tutmaz.
///
/// Çözüm üç katmanlı:
///   1. [normalize] — indeksleme ve sorgu için ortak, kayıpsız olmayan ama
///      **deterministik** sadeleştirme. `normalized_text` bununla üretilir.
///   2. [stems] — elle yazılmış muhafazakâr ek soyucu + ünlü düşmesi varyantı.
///   3. [ftsQuery] — üretilen köklerden önek (`sabr*`) sorgusu.
///
/// **Bu kurallar `tool/turkish_search.py` ile birebir aynı olmalıdır**;
/// `content.db` oradaki uygulamayla üretiliyor. `turkish_search_test.dart`
/// ikisinin aynı çıktıyı verdiğini doğrular.
class TurkishSearch {
  const TurkishSearch._();

  /// Türkçeye özgü küçültme: `I → ı`, `İ → i`. Dart'ın `toLowerCase()`
  /// bunu yapmaz; `I` → `i` üretir ve "IŞIK" → "işik" gibi yanlış sonuç verir.
  static String _lowerTr(String input) {
    final b = StringBuffer();
    for (final r in input.runes) {
      switch (r) {
        case 0x49: // I
          b.write('ı');
        case 0x130: // İ
          b.write('i');
        default:
          b.write(String.fromCharCode(r).toLowerCase());
      }
    }
    return b.toString();
  }

  static const Map<String, String> _fold = {
    'â': 'a',
    'ā': 'a',
    'á': 'a',
    'à': 'a',
    'î': 'i',
    'ī': 'i',
    'í': 'i',
    'ı': 'i',
    'û': 'u',
    'ū': 'u',
    'ú': 'u',
    'ü': 'u',
    'ö': 'o',
    'ó': 'o',
    'ô': 'o',
    'ç': 'c',
    'ğ': 'g',
    'ş': 's',
    'ʼ': '',
    '’': '',
    '‘': '',
    "'": '',
  };

  /// İndeksleme ve sorgu için ortak sadeleştirme.
  ///
  /// Küçük harfe indirir (Türkçe kuralıyla), şapkalı ve Türkçe'ye özgü
  /// harfleri katlar, noktalamayı atar, boşlukları tekler.
  static String normalize(String input) {
    final lowered = _lowerTr(input);
    final b = StringBuffer();
    for (final ch in lowered.split('')) {
      final folded = _fold[ch];
      if (folded != null) {
        b.write(folded);
        continue;
      }
      final c = ch.codeUnitAt(0);
      final isAsciiLetter = c >= 0x61 && c <= 0x7A;
      final isDigit = c >= 0x30 && c <= 0x39;
      b.write(isAsciiLetter || isDigit ? ch : ' ');
    }
    return b.toString().split(' ').where((w) => w.isNotEmpty).join(' ');
  }

  /// Sondan atılabilecek çekim ekleri — muhafazakâr tutuldu.
  ///
  /// Uzun ekten kısaya sıralı; ilk tutan uygulanır. Kök 3 harften kısalırsa
  /// soyma yapılmaz (aşırı soyma yanlış eşleşme üretir).
  static const List<String> _suffixes = [
    'lerinden',
    'larindan',
    'lerinde',
    'larinda',
    'lerini',
    'larini',
    'lerine',
    'larina',
    'lerin',
    'larin',
    'leri',
    'lari',
    'imiz',
    'iniz',
    'umuz',
    'unuz',
    'dan',
    'den',
    'tan',
    'ten',
    'nin',
    'nun',
    'in',
    'un',
    'ler',
    'lar',
    'lik',
    'luk',
    'li',
    'lu',
    'ci',
    'cu',
    'ce',
    'ca',
    'da',
    'de',
    'ta',
    'te',
    'ya',
    'ye',
    'yi',
    'yu',
    'im',
    'um',
    'si',
    'su',
    'si',
    'i',
    'e',
    'a',
    'u',
  ];

  static const int _minStem = 3;

  /// Bir kelimenin arama kökleri.
  ///
  /// Üretilenler:
  ///   · kelimenin kendisi
  ///   · ek soyulmuş hâli
  ///   · **ünlü düşmesi varyantı** — "sabir" → "sabr", "isim" → "ism".
  ///     Türkçede iki heceli, son hecesi dar ünlülü kelimeler ek alınca
  ///     ünlüsünü düşürür; "sabır" arayan "sabredenler"i ancak böyle bulur.
  static Set<String> stems(String word) {
    final out = <String>{};
    final w = normalize(word);
    if (w.isEmpty) return out;
    out.add(w);

    var stem = w;
    for (final suf in _suffixes) {
      if (stem.length - suf.length >= _minStem && stem.endsWith(suf)) {
        stem = stem.substring(0, stem.length - suf.length);
        out.add(stem);
        break;
      }
    }

    for (final base in {w, stem}) {
      final dropped = _dropNarrowVowel(base);
      if (dropped != null) out.add(dropped);
    }
    for (final base in {...out}) {
      final softened = _softenFinal(base);
      if (softened != null) out.add(softened);
    }
    return out;
  }

  /// Ünsüz yumuşaması: `ışık → ışığ(ı)`, `kitap → kitab(ı)`, `ümit → ümid(i)`.
  /// Sondaki sert ünsüz ek alınca yumuşar; önek araması bunu görmeli.
  /// (`ç → c` katlamada zaten olduğu için ayrıca ele alınmaz.)
  static String? _softenFinal(String w) {
    if (w.length < 3) return null;
    const map = {'k': 'g', 'p': 'b', 't': 'd'};
    final soft = map[w[w.length - 1]];
    if (soft == null) return null;
    return w.substring(0, w.length - 1) + soft;
  }

  /// Son hecedeki dar ünlüyü düşürür: `sabir → sabr`, `ilim → ilm`.
  /// Yalnızca `CVC` biten ve en az iki heceli kelimelerde uygulanır.
  static String? _dropNarrowVowel(String w) {
    if (w.length < 4) return null;
    const vowels = 'aeiou';
    const narrow = 'iu';
    final last = w[w.length - 1];
    final mid = w[w.length - 2];
    final before = w[w.length - 3];
    if (vowels.contains(last)) return null;
    if (!narrow.contains(mid)) return null;
    if (vowels.contains(before)) return null;
    // Kökte başka bir ünlü kalmalı, yoksa kelime tanınmaz hâle gelir.
    final head = w.substring(0, w.length - 2);
    if (!head.split('').any(vowels.contains)) return null;
    return head + last;
  }

  /// FTS5 sorgusu. Her kelime için kökler `OR`'lanır, kelimeler `AND`'lenir.
  ///
  /// Örnek: "sabır" → `(sabir* OR sabr*)`
  static String ftsQuery(String query) {
    final words = normalize(query).split(' ').where((w) => w.isNotEmpty);
    final groups = <String>[];
    for (final w in words) {
      final variants = stems(w).where((s) => s.length >= 2).toList()..sort();
      if (variants.isEmpty) continue;
      groups.add('(${variants.map((s) => '$s*').join(' OR ')})');
    }
    return groups.join(' AND ');
  }
}
