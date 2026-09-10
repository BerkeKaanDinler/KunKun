# 11 · Zikir ekranları · iskelet

Kaynak: `Zikir Ekranlari.dc.html`. Altı temada tam set (`1a`–`1f`), tema başına 10 ekran.

| # | Kimlik | Ekran |
|---|---|---|
| 1 | Z0 | Ana sayfa · üçüncü buton (Zikir) |
| 2 | Z1 | Hazır · namaz sonrası listesi |
| 3 | Z2 | Hazır sayaç · hedef 33 |
| 4 | Z3 | Hedef tamamlandı |
| 5 | Z4 | Set akışı · 4 adım |
| 6 | Z5 | Serbest zikirlerim |
| 7 | Z6 | Serbest sayaç · sınırsız |
| 8 | Z7 | Serbest zikir ekle |
| 9 | Z8 | İstatistik ve seri |
| 10 | Z9 | Kilit ekranı widget'ı |

## İki akış

**Hazır · namaz sonrası** — tek sabit set:

| Sıra | Zikir | Arapça | Sayı | Anlam |
|---|---|---|---|---|
| 1 | Sübhanallah | سُبْحَانَ اللّٰهِ | 33 | Allah'ı her türlü eksiklikten tenzih ederim |
| 2 | Elhamdülillah | الْحَمْدُ لِلّٰهِ | 33 | Hamd, âlemlerin Rabbi Allah'a mahsustur |
| 3 | Allahu Ekber | اللّٰهُ أَكْبَرُ | 33 | Allah her şeyden büyüktür |
| 4 | Sübhanallah | سُبْحَانَ اللّٰهِ | 1 | Seti kapatan tek zikir · 99'un ardından |

Metin, anlam ve sayı değiştirilemez, silinemez. Sayaç hedefte durur, tamamlandı durumuna geçer, sıradaki adıma devreder. Künye: `HAZIR · 1/4 · HEDEF 33`.

**Serbest · sınırsız** — kullanıcının kendi zikirleri. Hedef yok, sayaç durmaz, halka her 33'te başa döner, sıfırlama kullanıcıya bırakılır. Rozet `∞` aksan renginde, künye `SERBEST · SINIRSIZ`. Listede basılı tutup sıralanır, sağa kaydırıp silinir. Yalnızca cihazda saklanır, yedeklenmez.

Örnek kayıtlar: Sübhânallâhi ve bihamdihî (sabah zikri) · Hasbünallâhü ve ni'mel vekîl (zor günlerde) · Yâ Latîf (bugünün ismiyle).

---

## 1 · Z0 · Ana sayfa · üçüncü buton
Mevcut ana sayfanın altına üçüncü cam kart: 19–20 px "Zikir", 12.5 px "Tesbih sayacı · 12 günlük seri", sağda 5 noktalı ilerleme (3 dolu `--accent`) + ok. Alt gezinme çubuğu eklenmez.

## 2 · Z1 · Hazır · namaz sonrası
1. Geri + istatistik ikonu (44 × 44); başlık "Zikir" 34 px.
2. **Sekme:** Hazır zikirler | Serbest.
3. **Sırayla başla** aksan kartı: 21 px başlık, "33 · 33 · 33 · kapanışta Sübhanallah 1", sağda ok.
4. Bölüm künyesi "NAMAZ SONRASI ZİKİRLERİ" + sayı **4**.
5. Opak kart, 4 satır: ad 17 px / 600 + Arapça 15 px `--accent`, altında anlam 12.5 px; sağda sayı rozeti + ok.
6. Dipnot 12 px `--text-tertiary`: "Namaz sonrası dört adım sabittir…"

## 3 · Z2 · Hazır sayaç · hedef 33
Künye `HAZIR · 1/4 · HEDEF 33`, sağda ayar ikonu. Üstte ortalı Arapça 34 px + anlam 14 px. Ortada **306 px halka**: 33 boncuk, 24 dolu, boncuk 13 px, merkez logo 62 px, sayı 24 / 33, alt künye "SÜBHANALLAH · 33". Altında ipucu. En altta üç cam buton: **Sıfırla · Sonraki · Titreşim**.

## 4 · Z3 · Hedef tamamlandı
266 px halka, 33/33 dolu, künye "TAMAMLANDI". 27 px "Hedef tamamlandı" + 15 px alt metin. Üç kolonlu cam şerit: bugün **166** · gün seri **12** · toplam **4.312** (üçüncüsü `--accent`). Birincil buton "Sonraki adım · Elhamdülillah 33"; altında cam buton "Sıfırla ve baştan başla".

## 5 · Z4 · Set akışı · 4 adım
Künye `NAMAZ SONRASI · 2/4`. 4 sütunlu adımlayıcı: 4 px çubuk + 11 px etiket (Sübhanallah 33 · Elhamdülillah 33 · Allahu Ekber 33 · Sübhanallah 1). Tamamlanan `--accent` %55, aktif tam opak + 700, bekleyen `--track`. Ortada 274 px halka. Altta "SONRAKİ · Allahu Ekber · 33" cam satırı; iki buton: Sıfırla · Seti bitir.

## 6 · Z5 · Serbest zikirlerim
Sekmede "Serbest" aktif. Seri kartı: 38 px aksan kare içinde 12, "12 günlük seri", "Bugün 166 zikir · 67'si serbest listenden", sağda 7 çubuklu mini grafik. Bölüm künyesi "KENDİ ZİKİRLERİM" + **3**. Satırlarda ad 15.5 px kendi satırında (kırpılmaz), altında Arapça, sonra anlam; rozet `∞` `--accent`. Altta "Serbest zikir ekle" cam butonu ve dipnot.

## 7 · Z6 · Serbest sayaç · sınırsız
Künye `SERBEST · SINIRSIZ` `--accent` renginde. Arapça 30 px, ad 15 px / 600, "Kendi zikrin · sınırsız sayar". 306 px halka: dış çember **kesikli**, 7 boncuk dolu, merkezde sayı **40** (hedef payı yok), künye "2. TUR · SINIRSIZ". Butonlar: **Sıfırla · 33'te uyar · Bitir**.

## 8 · Z7 · Serbest zikir ekle
Üstte İptal / Kaydet. 27 px "Serbest zikir" + açıklama. Alanlar: **ZİKRİN ADI** (dolu, kenar `--accent`, imleç) · **ARAPÇA METİN · İSTEĞE BAĞLI** (`dir="rtl"`, placeholder) · **TÜRKÇE ANLAM** (placeholder). **SAYAÇ** bölümü: cam satırda `∞` + "Sınırsız sayar. Hedef yok; sayacı istediğin an sıfırlarsın." Hedef seçimi yoktur. Titreşim switch'i açık ("Her 33'te çift titreşim"). Birincil buton "Serbest listeme ekle".

## 9 · Z8 · İstatistik ve seri
34 px "İstatistik". Hero: "KESİNTİSİZ SERİ", 46 px **12 gün**, alt metin en uzun seri. Cam kart: "SON 7 GÜN" + 561 zikir, 7 çubuk (120 px, bugünkü `--accent`). Üç kolon: hazır **99** · serbest **67** · toplam **4.312**. "EN ÇOK YAPILAN": sıra numarası monospace, ad, serbest kayıtlarda "SERBEST" rozeti, sağda sayı `--accent`.

## 10 · Z9 · Kilit ekranı widget'ı
Zemin (T4 kararı): duvar kâğıdı gömülmez — `--hero-surface` + iki radyal katman + karartma gradyanı. Saat 78 px / 600. Cam widget (`rgba(255,255,255,.16)`, kenar `rgba(255,255,255,.24)`, blur 24 px, köşe 20 px): 40 px logo, künye "ZİKİR · SÜBHANALLAH", 26 px sayı 24 / 33, 5 px ilerleme (%73), alt metin "Namaz sonrası seti · 1/4 adım", sağda beyaz `+1` pill butonu.

---

## Tesbih halkası · animasyon spesifikasyonu

Tasarım dosyasında logo sürekli, hafif bir nefes animasyonuyla duruyor:

```css
@keyframes zikirPulse  { 0%,100% { transform: scale(1); }  50% { transform: scale(1.045); } }
@keyframes zikirRipple { 0% { transform: scale(.94); opacity: .34; }  70%,100% { transform: scale(1.06); opacity: 0; } }
```

Uygulamada asıl davranış **dokunma anına** bağlanacak. Hedef değerler:

| Öğe | Davranış |
|---|---|
| Merkez logo | `scale(1 → 1.07 → 1)`, 160 ms, `cubic-bezier(.2,.8,.2,1)` |
| Dokunulan boncuk | 120 ms içinde 13 → 16 px, `--track` → `--accent` |
| Dalga | Boncuğun arkasında tek seferlik `zikirRipple`, 1 px `--accent`, opacity .28 |
| Titreşim | Her sayımda `UIImpactFeedbackGenerator(.light)`; hedefte `.success` |
| Tur | Her 33'te tur sayacı artar; logo tam dönüş yapmaz, 12° yaylanır |
| Erişilebilirlik | `prefers-reduced-motion`: ölçek ve dalga kapanır, yalnızca renk geçişi kalır |

Merkezdeki logo her temada o temanın varyantıdır (`logo/yuvarlak/`); animasyon hedefi `data-zikir-pulse="true"` ile işaretli.

## Boş durumlar

**Serbest zikirlerim** ve **İstatistik** ekranlarının boş durumu `12-tasarim-cevaplari.md` T6 bölümünde tanımlı. Hazır sekmesi hiç boşalmaz. İstatistik boş durumunda seri kartı ve grafik çizilmez — sıfır dolu grafik yanlış okunur.

## Halka geometrisi

```
kap          : size × size (306 / 274 / 266 px)
boncuk çapı  : 13 px (306), 12 px (274 ve 266)
yarıçap      : size/2 − boncuk/2 − 6
ilk boncuk   : −90° (saat 12), sonra 360/33 = 10.909° adımlarla saat yönünde
aktif boncuk : çap +3 px
dış çember   : inset boncuk+2
merkez disk  : inset boncuk+18
```

Dar ekranda ölçekleme (T11):

```
halkaÇapı  = min(ekranGenişliği − 36, dökümÇapı)
ölçek      = halkaÇapı / dökümÇapı
boncukÇapı = round(dökümBoncuk × ölçek)
yarıçap    = halkaÇapı/2 − boncukÇapı/2 − 6 × ölçek
merkezDisk = inset (boncukÇapı + 18 × ölçek)
```

Alt sınır: boncuk çapı 9 px'in altına düşecekse halka küçülmez, merkez disk küçülür (sayı 52 → 40 px, logo 62 → 48 px). %135 metin ölçeğinde sayaç rakamı 52 px'i geçmez.
