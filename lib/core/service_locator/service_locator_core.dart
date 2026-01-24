import 'package:get_it/get_it.dart';

import 'init/dotenv_init.dart';
import 'init/hydrated_storage_init.dart';
import 'init/logger_init.dart';
import 'modules/cubits_module.dart';

Future<void> registerCoreDependencies(GetIt sl) async {
  // Inits
  await initDotenv();
  await initLogger(sl);
  await initHydratedStorage();

  // Modules
  registerCubits(sl);
}
