# 06 · Cam · yeşim (açık)

**Mod:** açık · cam
**Kur'an ekran seti:** `6e` — 15 ekran
**Zikir ekran seti:** `1f` — 10 ekran

Açık cam: beyaz yüzeyler, koyu yeşil aksan. Hero yüzeyi aksandan bir kademe koyudur (#2A5F4C) ki beyaz metin 4.5:1 üzerinde kalsın.

## Renk tokenları

| Token | Değer | Kullanım |
|---|---|---|
| `--surface` | `#EEF4F1` | Ekran zemini |
| `--surface-raised` | `#FFFFFF` | Opak liste kartı, panel |
| `--surface-sunken` | `#E4EDE8` | Girinti, arama alanı, boş durum |
| `--border` | `rgba(30,70,58,.13)` | Opak kart kenarı |
| `--divider` | `rgba(30,70,58,.14)` | Liste satır ayracı |
| `--accent` | `#1F7A5C` | Birincil buton, aktif durum, Arapça metin |
| `--accent-soft` | `rgba(31,122,92,.12)` | Aksan zeminli rozet / seçili chip *(türetilmiş)* |
| `--on-accent` | `#FFFFFF` | Aksan üstündeki metin ve ikon |
| `--text-primary` | `#12241E` | Başlık, gövde |
| `--text-secondary` | `rgba(20,50,42,.64)` | Alt metin, açıklama |
| `--text-tertiary` | `rgba(20,50,42,.44)` | Künye, dipnot, pasif ikon |
| `--track` | `rgba(20,50,42,.14)` | Boş boncuk, boş grafik çubuğu, kapalı switch |
| `--hero-surface` | `#2A5F4C` | Ana sayfa "Bugünün ismi" ve istatistik seri kartı |
| `--danger` | `#B3261E` | Silme, geri alınamaz işlem *(türetilmiş)* |
| `--glass-fill` | `rgba(255,255,255,.70)` | Cam kart dolgusu |
| `--glass-border` | `rgba(255,255,255,.92)` | Cam kart kenarı |
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
background: rgba(255,255,255,.70);
border: 1px solid rgba(255,255,255,.92);
border-radius: 18px;          /* hero/birincil kartta 22px, buton ve alanda 14px */
backdrop-filter: blur(20px);      /* yoğun katmanlarda 22px, iç içe kartlarda 18px, çalar çubuğunda 24px */
-webkit-backdrop-filter: blur(20px);
box-shadow: 0 10px 26px rgba(0,0,0,.08);
```

**Opak liste kartı**
```css
background: #FFFFFF;
border: 1px solid rgba(30,70,58,.13);
border-radius: 22px;
```
Satır ayracı: `border-bottom: 1px solid rgba(30,70,58,.14)` — son satırda yok.

**Birincil buton / aksan kart**
```css
background: #1F7A5C;
color: #FFFFFF;
border-radius: 22px;        /* tam genişlik buton: 14px, min-height 56px */
box-shadow: 0 10px 26px rgba(0,0,0,.08);
font-size: 17px; font-weight: 700;
```

**İkincil buton** — cam kart değerleri, `min-height: 52px`, metin `#12241E` 16 px / 600.

**Rozet (hedef sayısı, ∞, sure künyesi)**
```css
background: rgba(20,50,42,.06);
border: 1px solid rgba(255,255,255,.92);
border-radius: 8px;
padding: 5px 9px;
font-family: 'JetBrains Mono'; font-size: 11.5px;
color: rgba(20,50,42,.64);   /* hazır zikir: nötr */   |   #1F7A5C;   /* serbest ∞: aksan */
```

**Sekme (Hazır zikirler / Serbest)**
```css
/* kap    */ background: rgba(20,50,42,.06);
             border-radius: 12px; padding: 3px;
/* aktif  */ background: #FFFFFF;
             color: #12241E; font-weight: 600;
             box-shadow: 0 2px 6px rgba(0,0,0,.10);
/* pasif  */ color: rgba(20,50,42,.64); font-weight: 500;
```

**Switch** — açık: `#1F7A5C` zemin, `#FFFFFF` topuz (51 × 31, topuz 25). Kapalı: `rgba(20,50,42,.14)` zemin.

**Hero kart** — `#2A5F4C` zemin, köşe 26 px, üzerine iki radyal katman:
```css
background:
  radial-gradient(80% 70% at 24% 18%, rgba(255,255,255,.16) 0 42%, transparent 74%),
  radial-gradient(70% 60% at 82% 88%, rgba(0,0,0,.5) 0 40%, transparent 76%);
```
Sağ üstte `logo/yuvarlak/1F7A5C-koyu.png`, 188 px, opaklık %34. Hero üstündeki metin `#FFFFFF` ve `rgba(255,255,255,.74–.80)`

**Tesbih halkası**
```
dolu boncuk : #1F7A5C + box-shadow 0 0 10px rgba(31,122,92,.28)
boş boncuk  : rgba(20,50,42,.14)
dış çember  : 1px solid rgba(20,50,42,.10)   (serbest sayaçta dashed)
dalga       : 1px solid #1F7A5C, opacity .28
merkez disk : cam kart değerleri, border-radius 999px, logo 1F7A5C-koyu
```

## Varlıklar

| Amaç | Dosya |
|---|---|
| Halka merkezi / kart logosu | `logo/yuvarlak/1F7A5C-koyu.png` |
| iOS kilit ekranı duvar kâğıdı | `logo/duvar/ios-kilit-kum-1290x2796.png` |
| Android duvar kâğıdı | `logo/duvar/android-kum-1440x3120.png` |
| Masaüstü duvar kâğıdı | `logo/duvar/pc-kum-2560x1440.png` |
| Uygulama ikonu | `logo/ios/kum-1024.png` · `logo/ios/kum-180.png` |
| Küçük widget | `logo/widget/ios-kucuk-kum-338.png` |
| Orta widget | `logo/widget/ios-orta-kum-720x338.png` |

> Bu tema duvar kâğıdı, ikon ve widget varlıklarını **kum** ailesiyle paylaşır.
