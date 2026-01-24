import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import 'package:health_ia_care_app/core/logging/app_logger.dart';
import 'package:health_ia_care_app/core/logging/logger_mixin.dart';
import 'package:health_ia_care_app/core/logging/log_config.dart';

// Test class using the mixin with default logger name
class TestClassWithMixin with LoggerMixin {}

// Test class using the mixin with custom logger name
class TestClassWithCustomLoggerName with LoggerMixin {
  @override
  String get loggerName => 'Custom.Feature.TestClass';
}

void main() {
  group('LoggerMixin', () {
    setUpAll(() async {
      // Initialize AppLogger for mixin to work
      if (!AppLogger.instance.isInitialized) {
        await AppLogger.initialize(
          const LogConfig(
            rootLevel: Level.ALL,
            useUtc: false,
            hierarchical: true,
            featureLevels: {},
            consoleEnabled: false, // Disable to avoid test output noise
            consoleUseColor: false,
            fileEnabled: false,
            filePath: 'logs/test.log',
            fileMaxSizeKb: 1024,
            fileMaxCount: 3,
            showError: true,
            showStackTrace: true,
          ),
        );
      }
    });

    tearDownAll(() async {
      await AppLogger.instance.dispose();
    });

    group('loggerName', () {
      test('returns runtime type name by default', () {
        // arrange
        final testClass = TestClassWithMixin();

        // act
        final loggerName = testClass.loggerName;

        // assert
        expect(loggerName, equals('TestClassWithMixin'));
      });

      test('returns custom name when overridden', () {
        // arrange
        final testClass = TestClassWithCustomLoggerName();

        // act
        final loggerName = testClass.loggerName;

        // assert
        expect(loggerName, equals('Custom.Feature.TestClass'));
      });
    });

    group('logger', () {
      test('returns a Logger instance', () {
        // arrange
        final testClass = TestClassWithMixin();

        // act
        final logger = testClass.logger;

        // assert
        expect(logger, isA<Logger>());
      });

      test('logger has correct name from loggerName', () {
        // arrange
        final testClass = TestClassWithMixin();

        // act
        final logger = testClass.logger;

        // assert
        expect(logger.name, equals('TestClassWithMixin'));
      });

      test('logger with custom name has correct name', () {
        // arrange
        final testClass = TestClassWithCustomLoggerName();

        // act
        final logger = testClass.logger;

        // assert
        expect(logger.name, equals('TestClass'));
        expect(logger.fullName, equals('Custom.Feature.TestClass'));
      });

      test('logger is cached after first access', () {
        // arrange
        final testClass = TestClassWithMixin();

        // act
        final logger1 = testClass.logger;
        final logger2 = testClass.logger;

        // assert
        expect(identical(logger1, logger2), isTrue);
      });
    });
  });
}
