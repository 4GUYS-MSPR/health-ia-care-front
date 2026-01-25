import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';

import 'package:health_ia_care_app/core/logging/handlers/file_log_handler.dart';
import 'package:health_ia_care_app/core/logging/handlers/log_handler.dart';
import 'package:health_ia_care_app/core/logging/log_formatter.dart';

class MockLogFormatter extends Mock implements LogFormatter {}

void main() {
  group('FileLogHandler', () {
    late MockLogFormatter mockFormatter;

    setUp(() {
      mockFormatter = MockLogFormatter();
    });

    test('implements LogHandler', () {
      // arrange
      final handler = FileLogHandler(
        formatter: mockFormatter,
        relativePath: 'test/logs/test.log',
        maxSizeKb: 1024,
        maxFileCount: 3,
      );

      // assert
      expect(handler, isA<LogHandler>());
    });

    group('isSupported', () {
      test('returns true on non-web platforms', () {
        // assert
        expect(FileLogHandler.isSupported, equals(!kIsWeb));
      });
    });

    group('handle', () {
      test('does not throw if not initialized', () {
        // arrange
        final handler = FileLogHandler(
          formatter: mockFormatter,
          relativePath: 'test/logs/test.log',
          maxSizeKb: 1024,
          maxFileCount: 3,
        );
        final record = LogRecord(Level.INFO, 'Test message', 'TestLogger');

        // act & assert - should not throw
        expect(() => handler.handle(record), returnsNormally);
      });

      test('does not call formatter when not initialized', () {
        // arrange
        final handler = FileLogHandler(
          formatter: mockFormatter,
          relativePath: 'test_logs/test.log',
          maxSizeKb: 1024,
          maxFileCount: 3,
        );

        final record = LogRecord(Level.INFO, 'Test message', 'TestLogger');

        // act
        handler.handle(record);

        // assert - formatter should NOT be called since handler is not initialized
        verifyNever(() => mockFormatter.format(record));
      });
    });

    group('dispose', () {
      test('completes without error when not initialized', () async {
        // arrange
        final handler = FileLogHandler(
          formatter: mockFormatter,
          relativePath: 'test_logs/test_dispose.log',
          maxSizeKb: 1024,
          maxFileCount: 3,
        );

        // act & assert
        await expectLater(handler.dispose(), completes);
      });
    });

    // NOTE: Tests that require init() (file system access) should be in
    // integration_test/ folder since path_provider needs platform channels.
  });
}

