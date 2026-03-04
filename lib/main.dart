import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:logging/logging.dart';

import 'app/error_app.dart';
import 'app/main_app.dart';
import 'app/service_locator/service_locator.dart';
import 'core/logging/app_logger.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await _initializeApp();
    runApp(const MainApp());
  } catch (error, stackTrace) {
    _logStartupError(error, stackTrace);
    runApp(ErrorApp(error: error, stackTrace: stackTrace));
  } finally {
    FlutterNativeSplash.remove();
  }
}

Future<void> _initializeApp() async {
  _log('Starting app initialization...');
  _log('Initializing service locator...');

  await initServiceLocator();

  _log('Service locator initialized', level: .FINE);
  _log('App initialization completed successfully');
}

void _logStartupError(Object error, StackTrace stackTrace) {
  _log(
    'App initialization failed',
    level: Level.SHOUT,
    error: error,
    stackTrace: stackTrace,
  );
}

/// Logs a message using AppLogger if initialized, otherwise uses debugPrint.
void _log(
  String message, {
  Level level = Level.INFO,
  Object? error,
  StackTrace? stackTrace,
}) {
  if (AppLogger.instance.isInitialized) {
    final logger = AppLogger.instance.getLogger('Main');
    logger.log(level, message, error, stackTrace);
  } else {
    debugPrint('[Main][${level.name}] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('$stackTrace');
  }
}
