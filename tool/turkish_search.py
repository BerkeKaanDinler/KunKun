# -*- coding: utf-8 -*-
"""Türkçe arama normalleştirmesi — `lib/domain/usecases/turkish_search.dart`
ile BİREBİR aynı kurallar.

content.db'nin `normalized_text` kolonu buradan üretilir; uygulama aynı
kuralla sorgu üretir. İkisi ayrışırsa arama sessizce bozulur, o yüzden
`test/turkish_search_test.dart` iki uygulamanın çıktısını karşılaştırır.
"""

FOLD = {
    'â': 'a', 'ā': 'a', 'á': 'a', 'à': 'a',
    'î': 'i', 'ī': 'i', 'í': 'i', 'ı': 'i',
    'û': 'u', 'ū': 'u', 'ú': 'u', 'ü': 'u',
    'ö': 'o', 'ó': 'o', 'ô': 'o',
    'ç': 'c', 'ğ': 'g', 'ş': 's',
    'ʼ': '', '’': '', '‘': '', "'": '',
}

SUFFIXES = [
    'lerinden', 'larindan', 'lerinde', 'larinda', 'lerini', 'larini',
    'lerine', 'larina', 'lerin', 'larin', 'leri', 'lari',
    'imiz', 'iniz', 'umuz', 'unuz',
    'dan', 'den', 'tan', 'ten', 'nin', 'nun', 'in', 'un',
    'ler', 'lar', 'lik', 'luk', 'li', 'lu',
    'ci', 'cu', 'ce', 'ca',
    'da', 'de', 'ta', 'te', 'ya', 'ye', 'yi', 'yu',
    'im', 'um', 'si', 'su', 'si', 'i', 'e', 'a', 'u',
]

MIN_STEM = 3
VOWELS = 'aeiou'
NARROW = 'iu'


def _lower_tr(s: str) -> str:
    out = []
    for ch in s:
        if ch == 'I':
            out.append('ı')
        elif ch == 'İ':
            out.append('i')
        else:
            out.append(ch.lower())
    return ''.join(out)


def normalize(s: str) -> str:
    lowered = _lower_tr(s)
    out = []
    for ch in lowered:
        if ch in FOLD:
            out.append(FOLD[ch])
            continue
        if ('a' <= ch <= 'z') or ('0' <= ch <= '9'):
            out.append(ch)
        else:
            out.append(' ')
    return ' '.join(w for w in ''.join(out).split(' ') if w)


def _drop_narrow_vowel(w: str):
    if len(w) < 4:
        return None
    last, mid, before = w[-1], w[-2], w[-3]
    if last in VOWELS or mid not in NARROW or before in VOWELS:
        return None
    head = w[:-2]
    if not any(c in VOWELS for c in head):
        return None
    return head + last


def _soften_final(w: str):
    """Ünsüz yumuşaması: ışık → ışığ, kitap → kitab, ümit → ümid."""
    if len(w) < 3:
        return None
    soft = {'k': 'g', 'p': 'b', 't': 'd'}.get(w[-1])
    return None if soft is None else w[:-1] + soft


def stems(word: str):
    out = set()
    w = normalize(word)
    if not w:
        return out
    out.add(w)
    stem = w
    for suf in SUFFIXES:
        if len(stem) - len(suf) >= MIN_STEM and stem.endswith(suf):
            stem = stem[: len(stem) - len(suf)]
            out.add(stem)
            break
    for base in {w, stem}:
        d = _drop_narrow_vowel(base)
        if d:
            out.add(d)
    for base in set(out):
        soft = _soften_final(base)
        if soft:
            out.add(soft)
    return out


def fts_query(query: str) -> str:
    groups = []
    for w in normalize(query).split(' '):
        if not w:
            continue
        variants = sorted(s for s in stems(w) if len(s) >= 2)
        if variants:
            groups.append('(' + ' OR '.join(s + '*' for s in variants) + ')')
    return ' AND '.join(groups)


if __name__ == '__main__':
    import json
    import sys
    # Dart tarafıyla karşılaştırma için: her satır bir girdi, JSON çıktı.
    data = [l.rstrip('\n') for l in sys.stdin if l.strip()]
    print(json.dumps(
        {s: {'normalize': normalize(s),
             'stems': sorted(stems(s)),
             'fts': fts_query(s)} for s in data},
        ensure_ascii=False, indent=2))
