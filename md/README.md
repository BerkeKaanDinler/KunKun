# KUN · İlm-i Hâl — tasarım dökümü

Altı tema. Bu klasör tasarımın koda geçirilebilir tam dökümüdür; tüm değerler tasarım dosyalarından çıkarılıp doğrulanmıştır.

| Dosya | İçerik |
|---|---|
| `00-tasarim-sistemi.md` | İskelet: kapsam, çerçeve, boşluk, tipografi ölçeği, token adları, yüzey davranışı, etkileşim |
| `01-tema-cam-gece-yesimi.md` | Cam · gece yeşimi — 17 token, tipografi, çözülmüş bileşen değerleri, varlıklar |
| `02-tema-cam-murekkep-moru.md` | Cam · mürekkep moru — 17 token, tipografi, çözülmüş bileşen değerleri, varlıklar |
| `03-tema-cam-komur-bakir.md` | Cam · kömür + bakır — 17 token, tipografi, çözülmüş bileşen değerleri, varlıklar |
| `04-tema-cam-gece.md` | Cam · gece — 17 token, tipografi, çözülmüş bileşen değerleri, varlıklar |
| `05-tema-kagit-indeks.md` | Kâğıt indeks · serbest — 17 token, tipografi, çözülmüş bileşen değerleri, varlıklar |
| `06-tema-cam-yesim-acik.md` | Cam · yeşim (açık) — 17 token, tipografi, çözülmüş bileşen değerleri, varlıklar |
| `10-kuran-ekranlari.md` | 15 Kur'an ekranının iskeleti |
| `11-zikir-ekranlari.md` | 10 zikir ekranının iskeleti + tesbih animasyon ve geometri spesifikasyonu |
| `12-tasarim-cevaplari.md` | **Talepler v1.0'a cevaplar — T1–T11** |

## Özet

- **Çerçeve:** 402 × 874 px, iOS.
- **Temalar:** 4 koyu cam (yeşim, mürekkep, bakır, gece) · 1 açık cam (yeşim) · 1 opak kâğıt indeks. Varsayılan **Cam · gece**.
- **Kur'an ekranları:** 15 × 6 tema = 90.
- **Zikir ekranları:** 10 × 6 tema = 60.
- **Zikir mantığı:** hazır tarafta yalnızca namaz sonrası seti (33 · 33 · 33 + kapanışta Sübhanallah 1); serbest tarafta kullanıcının kendi zikirleri sınırsız sayar.
- **Alt gezinme çubuğu yoktur.** Ana sayfa üç karta dallanır: Ayetler · Tüm ayetler · Zikir.

## Bu sürümde düzeltilenler

1. **Kaçak karakter:** Kur'an dosyasının beş ana sayfasında "Ayetler" kartının üstünde görünen fazladan `>` karakteri kaldırıldı.
2. **Token hizalaması:** zikir ekranlarının cam dolgusu, kart kenarı, satır ayracı, hero yüzeyi ve aksan üstü metin rengi Kur'an setinin kanonik değerlerine çekildi (mürekkep, bakır, gece ve açık yeşim temalarında farklıydı).
3. **Kapsam düzeltmesi:** Kâğıt indeks temasının Kur'an ekran seti bulunmadığı bu dökümde açıkça belirtildi.

## Açık kalem

**Logo vektör kaynağı (T2).** PNG'ler altı temada tam; SVG'ye çevirmek için logoyu üreten çizim dosyası veya script gerekiyor. Ayrıntı `12-tasarim-cevaplari.md` T2 bölümünde.
