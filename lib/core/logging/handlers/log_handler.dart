import 'package:logging/logging.dart';

/// Abstract base class for log handlers.
///
/// Implementations handle log records in different ways
/// (console output, file writing, network transmission, etc.).
abstract class LogHandler {
  /// Handles a log record.
  ///
  /// Implementations should format and output the record
  /// according to their specific destination.
  void handle(LogRecord record);

  /// Disposes of any resources held by the handler.
  ///
  /// Called when the logging system is shutting down.
  Future<void> dispose();
}
