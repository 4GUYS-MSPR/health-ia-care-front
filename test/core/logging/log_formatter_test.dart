import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'package:health_ia_care_app/core/constants/ansi_colors.dart';
import 'package:health_ia_care_app/core/logging/log_formatter.dart';

void main() {
  group('LogFormatter', () {
    late LogFormatter formatter;

    setUp(() {
      formatter = const LogFormatter();
    });

    group('format', () {
      test('formats basic log record correctly', () {
        // arrange
        final record = LogRecord(
          Level.INFO,
          'Test message',
          'TestLogger',
        );

        // act
        final result = formatter.format(record);

        // assert
        expect(result, contains('[TestLogger][INFO]'));
        expect(result, contains('Test message'));
        expect(result, contains(record.sequenceNumber.toString()));
      });

      test('formats log record with local time by default', () {
        // arrange
        final record = LogRecord(
          Level.INFO,
          'Test message',
          'TestLogger',
        );
        final local = DateTime.now().toLocal();
        final localFormated = DateFormat('yyyy-MM-dd HH:mm:ss').format(local);

        // act
        final result = formatter.format(record);

        // assert
        expect(result, contains(localFormated));
      });

      test('formats log record with UTC time when useUtc is true', () {
        // arrange
        const utcFormatter = LogFormatter(useUtc: true);
        final utc = DateTime.now().toUtc();
        final utcFormated = DateFormat('yyyy-MM-dd HH:mm:ss').format(utc);
        final record = LogRecord(
          Level.INFO,
          'Test message',
          'TestLogger',
        );

        // act
        final result = utcFormatter.format(record);

        // assert
        expect(result, contains(utcFormated));
      });

      test('includes error when showError is true and error exists', () {
        // arrange
        final error = Exception('Test error');
        final record = LogRecord(
          Level.SEVERE,
          'Error occurred',
          'TestLogger',
          error,
        );

        // act
        final result = formatter.format(record);

        // assert
        expect(result, contains('Error occurred'));
        expect(result, contains('Exception: Test error'));
      });

      test('excludes error when showError is false', () {
        // arrange
        const noErrorFormatter = LogFormatter(showError: false);
        final error = Exception('Test error');
        final record = LogRecord(
          Level.SEVERE,
          'Error occurred',
          'TestLogger',
          error,
        );

        // act
        final result = noErrorFormatter.format(record);

        // assert
        expect(result, contains('Error occurred'));
        expect(result, isNot(contains('Exception: Test error')));
      });

      test(
        'includes stack trace when showStackTrace is true and trace exists',
        () {
          // arrange
          final stackTrace = StackTrace.current;
          final record = LogRecord(
            Level.SEVERE,
            'Error occurred',
            'TestLogger',
            null,
            stackTrace,
          );

          // act
          final result = formatter.format(record);

          // assert
          expect(result, contains('Error occurred'));
          expect(result, contains(stackTrace.toString()));
        },
      );

      test('excludes stack trace when showStackTrace is false', () {
        // arrange
        const noStackFormatter = LogFormatter(showStackTrace: false);
        final stackTrace = StackTrace.current;
        final record = LogRecord(
          Level.SEVERE,
          'Error occurred',
          'TestLogger',
          null,
          stackTrace,
        );

        // act
        final result = noStackFormatter.format(record);

        // assert
        expect(result, contains('Error occurred'));
        expect(result, isNot(contains('#0')));
      });

      test('formats different log levels correctly', () {
        // arrange
        final levels = [
          Level.FINEST,
          Level.FINER,
          Level.FINE,
          Level.CONFIG,
          Level.INFO,
          Level.WARNING,
          Level.SEVERE,
          Level.SHOUT,
        ];

        for (final level in levels) {
          final record = LogRecord(level, 'Test', 'Logger');

          // act
          final result = formatter.format(record);

          // assert
          expect(result, contains('[${level.name}]'));
        }
      });

      test('formats hierarchical logger names correctly', () {
        // arrange
        final record = LogRecord(
          Level.INFO,
          'Test message',
          'Auth.Data.AuthRepository',
        );

        // act
        final result = formatter.format(record);

        // assert
        expect(result, contains('[Auth.Data.AuthRepository]'));
      });

      group('color formatting', () {
        test('does not include ANSI codes when useColor is false', () {
          // arrange
          final record = LogRecord(Level.INFO, 'Test message', 'TestLogger');

          // act
          final result = formatter.format(record, false);

          // assert
          expect(result, isNot(contains(AnsiColors.reset)));
          expect(result, isNot(contains(AnsiColors.regularWhite)));
          expect(result, isNot(contains(AnsiColors.regularBlack)));
          expect(result, isNot(contains(AnsiColors.underlineBlack)));
          expect(
            result,
            isNot(contains(AnsiColors.backgroundHightIntensityBlack)),
          );
          expect(result, isNot(contains(AnsiColors.hightIntensityPurple)));
          expect(result, isNot(contains(AnsiColors.hightIntensityRed)));
          expect(result, isNot(contains(AnsiColors.regularBlue)));
        });

        test('includes ANSI codes when useColor is true', () {
          // arrange
          final record = LogRecord(Level.INFO, 'Test message', 'TestLogger');

          // act
          final result = formatter.format(record, true);

          // assert
          expect(result, contains(AnsiColors.reset));
          expect(result, contains(AnsiColors.regularWhite));
          expect(result, contains(AnsiColors.regularBlue));
          expect(result, contains(AnsiColors.backgroundHightIntensityBlack));
          expect(result, contains(AnsiColors.underlineBlack));
        });

        test('uses correct color for SHOUT level', () {
          // arrange
          final record = LogRecord(Level.SHOUT, 'Shout', 'TestLogger');

          // act
          final result = formatter.format(record, true);

          // assert
          expect(result, contains(AnsiColors.boldHightIntensityPurple));
        });

        test('uses correct color for SEVERE level', () {
          // arrange
          final record = LogRecord(Level.SEVERE, 'Error', 'TestLogger');

          // act
          final result = formatter.format(record, true);

          // assert
          expect(result, contains(AnsiColors.boldHightIntensityRed));
        });

        test('uses correct color for WARNING level', () {
          // arrange
          final record = LogRecord(Level.WARNING, 'Warning', 'TestLogger');

          // act
          final result = formatter.format(record, true);

          // assert
          expect(result, contains(AnsiColors.boldYellow));
        });

        test('uses correct color for INFO level', () {
          // arrange
          final record = LogRecord(Level.INFO, 'Info', 'TestLogger');

          // act
          final result = formatter.format(record, true);

          // assert
          expect(result, contains(AnsiColors.regularBlue));
        });

        test('uses correct color for CONFIG level', () {
          // arrange
          final record = LogRecord(Level.CONFIG, 'Config', 'TestLogger');

          // act
          final result = formatter.format(record, true);

          // assert
          expect(result, contains(AnsiColors.regularBlack));
        });

        test('uses correct color for FINE level', () {
          // arrange
          final record = LogRecord(Level.FINE, 'Fine', 'TestLogger');

          // act
          final result = formatter.format(record, true);

          // assert
          expect(result, contains(AnsiColors.regularGreen));
        });

        test('uses correct color for FINER level', () {
          // arrange
          final record = LogRecord(Level.FINER, 'Finer', 'TestLogger');

          // act
          final result = formatter.format(record, true);

          // assert
          expect(result, contains(AnsiColors.regularGreen));
        });

        test('uses correct color for FINEST level', () {
          // arrange
          final record = LogRecord(Level.FINEST, 'Finest', 'TestLogger');

          // act
          final result = formatter.format(record, true);

          // assert
          expect(result, contains(AnsiColors.regularGreen));
        });

        test('applies color to error when present', () {
          // arrange
          final error = Exception('Test error');
          final record = LogRecord(
            Level.SEVERE,
            'Error occurred',
            'TestLogger',
            error,
          );

          // act
          final result = formatter.format(record, true);

          // assert
          // Error should also be colored
          expect(
            result.indexOf(AnsiColors.hightIntensityRed),
            lessThan(result.indexOf('Exception')),
          );
        });

        test('applies color to stack trace when present', () {
          // arrange
          final stackTrace = StackTrace.current;
          final record = LogRecord(
            Level.SEVERE,
            'Error occurred',
            'TestLogger',
            null,
            stackTrace,
          );

          // act
          final result = formatter.format(record, true);

          // assert
          // Stack trace should also be colored
          expect(
            result.indexOf(AnsiColors.hightIntensityRed),
            lessThan(result.indexOf('#0')),
          );
        });
      });
    });
  });
}
