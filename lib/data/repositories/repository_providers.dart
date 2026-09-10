import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/features.dart';
import '../../core/theme/theme_controller.dart';
import '../../domain/models/models.dart';
import 'dhikr_repository_impl.dart';
import 'fixture_repositories.dart';
import 'json_saved_repository.dart';
import 'repositories.dart';

/// Ü16 · geliştirici anahtarı. Açıkken bütün repository'ler hata döner,
/// böylece her ekranın hata durumu gerçekten gezilebilir.
const String kForceErrorKey = 'dev_force_error';

class ForceErrorController extends Notifier<bool> {
  @override
  bool build() {
    if (!Features.devTools) return false;
    return ref.read(jsonStoreProvider).read<bool>(kForceErrorKey) ?? false;
  }

  void set(bool value) {
    state = value;
    ref.read(jsonStoreProvider).write(kForceErrorKey, value ? true : null);
  }
}

final forceErrorProvider = NotifierProvider<ForceErrorController, bool>(
  ForceErrorController.new,
);

/// Aşama 2'de yalnızca bu satırlar `Drift*` sınıflarına döner.
final verseRepositoryProvider = Provider<VerseRepository>(
  (ref) =>
      FixtureVerseRepository(failEverything: ref.watch(forceErrorProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) =>
      FixtureCategoryRepository(failEverything: ref.watch(forceErrorProvider)),
);

final savedRepositoryProvider = Provider<SavedRepository>(
  (ref) => JsonSavedRepository(
    ref.watch(jsonStoreProvider),
    failEverything: ref.watch(forceErrorProvider),
  ),
);

/// Kaydedilenler listesi — yazma sonrası kendiliğinden tazelenir.
final savedListProvider = StreamProvider<List<SavedVerse>>(
  (ref) => ref.watch(savedRepositoryProvider).watch(),
);

/// Kategori adı — kaydedilenlerdeki kaynak kategori hapı için.
final categoryNameProvider = FutureProvider.family<String?, String>(
  (ref, id) async =>
      (await ref.watch(categoryRepositoryProvider).categoryById(id))
          .valueOrNull
          ?.name,
);

final dhikrRepositoryProvider = Provider<DhikrRepository>(
  (ref) => JsonDhikrRepository(
    ref.watch(jsonStoreProvider),
    failEverything: ref.watch(forceErrorProvider),
  ),
);

final dhikrPresetsProvider = FutureProvider<List<DhikrPreset>>(
  (ref) async =>
      (await ref.watch(dhikrRepositoryProvider).presets()).valueOrNull ??
      const [],
);

final customDhikrProvider = StreamProvider<List<CustomDhikr>>(
  (ref) => ref.watch(dhikrRepositoryProvider).watchCustom(),
);

final dailyStatsProvider = FutureProvider<List<DailyStat>>(
  (ref) async =>
      (await ref.watch(dhikrRepositoryProvider).dailyStats()).valueOrNull ??
      const [],
);

final translatorsProvider = FutureProvider<List<Translator>>(
  (ref) async =>
      (await ref.watch(verseRepositoryProvider).translators()).valueOrNull ??
      const [],
);

final savedCategoriesProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(savedRepositoryProvider).watchCategories(),
);

final asmaulHusnaRepositoryProvider = Provider<AsmaulHusnaRepository>(
  (ref) => const FixtureAsmaulHusnaRepository(),
);
