import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ports/port_providers.dart';
import '../core/theme/tokens_ext.dart';
import '../data/repositories/repository_providers.dart';
import 'icons.dart';

/// Kaydet / kaydı kaldır. Durum `savedListProvider`'dan okunur, yazma sonrası
/// kendiliğinden tazelenir.
///
/// **Yalnızca `verseId` yazılır** — metin kopyalanmaz (referans bütünlüğü).
class SaveButton extends ConsumerWidget {
  const SaveButton({
    required this.verseId,
    this.sourceCategoryId,
    this.size = 18,
    super.key,
  });

  final String verseId;
  final String? sourceCategoryId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final saved = (ref.watch(savedListProvider).value ?? const []).any(
      (s) => s.verseId == verseId,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final repo = ref.read(savedRepositoryProvider);
        await ref.read(hapticsPortProvider).selection();
        if (saved) {
          await repo.remove(verseId);
        } else {
          await repo.save(verseId, sourceCategoryId: sourceCategoryId);
        }
      },
      child: Semantics(
        button: true,
        label: saved ? 'Kaydı kaldır' : 'Kaydet',
        child: Icon(
          saved ? KunIcons.bookmark : KunIcons.bookmarkBorder,
          size: size,
          color: saved ? t.accent : t.textPrimary,
        ),
      ),
    );
  }
}
