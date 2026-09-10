import 'package:flutter/widgets.dart';

import '../core/result.dart';
import '../core/theme/tokens_ext.dart';
import 'buttons.dart';
import 'icons.dart';
import 'metrics.dart';
import 'surfaces.dart';

/// T6 · Boş ve hata durumu için tek desen — ekran ekran kopyalanmaz.
///
/// Tasarım cevabının iki ek kuralı burada zorunlu kılınmıştır:
/// 1. **Ekran başlığı ve sekmeler her zaman korunur** — yalnızca içerik alanı
///    bu desenle değişir. Bu widget içerik alanına konur, ekranın tamamına değil.
/// 2. Aksiyon butonu kullanıcıyı bir sonraki adıma taşır ve metni `--accent`
///    olur. "Tekrar dene" yalnızca gerçek hatada çıkar, metni `--text-primary`:
///    hata butonu bir davet değil, bir onarımdır.
class KunStateView extends StatelessWidget {
  const KunStateView.empty({
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.icon = KunIcons.inbox,
    super.key,
  }) : isError = false;

  const KunStateView.error({
    required this.title,
    this.description,
    this.actionLabel = 'Tekrar dene',
    this.onAction,
    this.icon = KunIcons.warning,
    super.key,
  }) : isError = true;

  /// Hiçbir metinde ağ, internet, bağlantı veya sunucu göndermesi yoktur.
  factory KunStateView.fromFailure(KunFailure f, {VoidCallback? onRetry}) =>
      KunStateView.error(title: f.message, onAction: onRetry);

  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // Dikey ortalama **çağırana** aittir (ekranlar bunu `Expanded` içinde
    // `Center` ile sarar). Bileşen kendi doğal yüksekliğini alır; aksi hâlde
    // %135 metin ölçeğinde sabit yükseklikli kaplarda taşar.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: OpaqueCard(
        sunken: true,
        radius: t.radiusMd,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: KunMetrics.minTouch, color: t.textTertiary),
            const SizedBox(height: 13),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.type.listRow(t.textPrimary, size: 17),
            ),
            if (description != null) ...[
              const SizedBox(height: 13),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: context.type
                    .caption(t.textSecondary, size: 13.5)
                    .copyWith(height: 1.55),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 13),
              SecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
                // Onarım butonu davet değildir → aksan rengi kullanılmaz.
                labelColor: isError ? t.textPrimary : t.accent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// T6 · Ekran metinleri — fixture'a birebir alınmıştır.
class KunStateCopy {
  const KunStateCopy._();

  static const category = (
    title: 'Bu kategoride ayet yok',
    body: 'Kategori hazırlanıyor. Yakındaki başlıklardan devam edebilirsin.',
    action: 'Diğer kategoriler',
  );
  static const saved = (
    title: 'Henüz kayıt yok',
    body: 'Bir ayeti okurken sağ üstteki işareti kullan; buraya düşer.',
    action: 'Ayetlere git',
  );
  static const customDhikr = (
    title: 'Kendi zikrin yok',
    body: 'Serbest zikirler sınırsız sayar. Hedef koymadan da kullanabilirsin.',
    action: 'Serbest zikir ekle',
  );
  static const stats = (
    title: 'Sayacak bir şey yok',
    body:
        'İlk zikrini tamamladığında seri, günlük toplam ve grafik burada belirir.',
    action: 'Zikre başla',
  );
  static const sequentialError = (
    title: 'Liste yüklenemedi',
    body: 'Ayet verisi okunamadı. Yeniden denemek sorunu genelde çözer.',
    action: 'Tekrar dene',
  );

  /// Arama boş sonucunda aksiyon butonu yoktur — kullanıcı zaten
  /// arama alanının içindedir.
  static const searchEmpty = (
    title: 'Sonuç bulunamadı',
    body: '"2:255" gibi bir referans veya sûre adı deneyebilirsin.',
    action: null,
  );
}

/// Veri beklenen alanlar için — içerik **uydurulmaz**, yer tutucu bırakılır.
class AwaitingDataPlaceholder extends StatelessWidget {
  const AwaitingDataPlaceholder({
    this.label = 'Veri bekleniyor',
    this.height = 20,
    super.key,
  });

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      height: height,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(label, style: context.type.meta(t.textTertiary)),
      ),
    );
  }
}
