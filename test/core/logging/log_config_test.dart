import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import 'package:health_ia_care_app/core/logging/log_config.dart';

void main() {
  group('LogConfig', () {
    group('constructor', () {
      test('creates config with all required fields', () {
        // act
        final config = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {'Auth': Level.FINE},
          consoleEnabled: true,
          consoleUseColor: true,
          fileEnabled: true,
          filePath: 'logs/app.log',
          fileMaxSizeKb: 5120,
          fileMaxCount: 5,
          showError: true,
          showStackTrace: true,
        );

        // assert
        expect(config.rootLevel, equals(Level.INFO));
        expect(config.useUtc, isFalse);
        expect(config.hierarchical, isTrue);
        expect(config.featureLevels, equals({'Auth': Level.FINE}));
        expect(config.consoleEnabled, isTrue);
        expect(config.consoleUseColor, isTrue);
        expect(config.fileEnabled, isTrue);
        expect(config.filePath, equals('logs/app.log'));
        expect(config.fileMaxSizeKb, equals(5120));
        expect(config.fileMaxCount, equals(5));
        expect(config.showError, isTrue);
        expect(config.showStackTrace, isTrue);
      });
    });

    group('_parseLevel', () {
      // Testing via constructor since _parseLevel is private
      // We can test level parsing through LogConfig if we had a way to call it
      // For now, we'll rely on integration tests via fromEnv

      test('const config can be created', () {
        // act
        const config = LogConfig(
          rootLevel: Level.WARNING,
          useUtc: true,
          hierarchical: false,
          featureLevels: {},
          consoleEnabled: false,
          consoleUseColor: false,
          fileEnabled: false,
          filePath: 'test.log',
          fileMaxSizeKb: 1024,
          fileMaxCount: 3,
          showError: false,
          showStackTrace: false,
        );

        // assert
        expect(config.rootLevel, equals(Level.WARNING));
        expect(config.useUtc, isTrue);
        expect(config.hierarchical, isFalse);
        expect(config.consoleEnabled, isFalse);
        expect(config.fileEnabled, isFalse);
        expect(config.showError, isFalse);
        expect(config.showStackTrace, isFalse);
      });
    });

    group('equality', () {
      test('two configs with same values are equal', () {
        // arrange
        const config1 = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: true,
          consoleUseColor: true,
          fileEnabled: true,
          filePath: 'logs/app.log',
          fileMaxSizeKb: 5120,
          fileMaxCount: 5,
          showError: true,
          showStackTrace: true,
        );
        const config2 = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: true,
          consoleUseColor: true,
          fileEnabled: true,
          filePath: 'logs/app.log',
          fileMaxSizeKb: 5120,
          fileMaxCount: 5,
          showError: true,
          showStackTrace: true,
        );

        // assert
        expect(config1, equals(config2));
      });
    });

    group('featureLevels', () {
      test('supports empty feature levels', () {
        // act
        const config = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: true,
          consoleUseColor: true,
          fileEnabled: true,
          filePath: 'logs/app.log',
          fileMaxSizeKb: 5120,
          fileMaxCount: 5,
          showError: true,
          showStackTrace: true,
        );

        // assert
        expect(config.featureLevels, isEmpty);
      });

      test('supports multiple feature levels', () {
        // act
        final config = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {
            'Auth': Level.FINE,
            'Auth.Data': Level.FINER,
            'Core': Level.INFO,
            'Auth.Domain.SignInUsecase': Level.FINEST,
          },
          consoleEnabled: true,
          consoleUseColor: false,
          fileEnabled: true,
          filePath: 'logs/app.log',
          fileMaxSizeKb: 5120,
          fileMaxCount: 5,
          showError: true,
          showStackTrace: true,
        );

        // assert
        expect(config.featureLevels, hasLength(4));
        expect(config.featureLevels['Auth'], equals(Level.FINE));
        expect(config.featureLevels['Auth.Data'], equals(Level.FINER));
        expect(config.featureLevels['Core'], equals(Level.INFO));
        expect(
          config.featureLevels['Auth.Domain.SignInUsecase'],
          equals(Level.FINEST),
        );
      });
    });

    group('file configuration', () {
      test('supports various file sizes', () {
        // act
        const smallConfig = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: true,
          consoleUseColor: false,
          fileEnabled: true,
          filePath: 'logs/app.log',
          fileMaxSizeKb: 512, // 512 KB
          fileMaxCount: 3,
          showError: true,
          showStackTrace: true,
        );
        const largeConfig = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: true,
          consoleUseColor: false,
          fileEnabled: true,
          filePath: 'logs/app.log',
          fileMaxSizeKb: 10240, // 10 MB
          fileMaxCount: 10,
          showError: true,
          showStackTrace: true,
        );

        // assert
        expect(smallConfig.fileMaxSizeKb, equals(512));
        expect(smallConfig.fileMaxCount, equals(3));
        expect(largeConfig.fileMaxSizeKb, equals(10240));
        expect(largeConfig.fileMaxCount, equals(10));
      });

      test('supports custom file paths', () {
        // act
        const config = LogConfig(
          rootLevel: Level.INFO,
          useUtc: false,
          hierarchical: true,
          featureLevels: {},
          consoleEnabled: true,
          consoleUseColor: false,
          fileEnabled: true,
          filePath: 'custom/path/myapp.log',
          fileMaxSizeKb: 5120,
          fileMaxCount: 5,
          showError: true,
          showStackTrace: true,
        );

        // assert
        expect(config.filePath, equals('custom/path/myapp.log'));
      });
    });

    group('all log levels', () {
      test('supports all standard log levels', () {
        // arrange
        final levels = [
          Level.ALL,
          Level.FINEST,
          Level.FINER,
          Level.FINE,
          Level.CONFIG,
          Level.INFO,
          Level.WARNING,
          Level.SEVERE,
          Level.SHOUT,
          Level.OFF,
        ];

        for (final level in levels) {
          // act
          final config = LogConfig(
            rootLevel: level,
            useUtc: false,
            hierarchical: true,
            featureLevels: {},
            consoleEnabled: true,
            consoleUseColor: false,
            fileEnabled: true,
            filePath: 'logs/app.log',
            fileMaxSizeKb: 5120,
            fileMaxCount: 5,
            showError: true,
            showStackTrace: true,
          );

          // assert
          expect(config.rootLevel, equals(level));
        }
      });
    });
  });
}
