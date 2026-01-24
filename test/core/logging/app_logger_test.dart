import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import 'package:health_ia_care_app/core/logging/app_logger.dart';
import 'package:health_ia_care_app/core/logging/log_config.dart';

void main() {
  group('AppLogger', () {
    tearDown(() async {
      // Clean up after each test
      await AppLogger.instance.dispose();
    });

    group('instance', () {
      test('returns the same singleton instance', () {
        // act
        final instance1 = AppLogger.instance;
        final instance2 = AppLogger.instance;

        // assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('isInitialized', () {
      test('returns false before initialization', () {
        // assert
        expect(AppLogger.instance.isInitialized, isFalse);
      });

      test('returns true after initialization', () async {
        // arrange
        const config = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'logs/test.log',
          fileMaxSizeKb: 1024,
          fileMaxCount: 3,
          showError: true,
          showStackTrace: true,
        );

        // act
        await AppLogger.initialize(config);

        // assert
        expect(AppLogger.instance.isInitialized, isTrue);
      });
    });

    group('config', () {
      test('returns null before initialization', () {
        // assert
        expect(AppLogger.instance.config, isNull);
      });

      test('returns config after initialization', () async {
        // arrange
        const config = LogConfig(
          rootLevel: Level.FINE,
          useUtc: true,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'logs/test.log',
          fileMaxSizeKb: 1024,
          fileMaxCount: 3,
          showError: true,
          showStackTrace: true,
        );

        // act
        await AppLogger.initialize(config);

        // assert
        expect(AppLogger.instance.config, equals(config));
      });
    });

    group('initialize', () {
      test('sets hierarchicalLoggingEnabled from config', () async {
        // arrange
        const config = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'logs/test.log',
          fileMaxSizeKb: 1024,
          fileMaxCount: 3,
          showError: true,
          showStackTrace: true,
        );

        // act
        await AppLogger.initialize(config);

        // assert
        expect(hierarchicalLoggingEnabled, isTrue);
      });

      test('sets root logger level from config', () async {
        // arrange
        const config = LogConfig(
          rootLevel: Level.WARNING,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'logs/test.log',
          fileMaxSizeKb: 1024,
          fileMaxCount: 3,
          showError: true,
          showStackTrace: true,
        );

        // act
        await AppLogger.initialize(config);

        // assert
        expect(Logger.root.level, equals(Level.WARNING));
      });

      test('applies feature levels from config', () async {
        // arrange
        final featureLevels = {
          'Auth': Level.FINE,
          'Auth.Data': Level.FINER,
        };
        final config = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: featureLevels,
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'logs/test.log',
          fileMaxSizeKb: 1024,
          fileMaxCount: 3,
          showError: true,
          showStackTrace: true,
        );

        // act
        await AppLogger.initialize(config);

        // assert
        expect(Logger('Auth').level, equals(Level.FINE));
        expect(Logger('Auth.Data').level, equals(Level.FINER));
      });

      test('does not reinitialize if already initialized', () async {
        // arrange
        const config1 = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'logs/test.log',
          fileMaxSizeKb: 1024,
          fileMaxCount: 3,
          showError: true,
          showStackTrace: true,
        );
        const config2 = LogConfig(
          rootLevel: Level.SEVERE,
          useUtc: true,
          hierarchical: false,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: true,
          fileEnabled: false,
          filePath: 'logs/test2.log',
          fileMaxSizeKb: 2048,
          fileMaxCount: 5,
          showError: false,
          showStackTrace: false,
        );

        // act
        await AppLogger.initialize(config1);
        await AppLogger.initialize(config2);

        // assert - should still have config1 values
        expect(AppLogger.instance.config, equals(config1));
        expect(Logger.root.level, equals(Level.INFO));
      });
    });

    group('getLogger', () {
      setUp(() async {
        const config = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'logs/test.log',
          fileMaxSizeKb: 1024,
          fileMaxCount: 3,
          showError: true,
          showStackTrace: true,
        );
        await AppLogger.initialize(config);
      });

      test('returns a Logger with the specified name', () {
        // act
        final logger = AppLogger.instance.getLogger('TestFeature');

        // assert
        expect(logger, isA<Logger>());
        expect(logger.name, equals('TestFeature'));
      });

      test('returns same Logger instance for same name', () {
        // act
        final logger1 = AppLogger.instance.getLogger('TestFeature');
        final logger2 = AppLogger.instance.getLogger('TestFeature');

        // assert
        expect(identical(logger1, logger2), isTrue);
      });

      test('supports hierarchical logger names', () {
        // act
        final parentLogger = AppLogger.instance.getLogger('Auth');
        final childLogger = AppLogger.instance.getLogger('Auth.Data');

        // assert
        expect(parentLogger.name, equals('Auth'));
        expect(childLogger.name, equals('Data'));
        expect(childLogger.fullName, equals('Auth.Data'));
        expect(childLogger.parent, equals(parentLogger));
      });
    });

    group('dispose', () {
      test('sets isInitialized to false', () async {
        // arrange
        const config = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'logs/test.log',
          fileMaxSizeKb: 1024,
          fileMaxCount: 3,
          showError: true,
          showStackTrace: true,
        );
        await AppLogger.initialize(config);
        expect(AppLogger.instance.isInitialized, isTrue);

        // act
        await AppLogger.instance.dispose();

        // assert
        expect(AppLogger.instance.isInitialized, isFalse);
      });

      test('allows reinitialization after dispose', () async {
        // arrange
        const config1 = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'logs/test.log',
          fileMaxSizeKb: 1024,
          fileMaxCount: 3,
          showError: true,
          showStackTrace: true,
        );
        const config2 = LogConfig(
          rootLevel: Level.SEVERE,
          useUtc: true,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'logs/test2.log',
          fileMaxSizeKb: 2048,
          fileMaxCount: 5,
          showError: false,
          showStackTrace: false,
        );

        await AppLogger.initialize(config1);
        await AppLogger.instance.dispose();

        // act
        await AppLogger.initialize(config2);

        // assert
        expect(AppLogger.instance.isInitialized, isTrue);
        expect(AppLogger.instance.config, equals(config2));
      });
    });
  });
}
