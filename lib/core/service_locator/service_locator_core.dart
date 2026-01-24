import 'package:get_it/get_it.dart';

import 'init/dotenv_init.dart';
import 'init/hydrated_storage_init.dart';
import 'init/logger_init.dart';
import 'modules/cubits_module.dart';

Future<void> registerCoreDependencies(GetIt sl) async {
  // Inits
  await initHydratedStorage();
  await initLogger(sl);
  await initDotenv();

  // Modules
  registerCubits(sl);
}
