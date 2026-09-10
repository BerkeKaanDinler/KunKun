/// Hata taşıma. Repository'ler istisna fırlatmaz, `Result` döner.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  T? get valueOrNull => this is Ok<T> ? (this as Ok<T>).value : null;

  R when<R>({
    required R Function(T value) ok,
    required R Function(KunFailure f) err,
  }) =>
      this is Ok<T> ? ok((this as Ok<T>).value) : err((this as Err<T>).failure);
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final KunFailure failure;
}

/// Hata türleri.
///
/// **Ağ hatası yoktur.** Uygulama çevrimdışıdır; "İnternet yok" mesajı
/// hiçbir yerde görünmemelidir (mimari brief · Gizlilik).
enum KunFailureKind {
  /// Veri kaynağı okunamadı (bozuk fixture, erişilemeyen dosya).
  dataUnavailable,

  /// İstenen kayıt yok.
  notFound,

  /// Yazma başarısız.
  writeFailed,

  /// Ayarlar › geliştirici › "hata modu" ile zorlanan hata (Ü16).
  forced,
}

class KunFailure {
  const KunFailure(this.kind, {this.detail});

  final KunFailureKind kind;

  /// Kullanıcıya gösterilmez, loglanmaz — yalnızca geliştirici görünümü.
  final String? detail;

  /// Kullanıcıya gösterilecek metin. Hiçbirinde ağ göndermesi yoktur.
  String get message => switch (kind) {
    KunFailureKind.dataUnavailable => 'İçerik şu an açılamadı.',
    KunFailureKind.notFound => 'Kayıt bulunamadı.',
    KunFailureKind.writeFailed => 'Değişiklik kaydedilemedi.',
    KunFailureKind.forced =>
      'Hata modu açık — bu ekranın hata durumu gösteriliyor.',
  };
}
