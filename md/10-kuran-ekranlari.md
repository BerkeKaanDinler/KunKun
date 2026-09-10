# 10 · Kur'an ekranları · iskelet

Kaynak: `Temiz Secilen Temalar.dc.html` (beş tema: `8a`, `8b`, `8c`, `6c`, `6e`) ve `Kagit Indeks - Kuran Ekranlari.dc.html` (`5a` — ortak iskeletten türetildi, gözden geçirilmeyi bekliyor). Altı temada tam set.

Dosyadaki ekran etiketleri sırayla:

| # | Etiket | Ekran |
|---|---|---|
| 1 | `0` | Açılış |
| 2 | `0b` | Tanıtım 1 |
| 3 | `0c` | Tanıtım 2 |
| 4 | `0d` | İsim (atlanabilir) |
| 5 | `1` | Ana sayfa |
| 6 | `8a/8b/8c/6c/6e` | Tüm ayetler · sırayla |
| 7 | `2` | Keşif |
| 8 | `3` | Kategori |
| 9 | `4` | Ayet odak |
| 10 | `5` | Karşılaştırma |
| 11 | `6` | Ayarlar · okuma, ses, widget |
| 12 | `6b` | Ayarlar · kayıtlar, kişisel, hakkında |
| 13 | `7` | Kaydedilenler |
| 14 | `8` | Kilit ekranı widget'ı |
| 15 | `8b` | Ana ekran widget'ı |

> Etiketler dosyada tema başına yinelenir (ör. hem "Tüm ayetler" hem "Ana ekran widget'ı" `8b` alabiliyor). Koda geçirirken yukarıdaki **# sırası** esas alınmalı.

---

## 1 · Açılış
Zemin `--surface`. Ortada logo ve altında uygulama adı; alt kenarda 11 px künye `--text-tertiary`. Başka öğe yok.

## 2–3 · Tanıtım 1 ve 2
Üstte 196 px hero (`--hero-surface` + iki radyal katman + %34 logo). Altında 27 px başlık, 15 px açıklama `--text-secondary`. Altta 3 noktalı sayfa göstergesi (aktif `--accent`) ve birincil buton.

## 4 · İsim (atlanabilir)
27 px başlık, 15 px açıklama. Tek metin alanı: 52 px, `--surface-raised`, odakta kenar `--accent`. Birincil buton "Başla"; altında 16 px / 600 `--accent` bağlantı "Şimdilik atla".

## 5 · Ana sayfa
1. Selamlama 17 px / 500 `--text-secondary`; sağda kaydedilenler ve ayarlar ikonu (44 × 44).
2. **Hero** 196 px, köşe 26 px: künye "BUGÜNÜN İSMİ · 99 İSİMDEN 69.", isim 29 px / 700 `#FFF` + Arapça 21 px, altında 12.5 px alt metin.
3. **Günün ayeti** cam kart (köşe 22 px, dolgu 16 / 17 px): künye + sure referansı `--accent`, 17.5 px ayet metni.
4. Esnek boşluk.
5. **Ayetler** aksan kartı (dolgu 22 / 21 px, köşe 22 px, gölge): 23 px başlık, 13 px alt metin, sağda ok.
6. **Tüm ayetler** cam kart (dolgu 16 / 19 px, köşe 18 px): 19 px başlık, 12.5 px alt metin, sağda 34 px yuvarlak oynat + ok.
7. **Zikir** cam kart: 20 px başlık, "Tesbih sayacı · 12 günlük seri", sağda 5 noktalı ilerleme (3 dolu `--accent`, 2 `--track`) + ok.

> Alt gezinme çubuğu yok; ana sayfa üç kartla dallanır.

## 6 · Tüm ayetler · sırayla
34 px başlık + 13 px açıklama. Arama alanı cam kart (köşe 14 px) — "Sûre veya ayet ara · '2:255'". Uzun liste: ayet numarası monospace, Arapça 15 px `--accent`, altında Türkçe. Altta cam çalar çubuğu (blur 22 px): 38 px aksan kare içinde oynat ikonu, sure künyesi, ilerleme çizgisi.

## 7 · Keşif
34 px "Ayetler". Arama cam kartı. **İki eksen chip'i: Hayattan · Kur'an'dan** (aktif `--accent` + `--on-accent`, köşe 10 px, pasif `--surface-raised`). Açılışta Hayattan seçili. "Tümü" chip'i yoktur — iki eksenin kategori düzeni farklı mantıkta, birleşik liste ikisini de bozar. Altında gruplar: her grup için cam başlık kartı + opak kart içinde kategori satırları (16.5 px ad, sağda sayı 13 px `--text-secondary`), satır ayracı `--divider`. En altta cam çalar çubuğu (blur 24 px).

## 8 · Kategori
Geri, 34 px kategori adı, 12.5 px alt metin. Ayet listesi opak kart: sure künyesi 11.5 px / 700 monospace, ayet metni 16 px; sağda kaydet ikonu. Altta cam mini çalar (blur 22 px).

## 9 · Ayet odak
Tam ekran okuma: üstte geri / kaydet / paylaş. Arapça 30–34 px `dir="rtl"`, altında 17 px Türkçe, 12.5 px meal notu. Etiket chip'leri (köşe 10 px, `--surface-raised`). Altta cam kontrol çubuğu: önceki · oynat (aksan yuvarlak) · sonraki.

## 10 · Karşılaştırma
Ayet künyesi üstte. İki meal kartı alt alta: üstte meal sahibi 11 px monospace `--text-tertiary`, altında 16 px metin. Altta 11 px dipnot: "Farklar çeviri tercihinden gelir; künyeler Ayarlar › Kaynaklar altında." Altta cam çubuk.

## 11 · Ayarlar · okuma, ses, widget
Gruplu liste; bölüm başlıkları 11 px / .12em büyük harf `--text-tertiary`. Satırlar opak kart içinde: sol etiket 16 px, sağda değer `--text-secondary` veya switch. Gruplar: **OKUMA** (yazı boyutu, Arapça göster, meal), **SES** (kıraat, otomatik oynat), **WIDGET** (kilit ekranı, ana ekran, yenileme).

## 12 · Ayarlar · kayıtlar, kişisel, hakkında
**KAYITLAR** (kaydedilenler, geçmiş, dışa aktar) · **KİŞİSEL** (isim, tema, bildirim saati) · **HAKKINDA** (sürüm, kaynaklar, gizlilik). Silme satırı `--danger`.

## 13 · Kaydedilenler
34 px başlık. Altında iki sekme (aktif `--accent` zemin, köşe 10 px): Ayetler | Notlar. Arama cam kartı. Opak kart içinde kayıt satırları: künye 11.5 px / 700, metin 16 px. Sağa kaydırma silme.

## 14 · Kilit ekranı widget'ı
`logo/duvar/ios-kilit-<tema>-1290x2796.png` + `linear-gradient(180deg, rgba(0,0,0,.28) 0 22%, rgba(0,0,0,.05) 46%, rgba(0,0,0,.44) 100%)`. Tarih 15 px / 500, saat 80 px / 300. Cam widget: `rgba(255,255,255,.14)`, kenar `rgba(255,255,255,.2)`, blur 22 px, köşe 16 px; 17 px logo + künye, altında 16 px günün ayeti.

## Ses kapalı davranışı · audio == false

Alt çalar çubuğu **hiç çizilmez**, boşalan ~76 px kaydırma alanına katılır; alt güvenli alan dolgusu 22 px korunur. Pasif çubuk gösterilmez. Ses açıldığında çubuk aynı yere döner — layout değişmez, bileşen açılır. Etkilenen ekranlar: Tüm ayetler · Keşif · Kategori · Ayet odak · Karşılaştırma.

İstisna — **Ayet odak**: alt çubuk bir çalar değil, ayet gezinme çubuğudur. Ses kapalıyken ortadaki oynat butonu düşer, önceki/sonraki okları kalır.

## Boş ve hata durumları

Desen ve altı ekranın metinleri `12-tasarim-cevaplari.md` T6 bölümünde; görsel karşılığı `Ekran Durumlari - Bos Hata Ses.dc.html`. Ekran başlığı ve sekmeler her durumda korunur, yalnızca içerik alanı desenle değişir.

## 15 · Ana ekran widget'ı
Aynı duvar kâğıdı üzerinde ikon ızgarası + orta boy widget (`logo/widget/ios-orta-<tema>-720x338.png` ölçüsü): solda isim/ayet, sağda logo. Küçük widget 338 px kare: yalnızca isim + sayı.
