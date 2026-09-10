import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/theme/theme_controller.dart';
import 'data/local/json_store.dart';
import 'ui/glass.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ü15 · Aşama 1'in kalıcılık katmanı. Aşama 2'de yerini user.db alır.
  final store = await JsonStore.open();

  final container = ProviderContainer(
    overrides: [jsonStoreProvider.overrideWithValue(store)],
  );

  // Cihaz sınıfına göre düşürme: kötü kare süresinde blur kapanır.
  container.read(glassPolicyProvider.notifier).startAutoProbe();

  runApp(
    UncontrolledProviderScope(container: container, child: const KunApp()),
  );
}
