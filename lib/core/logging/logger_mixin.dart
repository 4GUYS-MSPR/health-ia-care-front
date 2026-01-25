import 'package:logging/logging.dart';

import 'app_logger.dart';

/// A mixin that provides easy access to a [Logger] instance.
///
/// The logger name is automatically derived from the class's runtime type.
///
/// Usage:
/// ```dart
/// class AuthRepository with LoggerMixin {
///   void authenticate() {
///     logger.info('Authenticating user...');
///   }
/// }
/// ```
///
/// The logger name will be the class name (e.g., 'AuthRepository').
/// For more specific naming, override the [loggerName] getter:
///
/// ```dart
/// class AuthRepository with LoggerMixin {
///   @override
///   String get loggerName => 'Auth.Data.AuthRepository';
/// }
/// ```
mixin LoggerMixin {
  Logger? _logger;

  /// The name to use for this logger.
  ///
  /// Override this to provide a custom logger name.
  /// By default, uses the runtime type name of the class.
  String get loggerName => runtimeType.toString();

  /// The logger instance for this class.
  ///
  /// Lazily created on first access.
  Logger get logger => _logger ??= AppLogger.instance.getLogger(loggerName);
}
