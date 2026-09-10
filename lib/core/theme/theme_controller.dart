import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/json_store.dart';
import 'kun_theme.dart';
import 'themes/themes.dart';

/// Uygulama açılışında `main` tarafından doldurulur.
final jsonStoreProvider = Provider<JsonStore>((ref) {
  throw StateError('jsonStoreProvider main() içinde override edilmeli');
});

const String kThemePrefKey = 'theme_id';

/// Seçili tema. Varsayılan **Cam · gece**; seçim JSON snapshot'a yazılır.
class ThemeController extends Notifier<KunTheme> {
  @override
  KunTheme build() {
    final store = ref.read(jsonStoreProvider);
    final saved = KunThemeId.fromSlug(store.read<String>(kThemePrefKey));
    return saved == null ? kunDefaultTheme : kunThemeOf(saved);
  }

  void select(KunThemeId id) {
    if (id == state.id) return;
    state = kunThemeOf(id);
    ref.read(jsonStoreProvider).write(kThemePrefKey, id.slug);
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, KunTheme>(
  ThemeController.new,
);

/// Token'ları ağaca taşır. `context.tokens` bunun üzerinden okur.
class KunThemeScope extends InheritedWidget {
  const KunThemeScope({required this.theme, required super.child, super.key});

  final KunTheme theme;

  static KunTheme of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<KunThemeScope>();
    assert(scope != null, 'KunThemeScope bulunamadı — KunApp içine alınmalı');
    return scope!.theme;
  }

  @override
  bool updateShouldNotify(KunThemeScope oldWidget) =>
      oldWidget.theme.id != theme.id;
}
