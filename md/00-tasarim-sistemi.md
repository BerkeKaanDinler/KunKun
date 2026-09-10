# 00 · Tasarım sistemi · genel

Tek iskelet, altı tema. Ekran yapısı, boşluklar, tipografi ölçeği ve etkileşimler bütün temalarda birebir aynı; temadan temaya yalnızca renk tokenları, köşe yarıçapı ve cam/opak yüzey davranışı değişir.

## Kapsam

| Set | Ekran | Tema | Toplam |
|---|---|---|---|
| Kur'an ekranları | 15 | 6 | 90 |
| Zikir ekranları | 10 | 6 | 60 |

Altı temanın hepsi iki sette de tamdır. Kâğıt indeks temasının Kur'an ekranları ortak iskeletten türetildi (`Kagit Indeks - Kuran Ekranlari.dc.html`) ve gözden geçirilmeyi bekliyor.

## Cihaz ve çerçeve

- Tasarım çerçevesi **402 × 874 px** (iPhone 16 Pro), `ios-frame.jsx`.
- Ekran kökü `padding: 58px 0 22px`; sayaç ekranlarında alt 26 px, açılış/onboarding 34 px. Üst 58 px durum çubuğu payı.
- Yatay kenar boşluğu: kart **18 px**, metin **20 px**; tam genişlik listelerde 14 px.
- Dikey ritim 9 / 12 / 14 / 16 / 20 px; kart içi dolgu 11–22 px.
- Minimum dokunma hedefi **44 × 44 px**; birincil buton 56, ikincil 52, liste satırı ≥ 60 px.

## Token adları

```css
:root {
  --surface;  --surface-raised;  --surface-sunken;
  --border;   --divider;
  --accent;   --accent-soft;     --on-accent;
  --text-primary; --text-secondary; --text-tertiary;
  --track;    --hero-surface;    --danger;
  --glass-fill; --glass-border;  --glass-blur;
  --radius-lg; --radius-md; --radius-sm;
}
```

`--glass-blur` tam token'dır: cam temalarda **20**, Kâğıt indeks'te **0**. Değer 0 iken cam kod yolu hiç çalışmaz, opak yüzeye geçilir — düşük segment cihazlarda blur'u kapatmak altı temanın `--glass-blur` değerini 0'a çekmekle olur.

Kullanım yeri katsayıları token değildir, doğrudan yazılır: standart cam kart `--glass-blur` · yoğun katman ve yapışkan başlık 22 · iç içe kart 18 · alt çalar çubuğu ve kilit ekranı widget'ı 24. `--glass-blur == 0` iken hepsi 0 kabul edilir.

Kurallar:
- Aksan zemin üzerine yazı her zaman `--on-accent` ile yazılır. Koyu temalarda bu `#10100F`, **Cam · gece** ve **Cam · yeşim (açık)** temalarında `#FFFFFF`, **Kâğıt indeks**'te `#F6F5F0`.
- Aksan renkli metin yalnızca `--surface` veya cam üzerinde kullanılır.
- `--danger` üç yerde kullanılır: Ayarlar 2 silme satırı (metin rengi), Kaydedilenler ve Serbest zikirlerim kaydırarak silme zemini (üstünde `#FFFFFF` ikon/metin).
- `--accent-soft` iki yerde kullanılır: seçili chip zemini (Keşif eksen chip'leri hariç — onlar tam `--accent`) ve rozet zemini. Üstüne yazılan metin `--accent` olur, `--on-accent` değil.
- Metin ölçeği 0.85–1.35 arasına clamp'lenir. Dokunma hedefi 44 × 44 px hiçbir koşulda küçülmez; sayaç rakamı %135'te de 52 px'i geçmez.

## Tipografi ölçeği

| Rol | px | Ağırlık | Not |
|---|---|---|---|
| Ekran başlığı | 34 | 700 | `letter-spacing: -.02em` |
| Bölüm başlığı | 27 | 700 | |
| Kart başlığı | 19–23 | 700 | |
| Liste satırı | 16.5–17 | 600 | |
| Gövde | 15–17.5 | 400 | `line-height: 1.5`, `text-wrap: pretty` |
| Alt metin | 12.5–13.5 | 400 | `line-height: 1.45–1.55` |
| Künye / etiket | 11–11.5 | 400–700 | JetBrains Mono, `.10–.14em`, büyük harf |
| Sayaç rakamı | 40–52 | 700 | `tabular-nums` |
| Arapça | 15 / 30–34 | 400 | `dir="rtl"`, renk `--accent` |

Yüklü aile seti: Spectral, EB Garamond, Newsreader, DM Sans, Libre Franklin, Manrope, JetBrains Mono, Roboto. Uygulama içi gövde beş temada sistem fontu; **Kâğıt indeks** Libre Franklin gövde + Spectral başlık kullanır.

## Yüzey davranışı

- **Cam temalar (01, 02, 03, 04, 06):** `--glass-fill` + 1 px `--glass-border` + `backdrop-filter: blur(20px)`. Blur yoğun katmanlarda 22 px, iç içe kartlarda 18 px, alt çalar çubuğunda 24 px. Açık cam temada ek olarak `box-shadow: 0 10px 26px rgba(0,0,0,.08)`.
- Cam dolgusunun tonu temaya göre değişir: yeşimde yeşil, mürekkepte mor, bakırda sıcak krem, **gece ve açık yeşimde nötr beyaz**.
- **Kâğıt indeks (05):** cam, blur ve gölge yoktur. Opak `--surface-raised`, 1 px `--border`, köşe 4 px.
- Liste kartı her temada opaktır; satır ayracı `--divider`, son satırda ayraç yok.

## Etkileşim

- Her sayımda `UIImpactFeedbackGenerator(.light)`; hedef tamamlanınca `.success`.
- Basılı tut: serbest zikir listesinde sıralama. Sağa kaydır: silme (`--danger`).
- `prefers-reduced-motion` açıkken ölçek ve dalga animasyonları kapanır, yalnızca renk geçişi kalır.

## Dosya haritası

| Dosya | İçerik |
|---|---|
| `00-tasarim-sistemi.md` | Bu dosya |
| `01-tema-cam-gece-yesimi.md` | Cam · gece yeşimi |
| `02-tema-cam-murekkep-moru.md` | Cam · mürekkep moru |
| `03-tema-cam-komur-bakir.md` | Cam · kömür + bakır |
| `04-tema-cam-gece.md` | Cam · gece |
| `05-tema-kagit-indeks.md` | Kâğıt indeks · serbest |
| `06-tema-cam-yesim-acik.md` | Cam · yeşim (açık) |
| `10-kuran-ekranlari.md` | 15 Kur'an ekranının iskeleti |
| `11-zikir-ekranlari.md` | 10 zikir ekranının iskeleti + tesbih animasyon spesifikasyonu |
| `12-tasarim-cevaplari.md` | Talepler v1.0'a cevaplar — T1–T11 |
