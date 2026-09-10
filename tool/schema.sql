-- content.db · SALT OKUNUR
--
-- Mimari brief · Veri modeli. Bu şema `tool/build_content_db.py` tarafından
-- uygulanır ve üretilen dosya uygulamaya gömülür. Kullanıcı verisi buraya
-- ASLA yazılmaz — o taraf user.db'dir.
--
-- Kararlı ID stratejisi:
--   ayet     sure:ayet    (ör. 2:255)
--   aile     tek harf     A–P
--   kategori A01–P10 + slug
-- Başlık, çeviri metni veya sıra numarası asla foreign key olmaz.

PRAGMA foreign_keys = ON;

CREATE TABLE surahs (
  id             INTEGER PRIMARY KEY,
  number         INTEGER NOT NULL UNIQUE,
  name_tr        TEXT    NOT NULL,
  name_ar        TEXT,
  verse_count    INTEGER NOT NULL,
  revelation_type TEXT,
  order_index    INTEGER NOT NULL
);

CREATE TABLE verses (
  id           TEXT PRIMARY KEY,          -- 'sure:ayet'
  surah_id     INTEGER NOT NULL REFERENCES surahs(id),
  ayah_number  INTEGER NOT NULL,
  text_ar      TEXT,                      -- veri yoksa NULL, uydurulmaz
  juz          INTEGER,
  page         INTEGER,
  UNIQUE (surah_id, ayah_number)
);

CREATE TABLE translators (
  id           TEXT PRIMARY KEY,
  slug         TEXT NOT NULL UNIQUE,
  name         TEXT NOT NULL,
  work_title   TEXT NOT NULL,
  edition      TEXT,
  year         INTEGER,
  license_note TEXT,                      -- lisans kaydı tamlığı buradan denetlenir
  sort_order   INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE translations (
  id              INTEGER PRIMARY KEY,
  verse_id        TEXT NOT NULL REFERENCES verses(id),
  translator_id   TEXT NOT NULL REFERENCES translators(id),
  text            TEXT NOT NULL,
  normalized_text TEXT NOT NULL,          -- aramada kullanılır, ekranda gösterilmez
  tts_text        TEXT,
  UNIQUE (verse_id, translator_id)
);

CREATE TABLE families (
  code        TEXT PRIMARY KEY,           -- 'A'..'P'
  axis        TEXT NOT NULL CHECK (axis IN ('hayattan','kurandan')),
  name        TEXT NOT NULL,
  description TEXT,
  sort_order  INTEGER NOT NULL
);

CREATE TABLE categories (
  id          TEXT PRIMARY KEY,           -- 'A01'..'P10'
  family_code TEXT NOT NULL REFERENCES families(code),
  slug        TEXT NOT NULL,
  name        TEXT NOT NULL,
  description TEXT,
  sort_order  INTEGER NOT NULL,
  UNIQUE (family_code, sort_order)
);

CREATE TABLE verse_categories (
  verse_id        TEXT NOT NULL REFERENCES verses(id),
  category_id     TEXT NOT NULL REFERENCES categories(id),
  relevance_score INTEGER NOT NULL DEFAULT 0,
  context_warning TEXT,
  review_status   TEXT NOT NULL DEFAULT 'pending',
  PRIMARY KEY (verse_id, category_id)
);

CREATE TABLE aliases (
  id          INTEGER PRIMARY KEY,
  phrase      TEXT NOT NULL,
  category_id TEXT NOT NULL REFERENCES categories(id),
  weight      INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE dhikr_presets (
  id           INTEGER PRIMARY KEY,
  slug         TEXT NOT NULL UNIQUE,
  name_tr      TEXT NOT NULL,
  text_ar      TEXT NOT NULL,
  meaning      TEXT NOT NULL,
  target_count INTEGER NOT NULL,
  step_order   INTEGER NOT NULL
);

CREATE TABLE asmaul_husna (
  order_index     INTEGER PRIMARY KEY,    -- 1..99
  name_tr         TEXT NOT NULL,
  name_ar         TEXT NOT NULL,
  transliteration TEXT NOT NULL,
  meaning         TEXT NOT NULL
);

-- Arama · Türkçe için unicode61; noktalı/noktasız I davranışı normalize
-- edilmiş kolonda çözülür, tokenizer'a bırakılmaz.
CREATE VIRTUAL TABLE verses_fts USING fts5(
  normalized_text,
  content = 'translations',
  content_rowid = 'id',
  tokenize = "unicode61 remove_diacritics 2"
);

CREATE TRIGGER translations_ai AFTER INSERT ON translations BEGIN
  INSERT INTO verses_fts(rowid, normalized_text)
  VALUES (new.id, new.normalized_text);
END;

CREATE TRIGGER translations_ad AFTER DELETE ON translations BEGIN
  INSERT INTO verses_fts(verses_fts, rowid, normalized_text)
  VALUES ('delete', old.id, old.normalized_text);
END;

CREATE TRIGGER translations_au AFTER UPDATE ON translations BEGIN
  INSERT INTO verses_fts(verses_fts, rowid, normalized_text)
  VALUES ('delete', old.id, old.normalized_text);
  INSERT INTO verses_fts(rowid, normalized_text)
  VALUES (new.id, new.normalized_text);
END;

CREATE INDEX idx_verses_surah      ON verses(surah_id, ayah_number);
CREATE INDEX idx_translations_verse ON translations(verse_id);
CREATE INDEX idx_vc_category        ON verse_categories(category_id);
CREATE INDEX idx_vc_verse           ON verse_categories(verse_id);
CREATE INDEX idx_aliases_phrase     ON aliases(phrase);
