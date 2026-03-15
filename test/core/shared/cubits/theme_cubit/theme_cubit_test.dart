import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:health_ia_care_app/core/shared/cubits/theme_cubit/theme_cubit.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late ThemeCubit themeCubit;
  late MockStorage mockStorage;

  setUp(() {
    mockStorage = MockStorage();
    HydratedBloc.storage = mockStorage;
    when(
      () => mockStorage.write(any(), any()),
    ).thenAnswer((_) async => Future.value());
    themeCubit = ThemeCubit();
  });

  tearDown(() {
    themeCubit.close();
  });

  test('initial state is ThemeMode.system', () {
    // assert
    expect(themeCubit.state, equals(ThemeMode.system));
  });

  test('saves the state to storage on state change', () {
    // arrange
    themeCubit.emit(ThemeMode.dark);

    // act
    themeCubit.emit(ThemeMode.light);

    // assert
    verify(
      () => mockStorage.write('ThemeCubit', {
        'theme_mode': ThemeMode.light.index,
      }),
    ).called(1);
  });

  test(
    'retrieve the last state from storage when instantiated',
    () {
      // arrange
      when(
        () => mockStorage.read('ThemeCubit'),
      ).thenReturn({'theme_mode': ThemeMode.dark.index});

      // act
      themeCubit = ThemeCubit();

      // assert
      expect(themeCubit.state, equals(ThemeMode.dark));
    },
  );

  group('systemBrightness', () {
    test(
      'return Brightness.light when platformBrightness is set to light mode',
      () {
        // arrange
        final binding = TestWidgetsFlutterBinding.ensureInitialized();
        binding.platformDispatcher.platformBrightnessTestValue = Brightness.light;

        // act
        final Brightness brightness = themeCubit.systemBrightness;

        // assert
        expect(brightness, equals(Brightness.light));
      },
    );

    test(
      'return Brightness.dark when platformBrightness is set to dark mode',
      () {
        // arrange
        final binding = TestWidgetsFlutterBinding.ensureInitialized();
        binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;

        // act
        final Brightness brightness = themeCubit.systemBrightness;

        // assert
        expect(brightness, equals(Brightness.dark));
      },
    );
  });

  group('nextThemeMode', () {
    group('system in light mode', () {
      test(
        'emits ThemeMode.dark when previous state is ThemeMode.system',
        () {
          // arrange
          final binding = TestWidgetsFlutterBinding.ensureInitialized();
          binding.platformDispatcher.platformBrightnessTestValue = Brightness.light;

          themeCubit.emit(ThemeMode.system);

          // act
          themeCubit.nextThemeMode();

          // assert
          expect(themeCubit.state, equals(ThemeMode.dark));
        },
      );

      test(
        'emits ThemeMode.light when previous state is ThemeMode.dark',
        () {
          // arrange
          final binding = TestWidgetsFlutterBinding.ensureInitialized();
          binding.platformDispatcher.platformBrightnessTestValue = Brightness.light;

          themeCubit.emit(ThemeMode.dark);

          // act
          themeCubit.nextThemeMode();

          // assert
          expect(themeCubit.state, equals(ThemeMode.light));
        },
      );

      test(
        'emits ThemeMode.system when previous state is ThemeMode.light',
        () {
          // arrange
          final binding = TestWidgetsFlutterBinding.ensureInitialized();
          binding.platformDispatcher.platformBrightnessTestValue = Brightness.light;

          themeCubit.emit(ThemeMode.light);

          // act
          themeCubit.nextThemeMode();

          // assert
          expect(themeCubit.state, equals(ThemeMode.system));
        },
      );
    });

    group('system in dark mode', () {
      test(
        'emits ThemeMode.light when previous state is ThemeMode.system',
        () {
          // arrange
          final binding = TestWidgetsFlutterBinding.ensureInitialized();
          binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;

          themeCubit.emit(ThemeMode.system);

          // act
          themeCubit.nextThemeMode();

          // assert
          expect(themeCubit.state, equals(ThemeMode.light));
        },
      );

      test(
        'emits ThemeMode.dark when previous state is ThemeMode.light',
        () {
          // arrange
          final binding = TestWidgetsFlutterBinding.ensureInitialized();
          binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;

          themeCubit.emit(ThemeMode.light);

          // act
          themeCubit.nextThemeMode();

          // assert
          expect(themeCubit.state, equals(ThemeMode.dark));
        },
      );

      test(
        'emits ThemeMode.system when previous state is ThemeMode.dark',
        () {
          // arrange
          final binding = TestWidgetsFlutterBinding.ensureInitialized();
          binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;

          themeCubit.emit(ThemeMode.dark);

          // act
          themeCubit.nextThemeMode();

          // assert
          expect(themeCubit.state, equals(ThemeMode.system));
        },
      );
    });
  });

  group('selectThemeMode', () {
    test('emits the correct ThemeMode', () {
      // arrange
      themeCubit.emit(ThemeMode.system);

      // act
      themeCubit.selectThemeMode(ThemeMode.light);
      final testThemeLight = themeCubit.state;

      themeCubit.selectThemeMode(ThemeMode.dark);
      final testThemeDark = themeCubit.state;

      themeCubit.selectThemeMode(ThemeMode.system);
      final testThemeSystem = themeCubit.state;

      // assert
      expect(testThemeLight, equals(ThemeMode.light));
      expect(testThemeDark, equals(ThemeMode.dark));
      expect(testThemeSystem, equals(ThemeMode.system));
    });
  });

  group('toggleThemeMode', () {
    test('emits ThemeMode.light when toggling from ThemeMode.dark', () {
      // arrange
      themeCubit.emit(ThemeMode.dark);

      // act
      themeCubit.toggleThemeMode();

      // assert
      expect(themeCubit.state, equals(ThemeMode.light));
    });

    test('emits ThemeMode.dark when toggling from ThemeMode.light', () {
      // arrange
      themeCubit.emit(ThemeMode.light);

      // act
      themeCubit.toggleThemeMode();

      // assert
      expect(themeCubit.state, equals(ThemeMode.dark));
    });

    group('system in light mode', () {
      test(
        'emits ThemeMode.dark when toggling from ThemeMode.system',
        () {
          // arrange
          final binding = TestWidgetsFlutterBinding.ensureInitialized();
          binding.platformDispatcher.platformBrightnessTestValue = Brightness.light;
          themeCubit.emit(ThemeMode.system);

          // act
          themeCubit.toggleThemeMode();

          // assert
          expect(themeCubit.state, equals(ThemeMode.dark));
        },
      );
    });

    group('system in dark mode', () {
      test(
        'emits ThemeMode.light when toggling from ThemeMode.system',
        () {
          // arrange
          final binding = TestWidgetsFlutterBinding.ensureInitialized();
          binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
          themeCubit.emit(ThemeMode.system);

          // act
          themeCubit.toggleThemeMode();

          // assert
          expect(themeCubit.state, equals(ThemeMode.light));
        },
      );
    });
  });
}
