# 01 · Cam · gece yeşimi

**Mod:** koyu · cam
**Kur'an ekran seti:** `8a` — 15 ekran
**Zikir ekran seti:** `1a` — 10 ekran

Nane aksan, koyu yeşim zemin. Cam dolgusu aksanla aynı aileden (yeşil tint).

## Renk tokenları

| Token | Değer | Kullanım |
|---|---|---|
| `--surface` | `#0B1613` | Ekran zemini |
| `--surface-raised` | `#122019` | Opak liste kartı, panel |
| `--surface-sunken` | `#0F1B16` | Girinti, arama alanı, boş durum |
| `--border` | `rgba(255,255,255,.12)` | Opak kart kenarı |
| `--divider` | `rgba(255,255,255,.09)` | Liste satır ayracı |
| `--accent` | `#4FD1A5` | Birincil buton, aktif durum, Arapça metin |
| `--accent-soft` | `rgba(79,209,165,.14)` | Aksan zeminli rozet / seçili chip *(türetilmiş)* |
| `--on-accent` | `#10100F` | Aksan üstündeki metin ve ikon |
| `--text-primary` | `#E8F2EC` | Başlık, gövde |
| `--text-secondary` | `rgba(232,242,236,.62)` | Alt metin, açıklama |
| `--text-tertiary` | `rgba(232,242,236,.40)` | Künye, dipnot, pasif ikon |
| `--track` | `rgba(232,242,236,.14)` | Boş boncuk, boş grafik çubuğu, kapalı switch |
| `--hero-surface` | `#12332A` | Ana sayfa "Bugünün ismi" ve istatistik seri kartı |
| `--danger` | `#FF6B5E` | Silme, geri alınamaz işlem *(türetilmiş)* |
| `--glass-fill` | `rgba(140,220,190,.09)` | Cam kart dolgusu |
| `--glass-border` | `rgba(160,230,200,.16)` | Cam kart kenarı |
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
background: rgba(140,220,190,.09);
border: 1px solid rgba(160,230,200,.16);
border-radius: 18px;          /* hero/birincil kartta 22px, buton ve alanda 14px */
backdrop-filter: blur(20px);      /* yoğun katmanlarda 22px, iç içe kartlarda 18px, çalar çubuğunda 24px */
-webkit-backdrop-filter: blur(20px);
```

**Opak liste kartı**
```css
background: #122019;
border: 1px solid rgba(255,255,255,.12);
border-radius: 22px;
```
Satır ayracı: `border-bottom: 1px solid rgba(255,255,255,.09)` — son satırda yok.

**Birincil buton / aksan kart**
```css
background: #4FD1A5;
color: #10100F;
border-radius: 22px;        /* tam genişlik buton: 14px, min-height 56px */
box-shadow: 0 14px 30px rgba(0,0,0,.5);
font-size: 17px; font-weight: 700;
```

**İkincil buton** — cam kart değerleri, `min-height: 52px`, metin `#E8F2EC` 16 px / 600.

**Rozet (hedef sayısı, ∞, sure künyesi)**
```css
background: rgba(255,255,255,.06);
border: 1px solid rgba(160,230,200,.16);
border-radius: 8px;
padding: 5px 9px;
font-family: 'JetBrains Mono'; font-size: 11.5px;
color: rgba(232,242,236,.62);   /* hazır zikir: nötr */   |   #4FD1A5;   /* serbest ∞: aksan */
```

**Sekme (Hazır zikirler / Serbest)**
```css
/* kap    */ background: rgba(255,255,255,.07);
             border-radius: 12px; padding: 3px;
/* aktif  */ background: rgba(255,255,255,.13);
             color: #E8F2EC; font-weight: 600;
/* pasif  */ color: rgba(232,242,236,.62); font-weight: 500;
```

**Switch** — açık: `#4FD1A5` zemin, `#FFFFFF` topuz (51 × 31, topuz 25). Kapalı: `rgba(232,242,236,.14)` zemin.

**Hero kart** — `#12332A` zemin, köşe 26 px, üzerine iki radyal katman:
```css
background:
  radial-gradient(80% 70% at 24% 18%, rgba(255,255,255,.16) 0 42%, transparent 74%),
  radial-gradient(70% 60% at 82% 88%, rgba(0,0,0,.5) 0 40%, transparent 76%);
```
Sağ üstte `logo/yuvarlak/4FD1A5-isik.png`, 188 px, opaklık %34. Hero üstündeki metin `#FFFFFF` ve `rgba(255,255,255,.74–.80)`

**Tesbih halkası**
```
dolu boncuk : #4FD1A5 + box-shadow 0 0 10px rgba(255,255,255,.10)
boş boncuk  : rgba(232,242,236,.14)
dış çember  : 1px solid rgba(255,255,255,.08)   (serbest sayaçta dashed)
dalga       : 1px solid #4FD1A5, opacity .28
merkez disk : cam kart değerleri, border-radius 999px, logo 4FD1A5-isik
```

## Varlıklar

| Amaç | Dosya |
|---|---|
| Halka merkezi / kart logosu | `logo/yuvarlak/4FD1A5-isik.png` |
| iOS kilit ekranı duvar kâğıdı | `logo/duvar/ios-kilit-yesim-1290x2796.png` |
| Android duvar kâğıdı | `logo/duvar/android-yesim-1440x3120.png` |
| Masaüstü duvar kâğıdı | `logo/duvar/pc-yesim-2560x1440.png` |
| Uygulama ikonu | `logo/ios/yesim-1024.png` · `logo/ios/yesim-180.png` |
| Küçük widget | `logo/widget/ios-kucuk-yesim-338.png` |
| Orta widget | `logo/widget/ios-orta-yesim-720x338.png` |

