# KUN · İlm-i Hâl — Karar kaydı

Aşama 1 kodlanmadan önce kapatılan maddeler. Kod bu kararlara göre yazıldı;
değişirse bu dosya da güncellenir.

## Ürün kararları (Ü1–Ü18) · 9 Eylül 2026

| No | Karar | Kodda nerede |
|---|---|---|
| Ü1 | Ses kapalı → alt çalar çubuğu **hiç çizilmez** | `ui/feature_gate.dart` |
| Ü2 | Kaydedilenler tek sekme; Notlar **sonra kodlanacak** | `FeatureGate.savedTabs` |
| Ü3 | Ayarlar › KAYITLAR › "geçmiş" satırı **kaldırıldı** | Bölüm 5 |
| Ü4 | Esmâ-i Hüsnâ hero'su **kalıyor**; 99 isim verisi gelmedi → "veri bekleniyor" durumu | `Features.asmaulHusna`, `AwaitingDataPlaceholder` |
| Ü5 | Widget önizlemesine giriş Ayarlar › WIDGET'ten | `FeatureGate.showWidgetSettings` |
| Ü6 | Fixture metinleri brief'in 5 uzunluk bandı + `ÖRNEK VERİ` künyesi | Bölüm 2 |
| Ü7 | Künyeler `ÖRNEK 01:03` biçiminde | Bölüm 2 |
| Ü8 | Arama placeholder'ı nötrleştirildi | Bölüm 4 |
| Ü9 | Çevirmenler `Örnek Meal A/B (yer tutucu)` | Bölüm 2 |
| Ü10 | Deterministik eşleşme, **20 kategori kasıtlı boş** | Bölüm 2 |
| Ü11 | `md/` UTF-8 olarak teslim alındı; Arapça harekeler sağlam | `md/` |
| Ü12 | Hazır set tasarımdaki gibi; fıkhî doğrulama üründe, **açık madde** | Bölüm 6 |
| Ü13 | Seri kuralı: ≥1 zikir · yerel gece yarısı · `daily_stats`'ten türetilir · saat geri alınırsa ne kırılır ne şişer | `domain/usecases/streak.dart` |
| Ü14 | `indeks = (yerel gün + ofset) % havuz`, tek yerde | `core/daily_pick.dart` |
| Ü15 | Kalıcılık **JSON snapshot**; Drift Aşama 2'de | `data/local/json_store.dart` |
| Ü16 | Hata modu anahtarı (geliştirici bölümü) | `KunFailureKind.forced`, Bölüm 5 |
| Ü17 | Bundle `com.kun.kun` · uygulama adı **KUN** · online kararı ertelendi | `pubspec.yaml` |
| Ü18 | Drift Aşama 2'ye; Aşama 1 arayüz + fixture | `data/repositories/` |

## Tasarım cevapları (T1–T11) · md/12-tasarim-cevaplari.md

| No | Karar | Kodda nerede |
|---|---|---|
| T1 | `md/` UTF-8 zip olarak teslim edildi ✅ | `md/` |
| T2 | Logo **SVG kaynağı yok** → PNG ile devam, `flutter_svg` eklenmez. **PNG'ler henüz elimde değil** | açık |
| T3 | Arapça font **Amiri**; 4 font OFL indirildi | `assets/fonts/`, `LICENSES.md` |
| T4 | Widget önizleme zemini sentetik gradyan, karartma korunur | Bölüm 5 |
| T5 | Kâğıt indeks 15 Kur'an ekranı üretildi — **`.dc.html` dosyası elimde değil**, türetme kuralları var | açık |
| T6 | Boş/hata deseni + 6 ekranın metni | `ui/states.dart` · `KunStateCopy` |
| T7 | Ses kapalı → boşluk kaydırma alanına. **Ayet odak istisnası:** çubuk kalır, oynat düşer | `FeatureGate.verseFocusBar` |
| T8 | Keşif: **iki chip**, eksen seçici, açılışta Hayattan | `KunChip`, Bölüm 4 |
| T9 | `--glass-blur` **token** → 18 token. Kademeler mutlak px (18/20/22/24), 0 iken hepsi 0 | `core/theme/tokens.dart` · `GlassLayer` |
| T10 | `--danger` 3 yerde, `--accent-soft` 2 yerde; soft zemin üstü yazı `--accent` | `KunBadge.soft` |
| T11 | Yatay sabit · yükseklik esner · ölçek 0.85–1.35 · halka ölçekleme formülü · sayaç ≤52 px | `KunMetrics`, `KunTypography.counterMaxPx` |

## Açık maddeler

1. **T2 · logo varlıkları** — PNG'ler teslim edilmedi. Şu an token renkli
   geometrik yer tutucu kullanılacak (Bölüm 2/3).
2. **T5 · Kâğıt indeks `.dc.html`** — teslim edildiği yazıyor ama dosya gelmedi;
   türetme kuralları tabloda var, o kurallarla ilerlenebilir.
3. **T6/T7 · `Ekran Durumlari - Bos Hata Ses.dc.html`** — dosya gelmedi; desen
   ve metinler md'de tam olduğu için bloke değil.
4. **Ü4 · Esmâ-i Hüsnâ 99 kayıt** — veri yok, hero yer tutucu durumda.
5. **Ü12 · tesbihat kapanışı** — fıkhî doğrulama yayından önce yapılacak.
6. **Blur ölçümü** — bağlı Android cihaz yok; `/dev/blur-bench` hazır.

## Bölüm 2 · giriş akışı · notlar

- **Tanıtım metinleri bana ait.** Tasarım dökümü yalnızca yapı veriyor
  ("27 px başlık, 15 px açıklama"), metin yok. Yazdıklarım brief'in
  gerçeklerine dayanıyor (160 başlık, çevrimdışı, hesap yok) — değiştirmek
  istersen `intro_screen.dart` içindeki `_pages`.
- **Gizlilik cümlesi** İsim ekranında zorunlu (C10) ve testle kilitli.
- **3 noktalı gösterge**: döküm göstergeyi Tanıtım ekranlarında tarif ediyor.
  İsim ekranını üçüncü adım sayıp göstergeyi orada da sürdürdüm — akış
  3 adım olarak okunuyor. Aksi isteniyorsa `PageDots` çağrısı kaldırılır.
- **Logo yer tutucu** (T2 açık): `ui/logo_mark.dart`, token renkli geometrik
  işaret. Gerçek varlık gelince yalnızca o dosya değişir.
- **`HomePlaceholderScreen` geçicidir** — Bölüm 3'te gerçek ana sayfayla
  değiştirilip silinecek.

## Tasarım kaynağı · 9 Eylül 2026 · handoff zip

`iOS Kur'an Uygulaması Tasarımı-handoff.zip` ile gerçek tasarım dosyaları geldi.
`design/` klasöründe duruyorlar. Kapsam doğrulaması:

| Dosya | İçerik | Durum |
|---|---|---|
| `Temiz Secilen Temalar.dc.html` | **75 ekran** = 15 × 5 cam teması | ✅ tam |
| `Kagit Indeks - Kuran Ekranlari.dc.html` | **15 ekran** | ✅ tam |
| `Ekran Durumlari - Bos Hata Ses.dc.html` | boş/hata/ses karşılaştırması | ✅ geldi |
| `Zikir Ekranlari.dc.html` | zikir seti | ✅ geldi |
| `ios-frame.jsx` · token/teknik dökümanlar | — | ✅ geldi |
| `logo/yuvarlak/*.png` | 6 tema logosu, 512 px | ✅ gömüldü (T2 kapandı) |

**Bölüm 2, iskelet yerine gerçek tasarımdan yeniden yazıldı.** `md/10` bir
"iskelet" dökümüydü ve ekran dosyasıyla birkaç yerde çelişiyordu:

| Konu | `md/10` iskeleti | Gerçek tasarım | Uygulanan |
|---|---|---|---|
| Atlama | butonun altında "Şimdilik atla" bağlantısı | **sağ üstte "Atla"**, üç ekranda da | tasarım |
| Tanıtım başlığı | 27 px | **30 px** / 700 / `-.02em` | tasarım |
| Tanıtım gövdesi | 15 px | **17 px** / 1.55 | tasarım |
| Tanıtım görseli | 196 px hero + radyal katman | **154 px blok**, aksan %18 zemin, 118 px logo | tasarım |
| Tanıtım 2 | (tanımsız) | **ayet kartı önizlemesi** | tasarım · içerik yer tutucu |
| Açılış | logo + ad + künye | logo 132 · KUN 44/700 `.14em` · 64 px ayraç · "İlm-i Hâl" 21 px · lafza 26 px · künye `UYGULAMA ADI YER TUTUCU` | tasarım |
| İsim alanı | 52 px yükseklik | dolgu 16, köşe `--radius-sm` | tasarım |

### Açık kalan çelişkiler

1. **Tanıtım 2 · ayet kartı** — tasarım mock'unda gerçek bir meal ve gerçek bir
   `sure:ayet` referansı var. Ü6/Ü7 fixture politikası ve lisans kuralı
   (çevirmen künyesi olmadan meal gösterilemez) gereği yer tutucu kondu.
2. **Gizlilik cümlesi** — brief "yalnızca telefonunda saklanır" cümlesini birebir
   zorunlu kılıyor; tasarım aynı güvenceyi "Cihazından çıkmaz" diye veriyor.
   Brief kazandı, tasarımın cümle ritmi korundu.
3. **Kâğıt indeks logosu** — `md/05` `2B4A5A-koyu.png` diyor, tasarım dosyası
   `1F7A5C-koyu.png` kullanıyor (yeşim açıktan türetme izi). Temanın aksanına
   uyduğu için `2B4A5A-koyu.png` seçildi.
4. **Birincil buton ağırlığı** — tema dökümanları 700, giriş ekranı mock'u 600.
   Bileşen 700'de bırakıldı (uygulama geneli).

## Bölüm 3 · ana sayfa · notlar

Tasarım `1` çerçevesinden birebir: selamlama + iki 44 px ikon · hero 204/26 ·
günün ayeti cam kartı (blur 22) · esnek boşluk · Ayetler aksan kartı (24 px
başlık) · Tüm ayetler · Zikir.

- **Ü4 · hero yer tutucu durumda.** 99 isim verisi gelmedi; künye "BUGÜNÜN İSMİ"
  kalıyor, isim/anlam/Arapça **uydurulmuyor**. Veri gelince `asmaul_husna`
  dolar, hero kendiliğinden gerçek içeriğe geçer.
- **Ü1 · "Tüm ayetler" kartında oynat butonu çizilmiyor** — tasarımda 34 px
  yuvarlak aksan buton var, `audio == false` olduğu için düşüyor.
- **Günün ayeti kartı 4 satırda kırpılıyor.** Fixture'ın en uzun bandı
  (908 karakter) kırpılmazsa ekranı doldurup üç dallanma kartını dışarı itiyor;
  gerçek veride Bakara 282 aynı şeyi yapar. Paylaşım görselindeki "asla
  kırpılmaz" kuralı burayı kapsamaz, o kural paylaşım görseline aittir.
- **`FlexScreen`**: tasarım `overflow:hidden` + `flex:1` boşluk kullanıyor.
  Bunu birebir kopyalamak yerine ekran sığdığında aynı davranan, taştığında
  (küçük cihaz / %135 metin) kaydırılabilir olan bir kap yazıldı.
- **Fixture**: `assets/fixtures/verses.json` — 5 ayet, brief'in beş uzunluk
  bandında (58 · 124 · 246 · 512 · 908 karakter, doğrulandı), iki yer tutucu
  çevirmen. Arapça alanlar `null`.
- Ayarlar ikonu Bölüm 5'e kadar geliştirici ekranlarına açılıyor.

## Bölüm 4 · keşif → kategori · notlar

Tasarım `2` ve `3` çerçevelerinden.

### Fixture taksonomisi

- `families.json` — **16 aile, 160 kategori**, adlar brief taksonomisinden
  birebir. Hayattan 70 · Kur'an'dan 90 (testle doğrulandı).
- Aile açıklamaları **ilk dört kategori adından türetilir**, editoryal metin
  yazılmaz (tasarımda "Kaygı, korku, öfke, yalnızlık — taşımak zor olan haller."
  gibi elle yazılmış açıklamalar var; onları kopyalamak yerine türetildi).
- `verses.json` — 60 ayet, beş uzunluk bandı döngüsel (58 · 124 · 246 · 512 · 908).
- `verse_categories.json` — Ü10: 138 kategori dolu, **22 kategori kasıtlı boş**,
  P ailesinde Fil/Karınca/Örümcek 1–3 ayet.
  **Not:** brief "bir ayet en fazla ~5 kategoriye bağlanır" diyor; bu gerçek
  veri için bir hacim tahmini. Fixture 60 ayetle 138 kategoriyi doldurduğu için
  bu sınır uygulanmadı, ayetler tekrar kullanılıyor.

### `md/10` iskeletiyle yeni çelişkiler

| Konu | `md/10` iskeleti | Gerçek tasarım | Uygulanan |
|---|---|---|---|
| Keşif · alt çalar çubuğu | "en altta cam çalar çubuğu (blur 24)" | **yok** | tasarım |
| Kategori başlığı | 34 px | **27 px** | tasarım |
| Eksen chip'i (pasif) | — | zemin yok, 1 px `--border` kenar | tasarım |

### Test altyapısı — bir tuzak

`testWidgets` gövdesinde `rootBundle` ile varlık okumak **askıda kalıyor**:
fake-async gerçek I/O'yu ilerletmiyor, `pumpAndSettle` hiç dönmüyor.
Fixture'lar `setUpAll` içinde gerçek async ile bir kez yükleniyor, testler
önbellekten okuyor. Sonraki bölümlerde de bu kalıp kullanılmalı.

## Test altyapısı · iki kural (acı deneyimle)

1. **`testWidgets` gövdesinde varlık okuma (`rootBundle`) testi asar.**
   Fake-async gerçek I/O'yu ilerletmez; `pumpAndSettle` hiç dönmez ve
   `flutter_tester` süreci kilitlenir. Fixture'lar `setUpAll` içinde gerçek
   async ile bir kez yüklenir, testler önbellekten okur, cache sıfırlanmaz.
2. **Bu ağaçta `pumpAndSettle` kullanılmaz.** Görsel/varlık akışları
   "settle" durumuna gelmiyor. Sabit sayıda `pump` (bkz. `_tick`) hem yeterli
   hem deterministik.

## Yama disiplini

Python `str.replace` ile yama üç kez **sessizce boşa gitti** çünkü `dart format`
yapıcıları çok satıra çevirmişti ve desen tutmadı. Bundan sonra her yamada
`assert s.count(old) == 1` var; tutmazsa betik patlıyor.

## Bölüm 5 · notlar

Ekranlar: Tüm ayetler · Kaydedilenler · Ayarlar 1 · Ayarlar 2 · Kaynaklar ·
iki widget önizlemesi.

### `md/10` iskeletiyle çelişkiler — gerçek tasarım kazandı

| Konu | İskelet | Gerçek tasarım |
|---|---|---|
| Tüm ayetler | "uzun ayet listesi" | **sûre listesi**, ilk sûre açık, içinde ayet satırları |
| Kaydedilenler 2. sekme | "Notlar" | **"Konular"** |
| Ayarlar 2 · 1. grup | "KAYITLAR (kaydedilenler, **geçmiş**, dışa aktar)" | **"KAYDEDİLENLER" (dışa aktar, içe aktar)** |
| Tema satırı | KİŞİSEL grubunda | **OKUMA grubunda** |
| WIDGET grubu | 3 satır (kilit, ana ekran, yenileme) | 1 satır (ana ekran) |

**Ü3 kendiliğinden çözüldü:** "geçmiş" satırı gerçek tasarımda hiç yok.

### Açık kalan iki nokta

1. **Kaydedilenler'in "Konular" sekmesi.** Tasarımda var; şemada karşılığı yok
   (`saved_verses` var, kayıtlı kategori tablosu yok) ve brief `notes = false`
   ile tek sekme istiyor. Şimdilik tek sekme, çubuk gizli. Konular istenirse
   `saved_categories` tablosu gerekir.
2. **Tema satırı.** Tasarımda "Açık · Koyu · Sistem" yazıyor; brief altı temanın
   değiştiricisini istiyor. Satır altı temayı listeleyen bir alt sheet açıyor.

### Diğer

- `JsonStore.write` artık **bloke etmiyor**: 120 ms'lik debounce future'ı
  `await` edilince fake-async testlerde kilitleniyordu. Diske indiğinden emin
  olmak için `flush()` var.
- Kaydetme yalnızca `verseId` + `savedAt` + `sourceCategoryId` yazıyor;
  **metin asla kopyalanmıyor** (referans bütünlüğü) — testle kilitli.
- Ayarlar'daki geliştirici bölümü Ü16 hata modu anahtarını, tema galerisini,
  blur bench'i ve giriş akışı sıfırlamayı barındırıyor.
- Widget önizlemeleri T4'e göre sentetik zeminle çiziliyor, `ÖNİZLEME` künyesi
  taşıyor.

## Bölüm 6 · zikir modülü · notlar

Z1–Z9 kodlandı. Z0 zaten ana sayfanın üçüncü kartıydı.

### Hazır set — sabit ve testle kilitli

`assets/fixtures/dhikr.json` doğrudan `md/11-zikir-ekranlari.md` tablosundan
üretildi: Sübhanallah 33 · Elhamdülillah 33 · Allahu Ekber 33 · kapanışta
Sübhanallah 1. Arapça metinler harekeli ve birebir.

Testler şunları kilitliyor:
- dört adım, sayılar `[33, 33, 33, 1]`, adlar birebir
- her adımın Arapça metni **harekeli** (0x64B–0x652 aralığında işaret var)
- serbest zikir eklemek hazır seti **etkilemiyor**
- hazır set kullanıcı deposuna **hiç yazılmıyor** (content/user ayrımı)

Arayüzde preset ekleme/silme/güncelleme metodu yok — yazma yolu mimari
olarak kapalı.

### Sayaç mantığı

- **Hazır:** sayaç hedefte durur, `completed` olur, sıradaki adıma devreder.
  33'ün üstüne çıkmaz (testli).
- **Serbest:** hedef yok, sayaç durmaz, halka `count % 33` ile başa döner,
  tur sayacı `count ~/ 33 + 1`. 70 sayımda 3. tur (testli).
- Her sayımda hafif titreşim; hedefte başarı titreşimi; serbest tarafta
  her 33'te çift titreşim (kullanıcı ayarına bağlı).
- Sayımlar `daily_stats`'e yazılır, **seri oradan türetilir** (Ü13).

### Halka geometrisi — tasarımla birebir

Formül `md/11`'den: 33 boncuk · ilk boncuk −90° · adım 360/33 = 10.909° ·
yarıçap `size/2 − boncuk/2 − 6` · dış çember `inset boncuk+2` ·
merkez disk `inset boncuk+18`.

Tasarım dosyasındaki mutlak boncuk konumlarıyla doğrulandı:
ilk boncuk `left:146.5 top:6.0`, ikinci `left:173.1 top:8.5` — testte
`closeTo` ile kilitli.

T11 alt sınırları: boncuk 9 px altına inmez (halka küçülmez, merkez disk
küçülür), sayaç rakamı 52 px'i aşmaz.

`prefers-reduced-motion` açıkken ölçek ve dalga kapanır, renk geçişi kalır.

### Z9 · kilit ekranı widget'ı

Tasarımdaki beyaz `+1` pill'i çizilir ama **pasiftir**. Sayacı kilit
ekranından artırmak etkileşimli widget gerektirir (iOS 17+ App Intents,
App Group ile paylaşılan durum) — Aşama 3, `Features.lockWidget = false`.

### Açık madde — Ü12

Tesbihatın kapanışı fıkhî bir meseledir. Tasarımdaki "kapanışta Sübhanallah 1"
kodlandı; yayından önce bir din görevlisine doğrulattırılması gereken madde
**hâlâ açık**. Değişirse tek fixture satırı değişir, kod değişmez.

## Aşama 2 ön koşulları · tamamlandı

### `tool/schema.sql` · content.db şeması

Brief'in şemasının tamamı + FTS5 sanal tablosu ve tetikleyicileri.
`translations` yazıldıkça `verses_fts` kendiliğinden güncellenir.
Tokenizer `unicode61 remove_diacritics 2`; Türkçe'ye özgü sorunlar
tokenizer'a değil **`normalized_text` kolonuna** bırakıldı.

### `tool/build_content_db.py` · üretim betiği + 4 zorunlu kontrol

| Kontrol | Ne yapar |
|---|---|
| Ayet sayısı | Sûrenin bildirdiği sayı = yazılan ayet = **her mealdeki satır sayısı**. Ayrıca ayet numaraları 1..N kesintisiz mi. **Besmele sayımı farkını buradan yakalar.** |
| Kapsama | Boş kategori listesi, 5'ten fazla kategoriye bağlı ayetler |
| Lisans | Her çevirmenin `license_note` alanı dolu mu; `--strict`'te yer tutucu reddedilir |
| Checksum | SHA-256, `content.db.sha256` dosyasına yazılır |

`--strict` gerçek veri modudur: yer tutucu çevirmen adı, yer tutucu lisans
notu veya boş kategori varsa build başarısız olur.

`test/content_db_test.dart` bunları CI testi olarak koşar (6 test), ayrıca
**üretimin deterministik** olduğunu doğrular — aynı kaynaktan iki üretim aynı
checksum'ı vermezse checksum elle düzenlemeyi değil betiğin kararsızlığını
yakalar, o yüzden bu ayrıca test edilir.

### Türkçe arama · çözüldü

`lib/domain/usecases/turkish_search.dart` + `tool/turkish_search.py` —
**aynı kurallar, iki dilde**. Test ikisinin çıktısını karşılaştırır; ayrışırlarsa
arama sessizce bozulacağı için bu kritik.

Üç katman:
1. **normalize** — Türkçe'ye özgü küçültme (`I→ı`, `İ→i`; Dart'ın kendi
   `toLowerCase()`'i burada yanılır), şapkalı/Türkçe harf katlama, noktalama.
2. **stems** — muhafazakâr ek soyucu + iki morfofonemik kural:
   · **ünlü düşmesi**: `sabır → sabr`, `isim → ism`, `zulüm → zulm`
   · **ünsüz yumuşaması**: `ışık → ışığ`, `kitap → kitab`, `ümit → ümid`
3. **ftsQuery** — köklerden önek sorgusu: `sabır` → `(sabir* OR sabr*)`

Asıl problem çözüldü: **"sabır" arayan "sabredenler"i buluyor.**
FTS5 üzerinde uçtan uca doğrulandı.

`test/turkish_search_test.dart` · **38 sorgudan test seti** (brief 30–40
istiyordu): ünlü düşmesi, noktalı/noktasız I, şapkalı harfler, Türkçe harfler,
çekim ekleri, kategori adları, kesme işareti, çok kelimeli sorgular.

### `tool/pilot_volume.py` · 10 kategorilik pilot

Aday listelerini **üretmez** — ayet seçimi editoryal karardır, betik uydurmaz.
Şablonu doldurulunca sayar: bant bant dağılım, ortalama/medyan, ayet başına
kategori, 160'a ölçekleme, Kur'an'ın yüzde kaçı, ±%30 aralık ve **uzman onay
yükü saat cinsinden**. Şablon `data/pilot-sablon.json` (Namaz/Cennet/Rahmeti
bol · Sabır/Şükür/Adalet/Kaygı orta · Fil/Karınca/Örümcek kıt).

### Kaydedilenler · "Konular" sekmesi eklendi

Tasarımın ikinci sekmesi kodlandı. `saved_categories` yalnızca kategori
kimliği tutar, ad kopyalanmaz — ayetlerdeki referans bütünlüğü kuralının aynısı.
Kategori ekranının sağ üstüne kaydet düğmesi geldi. Notlar sekmesi
`Features.notes` ile üçüncü sekme olarak eklenecek (Aşama 3).

## Simülatör turu sonrası düzeltmeler

Ekranlar elle gezildi, hem ekran görüntüleri hem çalışma zamanı günlüğü izlendi.
Ayrıca **tasarım dosyalarındaki bütün metinler kodla otomatik karşılaştırıldı**
(`.dc.html` → metin çıkarımı → kaynak taraması) — göz kararı değil.

### Bulunan ve düzeltilen hatalar

| # | Sorun | Düzeltme |
|---|---|---|
| 1 | Widget önizlemelerinde geri düğmesi ve `ÖNİZLEME` künyesi durum çubuğunun altında kalıyordu | Üç önizleme ekranına `SafeArea` |
| 2 | Ayarlar'da "Kayıtlar, kişisel, hakkında" satırı kartsız, boşlukta duruyordu | Kendi grubuna alındı |
| 3 | Z5'te seri kartı **hiç yoktu** | Tasarımdaki değerleriyle eklendi: 38 px aksan yuvarlağı, "N günlük seri", bugünün dökümü, 7 çubuklu mini grafik |
| 4 | Ayet odakta 10–18 kategori çipi çıkıyordu (tasarımda 4) | Fixture'da "bir ayet en fazla 5 kategori" normu geri kondu; ayet sayısı 200'e çıkarıldı ki 138 kategori yine dolsun |
| 5 | Z2/Z4 adımlayıcı etiketleri kırpılıyordu | Ad ve sayı alt alta, 10 px |
| 6 | Ayet odakta uzun meal başlığa ve alt çubuğa yapışıyordu | Kaydırma alanına alt dolgu |

### Tasarımda olup uygulamada olmayan, sonradan eklenenler

- **Z4 · "SONRAKİ · X · N / otomatik" cam satırı** — hiç yoktu
- **Z8 · "EN ÇOK YAPILAN" listesi** — hiç yoktu; serbest kayıtlarda `SERBEST`
  rozeti, sağda sayı `--accent`
- **Kategori ekranı açıklama satırı** — tasarımda başlığın altında var
  (fixture'da boş olduğu için veri gelene kadar çizilmez)
- **Ana sayfa Zikir kartı** — "Tesbih sayacı · N günlük seri" artık gerçek
  seriden geliyor; beş noktalı ilerleme son beş günün kaçında zikir olduğunu
  gösteriyor (sabit 0 değil)
- **Z5 serbest zikir satırlarında anlam** — "Sabah zikri", "Zor günlerde",
  "Bugünün ismiyle" (md/11'in parantez içi notları)

### Tasarımın metnine döndürülenler

| Ekran | Önceki | Tasarımdaki |
|---|---|---|
| Z3 | "1. adım" | "Setin ilk adımı" / "Setin son adımı" |
| Z6 | hazırla aynı ipucu | "Sınırsız sayar; halka her 33'te başa döner, sıfırlamak sana bağlı" |
| Z7 açıklama | "Kendi zikrini ekle…" | "Serbest zikirler sınırsız sayar; hedef yok…" |
| Z7 titreşim | "Her 33'te çift titreşim" | "Her dokunuşta titreşim" |
| Tüm ayetler | "Baştan sona, sırayla." | "Fâtiha'dan Nâs'a, sırayla." |
