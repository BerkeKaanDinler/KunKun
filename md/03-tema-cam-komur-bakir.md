# 03 · Cam · kömür + bakır

**Mod:** koyu · cam
**Kur'an ekran seti:** `8c` — 15 ekran
**Zikir ekran seti:** `1c` — 10 ekran

Nötr kömür zemin, sıcak bakır aksan. İkincil metin .60, üçüncül .38 — diğer koyu temalardan bir tık düşük.

## Renk tokenları

| Token | Değer | Kullanım |
|---|---|---|
| `--surface` | `#121110` | Ekran zemini |
| `--surface-raised` | `#1C1A18` | Opak liste kartı, panel |
| `--surface-sunken` | `#171514` | Girinti, arama alanı, boş durum |
| `--border` | `rgba(255,255,255,.12)` | Opak kart kenarı |
| `--divider` | `rgba(255,255,255,.09)` | Liste satır ayracı |
| `--accent` | `#E0894A` | Birincil buton, aktif durum, Arapça metin |
| `--accent-soft` | `rgba(224,137,74,.14)` | Aksan zeminli rozet / seçili chip *(türetilmiş)* |
| `--on-accent` | `#10100F` | Aksan üstündeki metin ve ikon |
| `--text-primary` | `#F2EDE7` | Başlık, gövde |
| `--text-secondary` | `rgba(242,237,231,.60)` | Alt metin, açıklama |
| `--text-tertiary` | `rgba(242,237,231,.38)` | Künye, dipnot, pasif ikon |
| `--track` | `rgba(242,237,231,.14)` | Boş boncuk, boş grafik çubuğu, kapalı switch |
| `--hero-surface` | `#2B211A` | Ana sayfa "Bugünün ismi" ve istatistik seri kartı |
| `--danger` | `#FF6B5E` | Silme, geri alınamaz işlem *(türetilmiş)* |
| `--glass-fill` | `rgba(255,235,215,.07)` | Cam kart dolgusu |
| `--glass-border` | `rgba(255,225,200,.14)` | Cam kart kenarı |
| `--glass-blur` | `20` | `backdrop-filter: blur()` — 0 ise opak yola geçilir |
| `--radius-lg / md / sm` | `22 / 18 / 14` px | Hero ve birincil kart / liste kartı / buton, alan |

`--accent-soft` seçili chip ve rozet zemininde, `--danger` silme satırı ve kaydırarak silme zemininde kullanılır (T10 kararı). Diğer tüm değerler tasarım dosyalarından birebir alınmıştır.

## Tipografi

Gövde ailesi: `system-ui, -apple-system, sans-serif`

| Rol | px | Ağırlık | Not |
|---|---|---|---|
| Ekran başlığı | 34 | 700 | `letter-spacing: -.02em` |
| Bölüm başlığı | 27 | 700 | |
| Kart başlığı | 19–23 | 700 | |
| Liste satırı | 16.5–17 | 600 | |
| Gövde | 15–17.5 | 400 | `line-height: 1.5` |
| Alt metin | 12.5–13.5 | 400 | `line-height: 1.45–1.55` |
| Künye | 11–11.5 | 400–700 | JetBrains Mono, `.10–.14em`, büyük harf |
| Sayaç rakamı | 40–52 | 700 | `tabular-nums` |
| Arapça | 15 (liste) / 30–34 (sayaç) | 400 | `dir="rtl"`, renk `--accent` |

## Bileşenler — çözülmüş değerler

**Cam kart**
```css
background: rgba(255,235,215,.07);
border: 1px solid rgba(255,225,200,.14);
border-radius: 18px;          /* hero/birincil kartta 22px, buton ve alanda 14px */
backdrop-filter: blur(20px);      /* yoğun katmanlarda 22px, iç içe kartlarda 18px, çalar çubuğunda 24px */
-webkit-backdrop-filter: blur(20px);
```

**Opak liste kartı**
```css
background: #1C1A18;
border: 1px solid rgba(255,255,255,.12);
border-radius: 22px;
```
Satır ayracı: `border-bottom: 1px solid rgba(255,255,255,.09)` — son satırda yok.

**Birincil buton / aksan kart**
```css
background: #E0894A;
color: #10100F;
border-radius: 22px;        /* tam genişlik buton: 14px, min-height 56px */
box-shadow: 0 14px 30px rgba(0,0,0,.5);
font-size: 17px; font-weight: 700;
```

**İkincil buton** — cam kart değerleri, `min-height: 52px`, metin `#F2EDE7` 16 px / 600.

**Rozet (hedef sayısı, ∞, sure künyesi)**
```css
background: rgba(255,255,255,.06);
border: 1px solid rgba(255,225,200,.14);
border-radius: 8px;
padding: 5px 9px;
font-family: 'JetBrains Mono'; font-size: 11.5px;
color: rgba(242,237,231,.60);   /* hazır zikir: nötr */   |   #E0894A;   /* serbest ∞: aksan */
```

**Sekme (Hazır zikirler / Serbest)**
```css
/* kap    */ background: rgba(255,255,255,.07);
             border-radius: 12px; padding: 3px;
/* aktif  */ background: rgba(255,255,255,.13);
             color: #F2EDE7; font-weight: 600;
/* pasif  */ color: rgba(242,237,231,.60); font-weight: 500;
```

**Switch** — açık: `#E0894A` zemin, `#FFFFFF` topuz (51 × 31, topuz 25). Kapalı: `rgba(242,237,231,.14)` zemin.

**Hero kart** — `#2B211A` zemin, köşe 26 px, üzerine iki radyal katman:
```css
background:
  radial-gradient(80% 70% at 24% 18%, rgba(255,255,255,.16) 0 42%, transparent 74%),
  radial-gradient(70% 60% at 82% 88%, rgba(0,0,0,.5) 0 40%, transparent 76%);
```
Sağ üstte `logo/yuvarlak/E0894A-isik.png`, 188 px, opaklık %34. Hero üstündeki metin `#FFFFFF` ve `rgba(255,255,255,.74–.80)`

**Tesbih halkası**
```
dolu boncuk : #E0894A + box-shadow 0 0 10px rgba(255,255,255,.10)
boş boncuk  : rgba(242,237,231,.14)
dış çember  : 1px solid rgba(255,255,255,.08)   (serbest sayaçta dashed)
dalga       : 1px solid #E0894A, opacity .28
merkez disk : cam kart değerleri, border-radius 999px, logo E0894A-isik
```

## Varlıklar

| Amaç | Dosya |
|---|---|
| Halka merkezi / kart logosu | `logo/yuvarlak/E0894A-isik.png` |
| iOS kilit ekranı duvar kâğıdı | `logo/duvar/ios-kilit-bakir-1290x2796.png` |
| Android duvar kâğıdı | `logo/duvar/android-bakir-1440x3120.png` |
| Masaüstü duvar kâğıdı | `logo/duvar/pc-bakir-2560x1440.png` |
| Uygulama ikonu | `logo/ios/bakir-1024.png` · `logo/ios/bakir-180.png` |
| Küçük widget | `logo/widget/ios-kucuk-bakir-338.png` |
| Orta widget | `logo/widget/ios-orta-bakir-720x338.png` |

