import 'dart:async';

import 'package:logging/logging.dart';

import 'handlers/console_log_handler.dart';
import 'handlers/file_log_handler.dart';
import 'handlers/log_handler.dart';
import 'log_config.dart';
import 'log_formatter.dart';

/// Central logging service for the application.
///
/// Manages the Dart [logging] package configuration and provides
/// a factory method to create loggers for different parts of the app.
///
/// Usage:
/// ```dart
/// // Initialize during app startup
/// await AppLogger.initialize(LogConfig.fromEnv());
///
/// // Get a logger for a specific component
/// final logger = AppLogger.instance.getLogger('Auth.Data.AuthRepository');
/// logger.info('User authenticated successfully');
/// ```
class AppLogger {
  AppLogger._();

  /// The singleton instance of [AppLogger].
  static final AppLogger instance = AppLogger._();

  final List<LogHandler> _handlers = [];
  StreamSubscription<LogRecord>? _subscription;
  bool _isInitialized = false;
  LogConfig? _config;

  /// Whether the logger has been initialized.
  bool get isInitialized => _isInitialized;

  /// The current logging configuration.
  ///
  /// Returns null if the logger has not been initialized.
  LogConfig? get config => _config;

  /// Initializes the logging system with the given configuration.
  ///
  /// This should be called early in the app startup, after environment
  /// variables are loaded but before other services are initialized.
  static Future<void> initialize(LogConfig config) async {
    if (instance._isInitialized) {
      return;
    }

    instance._config = config;

    // Configure the logging package
    hierarchicalLoggingEnabled = config.hierarchical;
    Logger.root.level = config.rootLevel;

    // Create the formatter
    final formatter = LogFormatter(
      useUtc: config.useUtc,
      showError: config.showError,
      showStackTrace: config.showStackTrace,
    );

    // Set up console handler
    if (config.consoleEnabled) {
      final consoleHandler = ConsoleLogHandler(
        formatter: formatter,
        useColor: config.consoleUseColor,
      );
      instance._handlers.add(consoleHandler);
    }

    // Set up file handler (not on web)
    if (config.fileEnabled && FileLogHandler.isSupported) {
      final fileHandler = FileLogHandler(
        formatter: formatter,
        relativePath: config.filePath,
        maxSizeKb: config.fileMaxSizeKb,
        maxFileCount: config.fileMaxCount,
      );
      await fileHandler.init();
      instance._handlers.add(fileHandler);
    }

    // Apply per-feature log levels
    for (final entry in config.featureLevels.entries) {
      Logger(entry.key).level = entry.value;
    }

    // Subscribe to log records
    instance._subscription = Logger.root.onRecord.listen(
      instance._handleRecord,
    );

    instance._isInitialized = true;

    // Log initialization complete
    final initLogger = instance.getLogger('Core.Logging.AppLogger');
    initLogger.info('Logging system initialized');
    initLogger.config('Root level: ${config.rootLevel}');
    initLogger.config('Hierarchical: ${config.hierarchical}');
    initLogger.config('UTC time: ${config.useUtc}');
    initLogger.config('Console enabled: ${config.consoleEnabled}');
    initLogger.config('File enabled: ${config.fileEnabled}');
    initLogger.config('Show Error: ${config.showError}');
    initLogger.config('Show Stack Trace : ${config.showStackTrace}');
    if (config.featureLevels.isNotEmpty) {
      initLogger.config('Feature levels: ${config.featureLevels}');
    }
  }

  /// Handles incoming log records by dispatching to all handlers.
  void _handleRecord(LogRecord record) {
    for (final handler in _handlers) {
      handler.handle(record);
    }
  }

  /// Gets or creates a [Logger] with the given name.
  ///
  /// If hierarchical logging is enabled, the logger will inherit its level
  /// from its parent unless explicitly configured in [LogConfig.featureLevels].
  ///
  /// Example names:
  /// - `'Auth'` - Top-level auth feature
  /// - `'Auth.Data.AuthRepository'` - Specific repository in auth feature
  /// - `'Core.Router'` - Router component in core
  Logger getLogger(String name) {
    return Logger(name);
  }

  /// Disposes of all handlers and cleans up resources.
  ///
  /// Should be called when the app is shutting down.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;

    for (final handler in _handlers) {
      await handler.dispose();
    }
    _handlers.clear();

    _config = null;
    _isInitialized = false;
  }
}
