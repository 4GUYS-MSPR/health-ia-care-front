import 'package:get_it/get_it.dart';

import 'init/hydrated_storage_init.dart';
import 'modules/cubits_module.dart';

Future<void> registerCoreDependencies(GetIt sl) async {
  await initHydratedStorage();
  registerCubits(sl);
}
