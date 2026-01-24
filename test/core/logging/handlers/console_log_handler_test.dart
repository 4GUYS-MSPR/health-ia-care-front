import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';

import 'package:health_ia_care_app/core/logging/handlers/console_log_handler.dart';
import 'package:health_ia_care_app/core/logging/handlers/log_handler.dart';
import 'package:health_ia_care_app/core/logging/log_formatter.dart';

class MockLogFormatter extends Mock implements LogFormatter {}

void main() {
  group('ConsoleLogHandler', () {
    late ConsoleLogHandler handler;
    late MockLogFormatter mockFormatter;

    setUp(() {
      mockFormatter = MockLogFormatter();
      handler = ConsoleLogHandler(
        formatter: mockFormatter,
        useColor: false,
      );
    });

    test('implements LogHandler', () {
      expect(handler, isA<LogHandler>());
    });

    test(
      'handle calls formatter.format with the record and useColor false',
      () {
        // arrange
        final record = LogRecord(Level.INFO, 'Test message', 'TestLogger');
        when(
          () => mockFormatter.format(record, false),
        ).thenReturn('formatted output');

        // act
        handler.handle(record);

        // assert
        verify(() => mockFormatter.format(record, false)).called(1);
      },
    );

    test('handle calls formatter.format with useColor true when enabled', () {
      // arrange
      final colorHandler = ConsoleLogHandler(
        formatter: mockFormatter,
        useColor: true,
      );
      final record = LogRecord(Level.INFO, 'Test message', 'TestLogger');
      when(
        () => mockFormatter.format(record, true),
      ).thenReturn('colored output');

      // act
      colorHandler.handle(record);

      // assert
      verify(() => mockFormatter.format(record, true)).called(1);
    });

    test('dispose completes without error', () async {
      // act & assert
      await expectLater(handler.dispose(), completes);
    });
  });
}
