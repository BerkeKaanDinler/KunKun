# KUN · İlm-i Hâl

Kur'an-ı Kerim ayetlerini konularına göre sınıflandıran, **tamamen çevrimdışı**
çalışan Türkçe meal rehberi. Kullanıcı ya yaşadığı hâle göre (*Hayattan*) ya da
merak ettiği konuya göre (*Kur'an'dan*) 160 kategoriden birini seçip ilgili
ayetleri okur. Ayrıca bir tesbih/zikir modülü vardır.

**Hesap yok · sunucu yok · senkron yok · analytics yok.**

---

## Durum · Aşama 1 tamamlandı

25 ekranın tamamı kodlandı, altı temada çalışıyor, fixture veriyle baştan sona
gezilebilir.

| Set | Ekranlar |
|---|---|
| Giriş | Açılış · Tanıtım 1 · Tanıtım 2 · İsim |
| Ana | Ana sayfa · Keşif · Kategori · Ayet odak · Karşılaştırma |
| Liste | Tüm ayetler · Kaydedilenler |
| Ayarlar | Ayarlar 1 · Ayarlar 2 · Kaynaklar |
| Widget | Kilit ekranı · Ana ekran *(uygulama içi önizleme)* |
| Zikir | Z1–Z9 |

**Gerçek meal, Arapça metin ve Esmâ-i Hüsnâ verisi henüz tedarik edilmedi.**
Uygulama fixture (yer tutucu) veriyle çalışır; ekranlarda görünen ayet metinleri
meal değildir, uzunluk bantlarını temsil eden yer tutuculardır.

---

## İçerik bütünlüğü kuralı

Bu depoda **ayet metni, meal, sure/ayet numarası, Arapça metin veya dinî
açıklama üretilmez.** Veri yoksa alan boş bırakılır ve raporlanır. Kural
istisnasızdır.

- Fixture ayet metinleri açıkça yer tutucudur, künyeler `ÖRNEK 01:03`
  biçiminde sentetiktir
- Arapça alanlar `null`'dır — uydurma Arapça yoktur
- Zikir setinin Arapça metinleri tasarım dökümünden **birebir** alınmıştır
- Kategori eşleşmeleri editoryaldir, dinî hüküm değildir; uygulamada belirtilir
- Çevirmen adı ve meal sürümü ayet ekranında görünür — lisans şartı

---

## Mimari

```
lib/
  core/theme/     17 token + glassBlur · 6 tema · context.tokens
  core/ports/     AudioPort · AdsPort · SharePort · WidgetPort ·
                  HapticsPort · ClockPort  (V1'de çoğu NoOp)
  data/           repository arayüzleri · fixture ve JSON implementasyonları
  domain/         modeller · streak · Türkçe arama
  ui/             GlassSurface · token tabanlı bileşenler · TasbihRing
  features/       onboarding · home · discover · category · verse ·
                  compare · sequential · saved · settings · dhikr
```

**Repository kuralı:** feature katmanı Drift'e veya bir HTTP istemcisine
doğrudan dokunmaz. Fixture ve gerçek veri **aynı arayüzü** uygular; veri kaynağı
değiştiğinde yalnızca `data/` değişir, 25 ekranın hiçbirine dokunulmaz.

### İki veritabanı

| | Yazılabilir | İçerik |
|---|---|---|
| `content.db` | hayır | ayetler, mealler, kategoriler, zikirler |
| kullanıcı verisi | evet | kaydedilenler, serbest zikirler, sayaçlar, tercihler |

Kullanıcı tarafı **yalnızca `verseId` tutar, metin asla kopyalamaz** — meal
güncellendiğinde kayıtlar otomatik güncel kalır.

### Cam / blur stratejisi

Tasarımın altı temasından beşi cam. Flutter'da `BackdropFilter` kaydırılan
listede pahalıdır, o yüzden:

- Blur **yalnızca sabit yüzeylerde** (alt çubuk, hero, sheet)
- Kaydırılan liste kartları yarı saydam **düz renk**
- Her blur katmanı `RepaintBoundary` ile izole
- `glassBlur == 0` opak kod yolunu açar — Kâğıt indeks teması ve düşük
  segment düşürmesi aynı yolu kullanır

---

## Araçlar

```bash
# content.db üret + dört zorunlu kontrol + checksum
python3 tool/build_content_db.py --source assets/fixtures --out build/content.db

# gerçek veri modu: yer tutucu kaynaklara izin vermez
python3 tool/build_content_db.py --source data/gercek --out build/content.db --strict

# 10 kategorilik pilot · veri hacmi ölçümü
python3 tool/pilot_volume.py --template > data/pilot.json
python3 tool/pilot_volume.py --input data/pilot.json
```

Zorunlu build kontrolleri: **ayet sayısı doğrulaması** (besmele sayımı farkını
yakalar) · **kapsama raporu** · **lisans kaydı tamlığı** · **DB checksum**.

### Türkçe arama

`lib/domain/usecases/turkish_search.dart` ve `tool/turkish_search.py` **aynı
kuralları** uygular — biri sorguyu, diğeri indeksi üretir; bir test ikisinin
birebir aynı çıktı verdiğini doğrular.

Türkçe sondan eklemelidir: kullanıcı "sabır" arar, ayette "sabredenler" geçer.
Üç katman çözer:

1. Türkçeye özgü normalleştirme (`I→ı`, `İ→i`, şapkalı ve Türkçe harf katlama)
2. Ek soyucu + **ünlü düşmesi** (`sabır→sabr`) + **ünsüz yumuşaması** (`ışık→ışığ`)
3. Önek sorgusu: `sabır` → `(sabir* OR sabr*)`

38 sorgudan test seti `test/turkish_search_test.dart` içinde.

---

## Çalıştırma

```bash
flutter pub get
flutter run

flutter test                              # 153 test
flutter test --update-goldens test/golden # 46 golden görüntüsü
```

Ayarlar → **Geliştirici** bölümünde: hata modunu zorla (her ekranın hata
durumu), tema galerisi, blur bench, giriş akışını sıfırla.

---

## Kaynaklar

| Klasör | İçerik |
|---|---|
| `md/` | Tasarım dökümü — sistem, 6 tema token'ı, ekran iskeletleri |
| `design/` | Tasarım dosyaları (`.dc.html`) — ekranların kaynağı |
| `talepler/` | Ürün ve tasarım taleplerinin PDF'leri |
| `KARARLAR.md` | **Karar kaydı** — Ü1–Ü18, T1–T11 ve her birinin kodda nerede karşılık bulduğu |

Çelişki olursa mimari brief kazanır; `md/` iskelet dökümdür, `design/` ise
ekranların gerçek kaynağıdır.

---

## Sıradaki · Aşama 2

Gerçek şema · Drift repository'leri · FTS5 bağlantısı · gerçek veri gömme.
Dördünden üçü gerçek veri beklemez.

### Açık maddeler

- **Tesbihatın kapanışı** fıkhî bir meseledir; yayından önce bir din
  görevlisine doğrulattırılmalıdır (`KARARLAR.md` · Ü12)
- **Esmâ-i Hüsnâ 99 kayıt** tedarik edilmedi; ana sayfa hero'su yer tutucu
  durumda
- **Cam/blur ölçümü** gerçek bir orta segment Android cihazda yapılmadı
