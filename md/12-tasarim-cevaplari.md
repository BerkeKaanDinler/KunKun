# 12 · Tasarımdan cevaplar — Talepler v1.0

**Yanıtlanan:** KUN · İlm-i Hâl · Tasarımdan Talepler v1.0 (9 Eylül 2026)
**Cevap sürümü:** 1.0 · 9 Eylül 2026

Her talep sırayla cevaplanıyor. Karar isteyen maddelerde önerin kabul edildiyse açıkça yazıyor; edilmediyse gerekçesi var.

---

## T1 · md/ klasörü — UTF-8 teslim ✅ ÇÖZÜLDÜ

Klasör zip olarak teslim edildi. Zip içindeki dosyalar UTF-8, panoya kopyalama adımı yok — aynı hasar tekrar üretilmez.

Doğrulama için üç dize (zip'ten çıkardıktan sonra bunları arayabilirsin):

| Dosya | Aranacak dize |
|---|---|
| `11-zikir-ekranlari.md` | `Kâğıt indeks` (ğ sağlam) |
| `11-zikir-ekranlari.md` | `سُبْحَانَ اللّٰهِ` (harekeli) |
| `05-tema-kagit-indeks.md` | `ölçek` |

Hazır zikir setinin dört Arapça metni tabloda tam ve harekeli:

| Sıra | Zikir | Arapça | Sayı |
|---|---|---|---|
| 1 | Sübhanallah | سُبْحَانَ اللّٰهِ | 33 |
| 2 | Elhamdülillah | الْحَمْدُ لِلّٰهِ | 33 |
| 3 | Allahu Ekber | اللّٰهُ أَكْبَرُ | 33 |
| 4 | Sübhanallah | سُبْحَانَ اللّٰهِ | 1 |

Serbest liste örnekleri (fixture için, dinî metin değil — kullanıcı kaydı örneği):

| Ad | Arapça |
|---|---|
| Sübhânallâhi ve bihamdihî | سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ |
| Hasbünallâhü ve ni'mel vekîl | حَسْبُنَا اللّٰهُ وَنِعْمَ الْوَكِيلُ |
| Yâ Latîf | يَا لَطِيفُ |

> Bu dosya da UTF-8. Aynı taşıma yolunu kullan.

---

## T2 · Logolar — SVG ⛔ KAYNAK GEREKİYOR, TASARIMDAN ÇIKMIYOR

Dürüst cevap: elimde logonun **vektör kaynağı yok**. Teslim edilen `logo/yuvarlak/*.png` dosyaları generatif olarak üretilmiş rasterlardır — 12 kollu gül penceresi, kemerli dış bant, iç içe halkalar, binlerce ince çizgi. Bunu SVG'ye çevirmek iki yoldan birine girer:

1. **Yeniden çizmek** — sadeleştirilmiş bir mark üretmek. Denedim; sonuç logonun kendisi değil, ona benzeyen başka bir işaret oldu. Teslim etmedim, sildim. Marka kimliğini tasarım tarafında sessizce değiştirmek doğru olmaz.
2. **Raster izlemek (auto-trace)** — bu desende on binlerce path üretir; dosya PNG'den büyük olur, `flutter_svg` ile 62 px'te çizmek de pahalıdır. Fayda yok.

**İhtiyacım olan:** logoyu üreten kaynak — çizim dosyası (AI/SVG/Figma) veya PNG'leri üreten script. Kaynak gelirse üç optik kademede (`≥96 px`, `40–95 px`, `<40 px`) SVG'ye çevirir, altı temayı `currentColor` ile tek dosyaya indiririm.

**Gelene kadar önerim — PNG'lerle devam et, iki gerekçeyle:**

- Dosyalar zaten elinde ve boyut kademeleri hazır: `logo/yuvarlak/<accent>.png` (halka merkezi, hero, kart) · `logo/ios/<tema>-1024.png` ve `-180.png` (ikon) · `logo/widget/ios-kucuk-<tema>-338.png`, `ios-orta-<tema>-720x338.png` (widget). Altı temanın hepsi mevcut.
- `flutter_svg` bağımlılığı gerekmez. Brief'in "minimum bağımlılık" ilkesi korunur, SVG kuralı için istisna açmaya da gerek kalmaz.

Sen yer/ölçek kaygısını "6 tema × çoklu boyut" olarak yazmışsın; PNG tarafında bu **6 dosya × 1 boyut** (yuvarlak mark) olarak duruyor, geri kalanı zaten platformun istediği ikon/widget boyutları. Yani sorun pratikte yok.

**Karar sende:** PNG ile ilerle (önerim) · veya vektör kaynağı bulup bana ilet, SVG'yi ben çevirsem.

---

## T3 · Fontlar ✅ KARAR VERİLDİ

**Arapça font: Amiri.** Gerekçenin aynısı bende de geçerli — hareke yerleşimi oturaklı, 15 px liste boyunda okunaklı kalıyor.

**İndirmeni onaylıyorum.** Google Fonts'tan OFL sürümlerini al; font dosyası göndermeyeceğim. Gereken kesitler:

| Font | Kesit | Nerede |
|---|---|---|
| Amiri | Regular 400 | Bütün Arapça metin |
| JetBrains Mono | Regular 400 · Bold 700 | Künyeler, sayaç rakamları, sure referansları |
| Libre Franklin | 400 · 600 · 700 | Kâğıt indeks — gövde |
| Spectral | 600 | Kâğıt indeks — başlıklar (34 / 27 / 23 px) |

Diğer beş tema sistem fontu kullanır; EB Garamond, Newsreader, DM Sans, Manrope ve Roboto **gömülmez** — bunlar tasarım dökümanının kendi tipografisiydi, uygulamanın değil.

İki ek not:

- Amiri'nin dikey metrikleri Latin fontlardan geniştir. Arapça satırlarda `line-height` 1.5'in altına düşmesin; sayaç ekranında 30–34 px Arapça için 1.5, listede 15 px için 1.45 doğrulandı.
- JetBrains Mono'da `tabular-nums` varsayılan; sayaç rakamı için ayrıca `fontFeatures` ayarı gerekmez.

---

## T4 · Widget önizleme zemini ✅ ÖNERİNE UY — SENTETİK GRADYAN

Duvar kâğıdı gömülmesin. Üç ekranın zemini token'lardan türetilecek:

```
zemin      : --hero-surface
katman 1   : radial-gradient(80% 70% at 24% 18%, rgba(255,255,255,.16) 0 42%, transparent 74%)
katman 2   : radial-gradient(70% 60% at 82% 88%, rgba(0,0,0,.5) 0 40%, transparent 76%)
karartma   : linear-gradient(180deg, rgba(0,0,0,.28) 0 22%, rgba(0,0,0,.05) 46%, rgba(0,0,0,.44) 100%)
```

Karartma gradyanı **korunuyor** — widget kartının beyaz metni onun üzerinde 4.5:1'i tutuyor, kaldırılırsa açık temalarda kontrast düşer.

Kâğıt indeks teması istisna: radyal katman yok, düz `--hero-surface`, karartma da yok (o temada zemin zaten açık ve widget kartı opak).

Mock'tan ayrılma kabul edilebilir; bu ekranlar "uygulama içi önizleme" olarak okunacak, gerçek widget değil. Ekran başlığına `ÖNİZLEME` künyesi eklenebilir — istersen ekle, tasarımda zorunlu değil.

---

## T5 · Kâğıt indeks · 15 Kur'an ekranı ✅ ÜRETİLDİ, BEKLEMEN GEREKMİYOR

Ekranlar teslim edildi: **`Kagit Indeks - Kuran Ekranlari.dc.html`** — 15 ekran, diğer beş temayla birebir aynı yapı.

Türetme ortak iskeletten yapıldı, uyguladığım kurallar:

| Kural | Değer |
|---|---|
| Cam kart → opak | `#F4F3EE` + 1 px `#E0DCD2` |
| `backdrop-filter` · `box-shadow` | tamamen kaldırıldı |
| Köşe | 26 / 22 / 18 / 14 → **4 px** (yuvarlak öğelerde 99 px korundu) |
| Aksan | `#1F7A5C` → `#2B4A5A` |
| Hero yüzeyi | aksanla aynı: `#2B4A5A` |
| Metin üçlüsü | `#1A1A17` · `rgba(26,26,23,.66)` · `rgba(26,26,23,.46)` |
| Yüzeyler | `--surface #EAE8E1` · `--raised #F4F3EE` · `--sunken #DCD9CE` |
| Tipografi | gövde Libre Franklin; 34 / 27 / 23 px başlıklar Spectral 600 |

Doğruladım: 15 çerçevede `backdrop-filter` sayısı **0**, ekran içi köşe yarıçapları yalnızca 2 / 4 / 99 px.

Riski sen de yazmışsın, kabul: bu 15 ekran mock'tan değil türetildi. Bölüm bölüm teslimde göster, birlikte geçelim. Referans karakter zikir setindeki aynı temanın 10 ekranı.

Kapsam tablosu güncellendi: **15 × 6 = 90 Kur'an ekranı**, 10 × 6 = 60 zikir ekranı.

---

## T6 · Boş ve hata durumları ✅ ÖNERİNE UY — ÇİZİLDİ

Desen aynen önerdiğin gibi. Teslim: **`Ekran Durumlari - Bos Hata Ses.dc.html`** — desen anatomisi altı temada, ardından etkilenen altı ekran.

```
zemin      : --surface-sunken
kenar      : 1 px --border
köşe       : --radius-md
yerleşim   : dikey ortalı, yatay dolgu 30 px, kart dolgusu 32/24 px, öğe arası 13 px
ikon       : 44 px, stroke --text-tertiary
başlık     : 17 px / 600, --text-primary, ortalı
açıklama   : 13.5 px / 1.55, --text-secondary, ortalı, text-wrap: pretty
aksiyon    : ikincil buton değerleri (cam kart + 52 px), yatay dolgu 22 px
```

Eklediğim iki kural:

1. **Ekran başlığı ve sekmeler her zaman korunur.** Yalnızca içerik alanı desenle değişir — kullanıcı nerede olduğunu kaybetmez. Kaydedilenler'de sekmeler görünür kalır; hangi sekmenin boş olduğu bilgi taşır.
2. **Aksiyon butonu kullanıcıyı bir sonraki adıma taşır**, metin rengi `--accent`. "Tekrar dene" yalnızca gerçek hatada çıkar ve metni `--text-primary` olur — hata butonu bir davet değil, bir onarım.

Altı ekranın metinleri (fixture'a birebir alınabilir):

| Ekran | Durum | Başlık | Açıklama | Aksiyon |
|---|---|---|---|---|
| Kategori | boş | Bu kategoride ayet yok | Kategori hazırlanıyor. Yakındaki başlıklardan devam edebilirsin. | Diğer kategoriler |
| Kaydedilenler | boş | Henüz kayıt yok | Bir ayeti okurken sağ üstteki işareti kullan; buraya düşer. | Ayetlere git |
| Serbest zikirlerim | boş | Kendi zikrin yok | Serbest zikirler sınırsız sayar. Hedef koymadan da kullanabilirsin. | Serbest zikir ekle |
| İstatistik | boş | Sayacak bir şey yok | İlk zikrini tamamladığında seri, günlük toplam ve grafik burada belirir. | Zikre başla |
| Tüm ayetler | hata | Liste yüklenemedi | Ayet verisi okunamadı. Yeniden denemek sorunu genelde çözer. | Tekrar dene |
| Arama | sonuç yok | Sonuç bulunamadı | "2:255" gibi bir referans veya sûre adı deneyebilirsin. | — |

İstatistik boş durumunda **seri kartı ve grafik hiç çizilmez** — sıfır dolu grafik yanlış okunur. Arama boş sonucunda aksiyon butonu yok; kullanıcı zaten arama alanının içinde.

Hiçbir metinde ağ, internet, bağlantı veya sunucu göndermesi yok.

---

## T7 · Ses kapalıyken alt band ✅ ÖNERİNE UY — BOŞLUK KAYDIRMA ALANINA

Karar: `audio == false` iken çubuk **hiç çizilmez**, boşalan ~76 px kaydırma alanına katılır. Pasif çubuk gösterilmez.

- Alt güvenli alan dolgusu korunur: **22 px** (döküm kökündeki değer).
- Liste/içerik kartı aşağı doğru uzar; hiçbir ekranda "eksik" hissi olmaz.
- Ses açıldığında çubuk aynı yere döner — **layout değişmez, yalnızca bileşen açılır**. Bu yüzden çubuğu içerik akışının bir parçası olarak değil, akışın sonuna eklenen ayrı bir bileşen olarak kur.

Etkilenen beş ekran: Tüm ayetler · Keşif · Kategori · Ayet odak · Karşılaştırma.

Bir istisna: **Ayet odak** ekranındaki alt kontrol çubuğu bir çalar değil, ayet gezinme çubuğudur (önceki / sonraki). Ses kapalıyken **ortadaki oynat butonu düşer, gezinme okları kalır** — çubuk tümden kaybolmaz. Diğer dört ekranda çubuk tamamen gitmeli.

Görsel karşılaştırma `Ekran Durumlari - Bos Hata Ses.dc.html` dosyasının son bölümünde: aynı ekranın ses açık ve kapalı hâli yan yana.

---

## T8 · Keşif — chip mi sekme mi ✅ İKİ CHIP · EKSEN SEÇİCİ

Chip'ler eksen seçicidir, aile filtresi değil. **İki chip: Hayattan · Kur'an'dan.**

"Tümü" eklemiyorum, iki gerekçeyle: eksen sayısı ikiyken "Tümü" üçüncü bir eksen gibi okunur ve karışık bir liste üretir; ayrıca iki eksenin kategori grupları farklı mantıkta düzenli (biri duygu/durum, diğeri sûre/tema) — birleşik liste ikisinin de düzenini bozar.

Görsel değerler dökümde tanımlı gibi kalıyor: aktif chip `--accent` zemin + `--on-accent` metin, köşe 10 px, pasif chip `--surface-raised`. Chip satırı yatay kaydırılabilir ama iki öğeyle taşma olmaz — satır sabit görünür.

Açılışta **Hayattan** seçili gelir; uygulamanın giriş noktası duygu/durum tarafı.

---

## T9 · `--glass-blur` token mı ✅ ÖNERİNE UY — TOKEN OLSUN

Token yap. 17 → **18 token**; radius üçlüsü tabloda tek satırda gösterildiği için sayım tutmuyordu, `--glass-blur` gerçekten eksikti.

| Tema | `--glass-blur` | Kod yolu |
|---|---|---|
| 01 Cam · gece yeşimi | 20 | BackdropFilter |
| 02 Cam · mürekkep moru | 20 | BackdropFilter |
| 03 Cam · kömür + bakır | 20 | BackdropFilter |
| 04 Cam · gece | 20 | BackdropFilter |
| 05 Kâğıt indeks | **0** | Opak — cam kod hiç çalışmaz |
| 06 Cam · yeşim (açık) | 20 | BackdropFilter |

Kademeli blur değerleri token değil, **kullanım yeri katsayısı** olarak kalsın:

| Yer | Değer |
|---|---|
| Standart cam kart | `--glass-blur` (20) |
| Yoğun katman · yapışkan başlık | 22 |
| İç içe kart (kart içinde kart) | 18 |
| Alt çalar çubuğu · kilit ekranı widget'ı | 24 |

Bunlar `--glass-blur` üzerinden çarpanla değil, doğrudan yazılsın (0.9× / 1.1× / 1.2× yuvarlatması 0 durumunda bozulur). `--glass-blur == 0` iken hepsi 0 kabul edilir ve opak yola geçilir — istediğin anahtar tam olarak bu.

Performans ölçümü kötü çıkarsa altı temanın `--glass-blur` değerini 0'a çekmek yeterli; opak yol Kâğıt indeks için zaten yazılmış olacak.

---

## T10 · `--accent-soft` ve `--danger` ✅ ÖNERİNE UY — KULLANILSIN

İkisi de ekranda karşılık bulsun. Yerleri:

**`--danger`** — üç yer:
1. Ayarlar 2 · silme satırı (metin rengi; satır zemini değişmez)
2. Kaydedilenler · sağa kaydırarak silme zemini (beyaz ikon + beyaz metin üstünde)
3. Serbest zikirlerim · sağa kaydırarak silme zemini

Değerler: koyu temalarda `#FF6B5E`, açık temalarda `#B3261E`. Kaydırma zemininde `--danger` dolgu + `#FFFFFF` ikon/metin; her ikisinde de kontrast 4.5:1 üzerinde.

**`--accent-soft`** — iki yer:
1. Seçili chip zemini (Keşif eksen chip'leri **hariç** — onlar tam `--accent` kalır; aradaki fark eksen seçiminin daha güçlü bir durum olduğunu gösterir)
2. Rozet zemini: Kaydedilenler sekme sayacı, kategori ayet sayısı

`--accent-soft` üzerine yazılan metin `--accent` olur, `--on-accent` değil — yumuşak zemin şeffaf bir aksan tintidir, tam aksan değil.

Böylece 18 token'ın hepsi ekranda karşılık buluyor, ölü token kalmıyor.

---

## T11 · Esneme ve %135 metin ölçeği ✅ ÖNERİNE UY

Aynen: yatay kenar boşlukları sabit, yükseklikler esner, her ekran kaydırılabilir, metin ölçeği **0.85–1.35** arasına clamp'lenir, dokunma hedefi 44 × 44 px hiçbir koşulda küçülmez.

Sabit kalan yatay değerler:

| Öğe | px |
|---|---|
| Kart kenar boşluğu | 18 |
| Metin kenar boşluğu | 20 |
| Tam genişlik liste | 14 |
| Kart içi dolgu | 11–22 |

**Tesbih halkası** — önerdiğin ölçekleme doğru, formülü netleştiriyorum:

```
halkaÇapı  = min(ekranGenişliği − 36, dökümÇapı)      // 36 = 2 × 18 kenar boşluğu
ölçek      = halkaÇapı / dökümÇapı
boncukÇapı = round(dökümBoncuk × ölçek)                // 13 veya 12 px
yarıçap    = halkaÇapı/2 − boncukÇapı/2 − 6 × ölçek
merkezDisk = inset (boncukÇapı + 18 × ölçek)
```

Geometri birebir korunur: 33 boncuk · ilk boncuk −90° · adım 10.909° · saat yönünde · aktif boncuk +3 px × ölçek.

İki alt sınır ekliyorum:

- **Boncuk çapı 9 px'in altına düşmezse** halka küçülmesin, bunun yerine merkez disk küçülsün (sayı 52 → 40 px, logo 62 → 48 px). 9 px altında boncuklar birbirine girer ve tur okunmaz olur.
- **%135 metin ölçeğinde sayaç rakamı** 52 px'ten büyümesin (clamp'in üstünde ayrıca sabitlensin) — merkez diske sığmıyor. Diğer bütün metinler ölçekle büyür.

---

## Özet

| No | Talep | Durum |
|---|---|---|
| T1 | md/ orijinal UTF-8 | ✅ Zip olarak teslim |
| T2 | Logolar — SVG | ⛔ Vektör kaynak gerekiyor · PNG ile devam önerisi |
| T3 | Fontlar + Arapça font | ✅ Amiri · indirmeyi onaylıyorum |
| T4 | Widget önizleme zemini | ✅ Sentetik gradyan |
| T5 | Kâğıt indeks · 15 ekran | ✅ Üretildi, teslim edildi |
| T6 | Boş / hata deseni | ✅ Çizildi, teslim edildi |
| T7 | Ses kapalı alt band | ✅ Kaydırma alanına · Ayet odak istisnası |
| T8 | Keşif chip'leri | ✅ İki chip, eksen seçici |
| T9 | `--glass-blur` | ✅ Token · 18 token |
| T10 | `--accent-soft` / `--danger` | ✅ Kullanılsın, yerleri tanımlı |
| T11 | Esneme ve %135 | ✅ Onaylandı + iki alt sınır |

**Bölüm 1'i bloke eden madde kalmadı.** T3 kararı verildi, fontları indirebilirsin. Açık tek kalem T2 — logo vektör kaynağı; PNG'lerle ilerlemek Bölüm 1'i bloke etmiyor.

## Bu cevapla gelen dosyalar

| Dosya | İçerik |
|---|---|
| `md/` (zip) | Bu döküm, UTF-8 |
| `Kagit Indeks - Kuran Ekranlari.dc.html` | T5 · 15 ekran |
| `Ekran Durumlari - Bos Hata Ses.dc.html` | T6 + T7 · desen 6 temada, 6 ekran durumu, ses karşılaştırması |

## Dökümde güncellenenler

- `00-tasarim-sistemi.md` — kapsam 15 × 6 = 90 · `--glass-blur` token · metin ölçeği clamp
- Tema dosyaları (01–06) — `--glass-blur` satırı · `--accent-soft` ve `--danger` kullanım yerleri
- `10-kuran-ekranlari.md` — Kâğıt indeks artık tam · Keşif iki chip · ses kapalı davranışı
- `11-zikir-ekranlari.md` — boş durumlar · halka ölçekleme formülü
