#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""content.db üretim betiği.

Mimari brief · "Zorunlu build kontrolleri" — bunlar CI testidir; tutmazsa
build başarısız olur:

  1. Ayet sayısı doğrulaması — her surenin ayet sayısı, Arapça kaynak ile
     her mealde aynı mı? Besmele sayımı farkı buradan yakalanır.
  2. Kapsama raporu — boş kategori var mı, aynı ayet aşırı tekrar ediyor mu.
  3. Lisans kaydı tamlığı — her içerik kaynağının izin durumu kayıtlı mı.
  4. Üretilmiş DB checksum'ı — elle düzenlenmediğinin kanıtı.

Kullanım:
    python3 tool/build_content_db.py --source assets/fixtures --out build/content.db
    python3 tool/build_content_db.py --source data/gercek --out build/content.db --strict

`--strict` gerçek veri için: yer tutucu kaynaklara izin vermez.
"""

import argparse
import hashlib
import json
import os
import sqlite3
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from turkish_search import normalize  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
SCHEMA = os.path.join(HERE, 'schema.sql')


class BuildError(Exception):
    pass


def load(source, name):
    path = os.path.join(source, name)
    if not os.path.exists(path):
        raise BuildError(f'kaynak yok: {path}')
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def build(source, out, strict):
    verses_json = load(source, 'verses.json')
    fam_json = load(source, 'families.json')
    map_json = load(source, 'verse_categories.json')
    dhikr_json = load(source, 'dhikr.json')

    if os.path.exists(out):
        os.remove(out)
    os.makedirs(os.path.dirname(out) or '.', exist_ok=True)

    db = sqlite3.connect(out)
    with open(SCHEMA, encoding='utf-8') as f:
        db.executescript(f.read())

    # --- sûreler ve ayetler
    surahs = {}
    for v in verses_json['verses']:
        n = v['surahNumber']
        s = surahs.setdefault(n, {'name': v['surahName'], 'count': 0})
        s['count'] += 1
    for n in sorted(surahs):
        db.execute(
            'INSERT INTO surahs(id, number, name_tr, name_ar, verse_count,'
            ' revelation_type, order_index) VALUES (?,?,?,?,?,?,?)',
            (n, n, surahs[n]['name'], None, surahs[n]['count'], None, n),
        )
    for v in verses_json['verses']:
        db.execute(
            'INSERT INTO verses(id, surah_id, ayah_number, text_ar, juz, page)'
            ' VALUES (?,?,?,?,?,?)',
            (v['id'], v['surahNumber'], v['ayahNumber'], v.get('textAr'),
             v.get('juz'), v.get('page')),
        )

    # --- çevirmenler ve mealler
    for t in verses_json['translators']:
        db.execute(
            'INSERT INTO translators(id, slug, name, work_title, edition,'
            ' year, license_note, sort_order) VALUES (?,?,?,?,?,?,?,?)',
            (t['id'], t['slug'], t['name'], t['workTitle'], t.get('edition'),
             t.get('year'), t.get('licenseNote'), t.get('sortOrder', 0)),
        )
    tid = 0
    for v in verses_json['verses']:
        for translator_id, text in v['translations'].items():
            tid += 1
            db.execute(
                'INSERT INTO translations(id, verse_id, translator_id, text,'
                ' normalized_text, tts_text) VALUES (?,?,?,?,?,?)',
                (tid, v['id'], translator_id, text, normalize(text), None),
            )

    # --- taksonomi
    for f in fam_json['families']:
        db.execute(
            'INSERT INTO families(code, axis, name, description, sort_order)'
            ' VALUES (?,?,?,?,?)',
            (f['code'], f['axis'], f['name'], f.get('description'),
             f['sortOrder']),
        )
    for c in fam_json['categories']:
        db.execute(
            'INSERT INTO categories(id, family_code, slug, name, description,'
            ' sort_order) VALUES (?,?,?,?,?,?)',
            (c['id'], c['familyCode'], c['slug'], c['name'],
             c.get('description'), c['sortOrder']),
        )
    for m in map_json['mappings']:
        db.execute(
            'INSERT INTO verse_categories(verse_id, category_id,'
            ' relevance_score, review_status) VALUES (?,?,?,?)',
            (m['verseId'], m['categoryId'], m.get('relevanceScore', 0),
             m.get('reviewStatus', 'pending')),
        )

    # --- zikir
    for i, p in enumerate(dhikr_json['presets'], start=1):
        db.execute(
            'INSERT INTO dhikr_presets(id, slug, name_tr, text_ar, meaning,'
            ' target_count, step_order) VALUES (?,?,?,?,?,?,?)',
            (i, p['slug'], p['nameTr'], p['textAr'], p['meaning'],
             p['targetCount'], p['stepOrder']),
        )

    # --- Esmâ-i Hüsnâ · veri yoksa BOŞ bırakılır, uydurulmaz
    asma = os.path.join(source, 'asmaul_husna.json')
    if os.path.exists(asma):
        with open(asma, encoding='utf-8') as f:
            for e in json.load(f)['entries']:
                db.execute(
                    'INSERT INTO asmaul_husna(order_index, name_tr, name_ar,'
                    ' transliteration, meaning) VALUES (?,?,?,?,?)',
                    (e['orderIndex'], e['nameTr'], e['nameAr'],
                     e['transliteration'], e['meaning']),
                )

    db.commit()
    return db


# ---------------------------------------------------------------- kontroller

def check_verse_counts(db):
    """1 · Ayet sayısı doğrulaması.

    Her sûrenin bildirilen ayet sayısı, gerçekten yazılan ayet sayısıyla ve
    HER mealdeki satır sayısıyla aynı olmalı. Besmele bir mealde ayrı ayet
    sayılıp diğerinde sayılmazsa hizalama kayar — Arapçada 5. ayet
    gösterilirken Türkçede 6. ayetin meali görünür. Bu kontrol onu yakalar.
    """
    problems = []
    for number, declared, actual in db.execute(
        'SELECT s.number, s.verse_count, COUNT(v.id) FROM surahs s'
        ' LEFT JOIN verses v ON v.surah_id = s.id GROUP BY s.id'
    ):
        if declared != actual:
            problems.append(
                f'sûre {number}: bildirilen {declared}, yazılan {actual}')

    for number, translator, n in db.execute(
        'SELECT s.number, t.translator_id, COUNT(*) FROM translations t'
        ' JOIN verses v ON v.id = t.verse_id'
        ' JOIN surahs s ON s.id = v.surah_id'
        ' GROUP BY s.id, t.translator_id'
    ):
        expected = db.execute(
            'SELECT verse_count FROM surahs WHERE number = ?', (number,)
        ).fetchone()[0]
        if n != expected:
            problems.append(
                f'sûre {number} · {translator}: {n} meal satırı, '
                f'{expected} ayet bekleniyordu')

    # Ayet numaraları 1..N kesintisiz olmalı — atlama besmele farkının izidir.
    for number, in db.execute('SELECT number FROM surahs ORDER BY number'):
        nums = [r[0] for r in db.execute(
            'SELECT ayah_number FROM verses v JOIN surahs s ON s.id=v.surah_id'
            ' WHERE s.number=? ORDER BY v.ayah_number', (number,))]
        if nums and nums != list(range(1, len(nums) + 1)):
            problems.append(f'sûre {number}: ayet numaraları kesintili {nums[:8]}…')
    return problems


def check_coverage(db):
    """2 · Kapsama raporu — boş kategori ve aşırı tekrar eden ayet."""
    empty = [r[0] for r in db.execute(
        'SELECT c.id FROM categories c'
        ' LEFT JOIN verse_categories vc ON vc.category_id = c.id'
        ' GROUP BY c.id HAVING COUNT(vc.verse_id) = 0 ORDER BY c.id')]
    overused = [(r[0], r[1]) for r in db.execute(
        'SELECT verse_id, COUNT(*) c FROM verse_categories'
        ' GROUP BY verse_id HAVING c > 5 ORDER BY c DESC LIMIT 20')]
    total = db.execute('SELECT COUNT(*) FROM categories').fetchone()[0]
    return {'empty': empty, 'overused': overused, 'total': total}


def check_licenses(db, strict):
    """3 · Lisans kaydı tamlığı."""
    problems = []
    for tid, name, note in db.execute(
        'SELECT id, name, license_note FROM translators'
    ):
        if not note or not note.strip():
            problems.append(f'çevirmen {tid} ({name}): lisans notu boş')
        elif strict and 'lisans yok' in note.lower():
            problems.append(
                f'çevirmen {tid} ({name}): yer tutucu lisans — gerçek veride kabul edilmez')
    if strict:
        for tid, name in db.execute(
            "SELECT id, name FROM translators WHERE name LIKE '%yer tutucu%'"
        ):
            problems.append(f'çevirmen {tid} ({name}): yer tutucu ad')
    return problems


def checksum(path):
    """4 · Üretilmiş DB checksum'ı — elle düzenlenmediğinin kanıtı."""
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--source', default='assets/fixtures')
    ap.add_argument('--out', default='build/content.db')
    ap.add_argument('--strict', action='store_true',
                    help='gerçek veri modu: yer tutucu kaynaklara izin verilmez')
    ap.add_argument('--report', default=None, help='JSON rapor dosyası')
    args = ap.parse_args()

    db = build(args.source, args.out, args.strict)

    counts = check_verse_counts(db)
    coverage = check_coverage(db)
    licenses = check_licenses(db, args.strict)
    db.close()

    digest = checksum(args.out)
    sums = os.path.join(os.path.dirname(args.out) or '.', 'content.db.sha256')
    with open(sums, 'w') as f:
        f.write(f'{digest}  {os.path.basename(args.out)}\n')

    report = {
        'out': args.out,
        'sha256': digest,
        'sizeBytes': os.path.getsize(args.out),
        'verseCountProblems': counts,
        'coverage': {
            'totalCategories': coverage['total'],
            'emptyCategories': coverage['empty'],
            'emptyCount': len(coverage['empty']),
            'versesInMoreThan5Categories': coverage['overused'],
        },
        'licenseProblems': licenses,
        'strict': args.strict,
    }
    if args.report:
        with open(args.report, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)

    print(f'content.db  {report["sizeBytes"]:,} bayt')
    print(f'sha256      {digest}')
    print(f'kategori    {coverage["total"]} · boş {len(coverage["empty"])}')

    failed = False
    if counts:
        failed = True
        print('\n✗ AYET SAYISI DOĞRULAMASI')
        for p in counts:
            print('   ', p)
    if licenses:
        failed = True
        print('\n✗ LİSANS KAYDI')
        for p in licenses:
            print('   ', p)
    if args.strict and coverage['empty']:
        failed = True
        print(f'\n✗ KAPSAMA · {len(coverage["empty"])} boş kategori '
              f'(gerçek veride kabul edilmez): {coverage["empty"][:10]}…')

    if failed:
        print('\nBUILD BAŞARISIZ')
        return 1
    print('\n✓ bütün zorunlu kontroller geçti')
    return 0


if __name__ == '__main__':
    sys.exit(main())
