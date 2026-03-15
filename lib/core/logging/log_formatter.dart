import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import '../constants/ansi_colors.dart';

/// Formats log records into a consistent string format.
///
/// Format: `<sequenceNumber> <time> [<loggerName>][<level>] <message>`
/// With optional error and stack trace on new lines.
class LogFormatter {
  /// Whether to format timestamps in UTC.
  final bool useUtc;

  /// Whether to include error objects in the output.
  final bool showError;

  /// Whether to include stack traces in the output.
  final bool showStackTrace;

  const LogFormatter({
    this.useUtc = false,
    this.showError = true,
    this.showStackTrace = true,
  });

  /// Formats a [LogRecord] into a string.
  ///
  /// When [useColor] is true, ANSI color codes are applied based on log level.
  ///
  /// Example output:
  /// ```
  /// 12 2026-01-19 15:04:24 [Authentication.Data.AuthRemoteDatasource][FINE] supabase responded with ...
  /// ```
  String format(LogRecord record, [bool useColor = false]) {
    final buffer = StringBuffer();

    final logLevelColor = useColor ? _getColorForLevel(record.level) : '';
    final colorReset = useColor ? AnsiColors.reset : '';

    // Sequence number
    final sequenceNumberColor = useColor ? AnsiColors.regularWhite : '';
    buffer.write(sequenceNumberColor);
    buffer.write(record.sequenceNumber);
    buffer.write(colorReset);
    buffer.write(' ');

    // Timestamp
    final timestampColor = useColor ? AnsiColors.underlineBlack : '';
    final time = useUtc ? record.time.toUtc() : record.time;
    buffer.write(timestampColor);
    buffer.write(_formatDateTime(time));
    buffer.write(colorReset);
    buffer.write(' ');

    // Logger name and level
    final bracketColor = useColor ? AnsiColors.regularWhite : '';
    final loggerNameColor = useColor ? AnsiColors.backgroundHightIntensityBlack : '';

    buffer.write(bracketColor);
    buffer.write('[');
    buffer.write(colorReset);

    buffer.write(loggerNameColor);
    buffer.write(record.loggerName);
    buffer.write(colorReset);

    buffer.write(bracketColor);
    buffer.write('][');
    buffer.write(colorReset);

    buffer.write(logLevelColor);
    buffer.write(record.level.name);
    buffer.write(colorReset);

    buffer.write(bracketColor);
    buffer.write(']');
    buffer.write(colorReset);
    buffer.write(' ');

    // Message
    buffer.write(record.message);

    // Error (optional)
    if (showError && record.error != null) {
      buffer.writeln();
      buffer.write(logLevelColor);
      buffer.write(record.error);
      buffer.write(colorReset);
    }

    // Stack trace (optional)
    if (showStackTrace && record.stackTrace != null) {
      buffer.writeln();
      buffer.write(logLevelColor);
      buffer.write(record.stackTrace);
      buffer.write(colorReset);
    }

    return buffer.toString();
  }

  /// Returns the ANSI color code for the given log level.
  String _getColorForLevel(Level level) {
    return switch (level) {
      .SHOUT => AnsiColors.boldHightIntensityPurple,
      .SEVERE => AnsiColors.boldHightIntensityRed,
      .WARNING => AnsiColors.boldYellow,
      .INFO => AnsiColors.regularBlue,
      .CONFIG => AnsiColors.regularBlack,
      .FINE => AnsiColors.regularGreen,
      .FINER => AnsiColors.regularGreen,
      .FINEST => AnsiColors.regularGreen,
      _ => AnsiColors.regularCyan,
    };
  }

  /// Formats a [DateTime] as "yyyy-MM-dd HH:mm:ss".
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
