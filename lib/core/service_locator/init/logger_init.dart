import 'package:get_it/get_it.dart';

import '../../logging/app_logger.dart';
import '../../logging/log_config.dart';

/// Initializes the logging system.
///
/// This should be called early in the service locator initialization,
/// after dotenv is loaded but before other services that may need logging.
Future<void> initLogger(GetIt sl) async {
  final config = LogConfig.fromEnv();
  await AppLogger.initialize(config);

  // Register AppLogger for dependency injection if needed
  sl.registerSingleton<AppLogger>(AppLogger.instance);
}
