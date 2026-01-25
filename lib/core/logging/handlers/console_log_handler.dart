import 'package:logging/logging.dart';

import '../log_formatter.dart';
import 'log_handler.dart';

/// A log handler that outputs formatted log records to the console.
class ConsoleLogHandler implements LogHandler {
  final LogFormatter _formatter;
  final bool _useColor;

  /// Creates a console log handler with the specified formatter.
  ConsoleLogHandler({
    required LogFormatter formatter,
    required bool useColor,
  }) : _formatter = formatter,
       _useColor = useColor;

  @override
  void handle(LogRecord record) {
    // ignore: avoid_print
    print(_formatter.format(record, _useColor));
  }

  @override
  Future<void> dispose() async {
    // Nothing to dispose for console handler
  }
}
