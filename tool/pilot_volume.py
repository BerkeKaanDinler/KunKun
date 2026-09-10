#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""10 kategorilik pilot — gerçek veri hacmi ölçümü.

Mimari brief · "Veri hacmi": kategori tarafının hacmi bilinmiyor.
Ölçüm yöntemi: 10 kategorilik pilot — biri bol (Namaz), biri orta (Sabır),
biri kıt (Fil). Aday listeleri çıkarılıp sayılır, ortalama 160 ile çarpılır.

Bu betik **saymayı** yapar; aday listelerini üretmez. Aday listeleri
editoryal iştir — ayet seçimi dinî/editoryal karardır, betik uydurmaz.

Girdi biçimi (JSON):
    {
      "pilot": [
        {"categoryId": "H01", "name": "Namaz", "band": "bol",
         "verseIds": ["2:3", "2:43", ...]},
        ...
      ]
    }

Kullanım:
    python3 tool/pilot_volume.py --input data/pilot.json
    python3 tool/pilot_volume.py --template > data/pilot-sablon.json
"""

import argparse
import json
import statistics
import sys

TOTAL_CATEGORIES = 160
# Brief: bir ayet 5 kategoriye kadar bağlanabilir; eşleşme sayısı ile
# farklı ayet sayısı aynı şey değildir.
MAX_CATEGORIES_PER_VERSE = 5
QURAN_VERSES = 6236

TEMPLATE = {
    "_not": "Aday listeleri editoryaldir; bu dosyayı insan doldurur. "
            "verseIds 'sure:ayet' biçiminde.",
    "pilot": [
        {"categoryId": "H01", "name": "Namaz", "band": "bol", "verseIds": []},
        {"categoryId": "K06", "name": "Cennet", "band": "bol", "verseIds": []},
        {"categoryId": "G03", "name": "Rahmeti", "band": "bol", "verseIds": []},
        {"categoryId": "B02", "name": "Sabır", "band": "orta", "verseIds": []},
        {"categoryId": "B05", "name": "Şükür", "band": "orta", "verseIds": []},
        {"categoryId": "L02", "name": "Adalet", "band": "orta", "verseIds": []},
        {"categoryId": "A01", "name": "Kaygı", "band": "orta", "verseIds": []},
        {"categoryId": "P04", "name": "Fil", "band": "kıt", "verseIds": []},
        {"categoryId": "P02", "name": "Karınca", "band": "kıt", "verseIds": []},
        {"categoryId": "P03", "name": "Örümcek", "band": "kıt", "verseIds": []},
    ],
}


def report(data):
    pilot = data['pilot']
    filled = [p for p in pilot if p['verseIds']]
    if not filled:
        print('Aday listeleri boş — ölçüm yapılamaz.')
        print('Şablonu doldurup tekrar çalıştır: '
              'python3 tool/pilot_volume.py --template > data/pilot.json')
        return 1

    counts = [len(p['verseIds']) for p in filled]
    all_ids = [v for p in filled for v in p['verseIds']]
    distinct = len(set(all_ids))

    print(f'Pilot · {len(filled)}/{len(pilot)} kategori dolduruldu\n')
    print(f'{"kategori":22s} {"bant":6s} {"ayet":>5s}')
    print('-' * 36)
    for p in sorted(filled, key=lambda x: -len(x['verseIds'])):
        print(f'{p["name"]:22s} {p.get("band","?"):6s} {len(p["verseIds"]):>5d}')

    mean = statistics.mean(counts)
    median = statistics.median(counts)
    print('\nEşleşme sayısı')
    print(f'  ortalama            {mean:.1f}')
    print(f'  medyan              {median:.1f}')
    print(f'  toplam eşleşme      {len(all_ids)}')
    print(f'  farklı ayet         {distinct}')

    overlap = len(all_ids) / distinct if distinct else 1
    print(f'  ayet başına kategori {overlap:.2f}')

    est_mappings = mean * TOTAL_CATEGORIES
    est_distinct = est_mappings / max(overlap, 1.0)
    print('\n160 kategoriye ölçekleme')
    print(f'  tahmini eşleşme     {est_mappings:,.0f}')
    print(f'  tahmini farklı ayet {est_distinct:,.0f}'
          f'  (Kur\'an\'ın %{est_distinct / QURAN_VERSES * 100:.0f}\'i)')

    lo = est_distinct * 0.7
    hi = min(est_distinct * 1.4, QURAN_VERSES)
    print(f'  aralık (±%30)       {lo:,.0f} – {hi:,.0f}')

    print('\nUzman onay yükü')
    print(f'  onaylanacak eşleşme {est_mappings:,.0f}')
    print(f'  dakikada 4 eşleşme  {est_mappings / 4 / 60:,.0f} saat')

    if overlap > MAX_CATEGORIES_PER_VERSE:
        print(f'\n! ayet başına kategori {overlap:.1f} — brief\'in ~5 sınırının '
              'üstünde; eşleşmeler gözden geçirilmeli')
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--input')
    ap.add_argument('--template', action='store_true')
    args = ap.parse_args()

    if args.template:
        json.dump(TEMPLATE, sys.stdout, ensure_ascii=False, indent=2)
        print()
        return 0
    if not args.input:
        ap.error('--input veya --template gerekli')
    with open(args.input, encoding='utf-8') as f:
        return report(json.load(f))


if __name__ == '__main__':
    sys.exit(main())
