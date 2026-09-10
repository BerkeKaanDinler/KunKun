# 05 · Kâğıt indeks · serbest

**Mod:** açık · opak
**Kur'an ekran seti:** **yok** — bu tema yalnızca palet ve tipografi kartı olarak tanımlı (`1l`)
**Zikir ekran seti:** `1e` — 10 ekran

Arşiv/indeks mantığı: cam yok, blur yok, gölge yok. Keskin 4 px köşe, opak yüzeyler, görünür aile kodları, başlıklarda Spectral serif. Ek yüzey basamakları: #DCD9CE ve #D6D3C9.

## Renk tokenları

| Token | Değer | Kullanım |
|---|---|---|
| `--surface` | `#EAE8E1` | Ekran zemini |
| `--surface-raised` | `#F4F3EE` | Opak liste kartı, panel |
| `--surface-sunken` | `#DCD9CE` | Girinti, arama alanı, boş durum |
| `--border` | `#E0DCD2` | Opak kart kenarı |
| `--divider` | `#E0DCD2` | Liste satır ayracı |
| `--accent` | `#2B4A5A` | Birincil buton, aktif durum, Arapça metin |
| `--accent-soft` | `rgba(43,74,90,.12)` | Aksan zeminli rozet / seçili chip *(türetilmiş)* |
| `--on-accent` | `#F6F5F0` | Aksan üstündeki metin ve ikon |
| `--text-primary` | `#1A1A17` | Başlık, gövde |
| `--text-secondary` | `rgba(26,26,23,.66)` | Alt metin, açıklama |
| `--text-tertiary` | `rgba(26,26,23,.46)` | Künye, dipnot, pasif ikon |
| `--track` | `rgba(26,26,23,.14)` | Boş boncuk, boş grafik çubuğu, kapalı switch |
| `--hero-surface` | `#2B4A5A` | Ana sayfa "Bugünün ismi" ve istatistik seri kartı |
| `--danger` | `#B3261E` | Silme, geri alınamaz işlem *(türetilmiş)* |
| `--glass-fill` | `— (cam yok, opak #F4F3EE)` | Cam kart dolgusu |
| `--glass-border` | `#E0DCD2` | Cam kart kenarı |
| `--glass-blur` | `0` | `backdrop-filter: blur()` — 0 ise opak yola geçilir |
| `--radius-lg / md / sm` | `4 / 4 / 4` px | Hero ve birincil kart / liste kartı / buton, alan |

`--accent-soft` seçili chip ve rozet zemininde, `--danger` silme satırı ve kaydırarak silme zemininde kullanılır (T10 kararı). Diğer tüm değerler tasarım dosyalarından birebir alınmıştır.

## Tipografi

Gövde ailesi: `'Libre Franklin', system-ui, sans-serif`  ·  Başlıklar: Spectral serif (27 / 23 / 17), künyeler JetBrains Mono

| Rol | px | Ağırlık | Not |
|---|---|---|---|
| Ekran başlığı | 34 | 600 (Spectral) | `letter-spacing: -.01em` |
| Bölüm başlığı | 27 | 600 (Spectral) | |
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
/* Bu temada cam yoktur */
background: #F4F3EE;
border: 1px solid #E0DCD2;
border-radius: 4px;
```

**Opak liste kartı**
```css
background: #F4F3EE;
border: 1px solid #E0DCD2;
border-radius: 4px;
```
Satır ayracı: `border-bottom: 1px solid #E0DCD2` — son satırda yok.

**Birincil buton / aksan kart**
```css
background: #2B4A5A;
color: #F6F5F0;
border-radius: 4px;        /* tam genişlik buton: 4px, min-height 56px */
/* gölge yok */
font-size: 17px; font-weight: 700;
```

**İkincil buton** — cam kart değerleri, `min-height: 52px`, metin `#1A1A17` 16 px / 600.

**Rozet (hedef sayısı, ∞, sure künyesi)**
```css
background: #EAE8E1;
border: 1px solid #E0DCD2;
border-radius: 3px;
padding: 5px 9px;
font-family: 'JetBrains Mono'; font-size: 11.5px;
color: rgba(26,26,23,.66);   /* hazır zikir: nötr */   |   #2B4A5A;   /* serbest ∞: aksan */
```

**Sekme (Hazır zikirler / Serbest)**
```css
/* kap    */ background: #F4F3EE;
             border-radius: 4px; padding: 3px;
/* aktif  */ background: #2B4A5A;
             color: #F6F5F0; font-weight: 600;
/* pasif  */ color: rgba(26,26,23,.66); font-weight: 500;
```

**Switch** — açık: `#2B4A5A` zemin, `#FFFFFF` topuz (51 × 31, topuz 25). Kapalı: `rgba(26,26,23,.14)` zemin.

**Hero kart** — `#2B4A5A` zemin, köşe 4 px; düz renk, gradyan ve logo katmanı yok

**Tesbih halkası**
```
dolu boncuk : #2B4A5A + box-shadow 0 0 10px rgba(43,74,90,.25)
boş boncuk  : rgba(26,26,23,.14)
dış çember  : 1px solid #E0DCD2   (serbest sayaçta dashed)
dalga       : 1px solid #2B4A5A, opacity .28
merkez disk : cam kart değerleri, border-radius 999px, logo 2B4A5A-koyu
```

## Varlıklar

| Amaç | Dosya |
|---|---|
| Halka merkezi / kart logosu | `logo/yuvarlak/2B4A5A-koyu.png` |
| iOS kilit ekranı duvar kâğıdı | `logo/duvar/ios-kilit-kum-1290x2796.png` |
| Android duvar kâğıdı | `logo/duvar/android-kum-1440x3120.png` |
| Masaüstü duvar kâğıdı | `logo/duvar/pc-kum-2560x1440.png` |
| Uygulama ikonu | `logo/ios/kum-1024.png` · `logo/ios/kum-180.png` |
| Küçük widget | `logo/widget/ios-kucuk-kum-338.png` |
| Orta widget | `logo/widget/ios-orta-kum-720x338.png` |

> Bu tema duvar kâğıdı, ikon ve widget varlıklarını **kum** ailesiyle paylaşır.
