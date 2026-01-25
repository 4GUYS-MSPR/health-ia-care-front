import 'package:equatable/equatable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

/// Configuration for the application logging system.
///
/// All values are read from environment variables with sensible defaults.
class LogConfig extends Equatable {
  /// The root log level for the application.
  final Level rootLevel;

  /// Whether to use UTC time for log timestamps.
  final bool useUtc;

  /// Whether to enable hierarchical logging.
  ///
  /// When enabled, child loggers inherit their parent's level unless
  /// explicitly overridden.
  final bool hierarchical;

  /// Per-feature log levels.
  ///
  /// Map of logger names to their specific log levels.
  /// Format in .env: "Auth:FINE;Auth.Data:FINER;Core:INFO"
  final Map<String, Level> featureLevels;

  /// Whether the console handler is enabled.
  final bool consoleEnabled;

  /// Whether to use colored output in console logs.
  final bool consoleUseColor;

  /// Whether the file handler is enabled.
  final bool fileEnabled;

  /// Path for log files (relative to app documents directory).
  final String filePath;

  /// Maximum size of a single log file in kilobytes.
  final int fileMaxSizeKb;

  /// Maximum number of rotated log files to keep.
  final int fileMaxCount;

  /// Whether to include error objects in log output.
  final bool showError;

  /// Whether to include stack traces in log output.
  final bool showStackTrace;

  const LogConfig({
    required this.rootLevel,
    required this.useUtc,
    required this.hierarchical,
    required this.featureLevels,
    required this.consoleEnabled,
    required this.consoleUseColor,
    required this.fileEnabled,
    required this.filePath,
    required this.fileMaxSizeKb,
    required this.fileMaxCount,
    required this.showError,
    required this.showStackTrace,
  });

  /// Creates a [LogConfig] from environment variables.
  ///
  /// Environment variables:
  /// - `LOG_ROOT_LEVEL`: Root log level (default: INFO)
  /// - `LOG_USE_UTC`: Use UTC time (default: false)
  /// - `LOG_HIERARCHICAL`: Enable hierarchical logging (default: true)
  /// - `LOG_FEATURE_LEVELS`: Per-feature levels (default: empty)
  /// - `LOG_CONSOLE_ENABLED`: Enable console handler (default: true)
  /// - `LOG_FILE_ENABLED`: Enable file handler (default: true)
  /// - `LOG_FILE_PATH`: Log file path (default: logs/app.log)
  /// - `LOG_FILE_MAX_SIZE_KB`: Max file size in KB (default: 5120)
  /// - `LOG_FILE_MAX_COUNT`: Max rotated files (default: 5)
  /// - `LOG_SHOW_ERROR`: Show error objects in output (default: true)
  /// - `LOG_SHOW_STACK_TRACE`: Show stack traces in output (default: true)
  factory LogConfig.fromEnv() {
    return LogConfig(
      rootLevel: _parseLevel(
        dotenv.get('LOG_ROOT_LEVEL', fallback: 'INFO'),
      ),
      useUtc: dotenv.getBool('LOG_USE_UTC', fallback: false),
      hierarchical: dotenv.getBool('LOG_HIERARCHICAL', fallback: true),
      featureLevels: _parseFeatureLevels(
        dotenv.get('LOG_FEATURE_LEVELS', fallback: ''),
      ),
      consoleEnabled: dotenv.getBool('LOG_CONSOLE_ENABLED', fallback: true),
      consoleUseColor: dotenv.getBool('LOG_CONSOLE_USE_COLOR', fallback: false),
      fileEnabled: dotenv.getBool('LOG_FILE_ENABLED', fallback: true),
      filePath: dotenv.get('LOG_FILE_PATH', fallback: 'logs/app.log'),
      fileMaxSizeKb: dotenv.getInt('LOG_FILE_MAX_SIZE_KB', fallback: 5120),
      fileMaxCount: dotenv.getInt('LOG_FILE_MAX_COUNT', fallback: 5),
      showError: dotenv.getBool('LOG_SHOW_ERROR', fallback: true),
      showStackTrace: dotenv.getBool('LOG_SHOW_STACK_TRACE', fallback: true),
    );
  }

  /// Parses a level string to a [Level].
  ///
  /// Falls back to [Level.INFO] if the level is not recognized.
  static Level _parseLevel(String levelStr) {
    return Level.LEVELS.firstWhere(
      (level) => level.name.toUpperCase() == levelStr.toUpperCase(),
      orElse: () => Level.INFO,
    );
  }

  /// Parses feature levels from a string.
  ///
  /// Format: "Auth:FINE;Auth.Data:FINER;Core:INFO"
  static Map<String, Level> _parseFeatureLevels(String featureLevelsStr) {
    if (featureLevelsStr.isEmpty) {
      return {};
    }

    final Map<String, Level> levels = {};
    final entries = featureLevelsStr.split(';');

    for (final entry in entries) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final name = parts[0].trim();
        final level = _parseLevel(parts[1].trim());
        if (name.isNotEmpty) {
          levels[name] = level;
        }
      }
    }

    return levels;
  }

  @override
  List<Object?> get props => [
    rootLevel,
    useUtc,
    hierarchical,
    featureLevels,
    consoleEnabled,
    consoleUseColor,
    fileEnabled,
    filePath,
    fileMaxSizeKb,
    fileMaxCount,
    showError,
    showStackTrace,
  ];
}
