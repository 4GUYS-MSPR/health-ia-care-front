import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:health_ia_care_app/core/shared/cubits/locale_cubit/locale_cubit.dart';
import 'package:health_ia_care_app/core/utils/locale_utils.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late LocaleCubit localeCubit;
  late MockStorage mockStorage;

  setUp(() {
    mockStorage = MockStorage();
    HydratedBloc.storage = mockStorage;
    when(
      () => mockStorage.write(any(), any()),
    ).thenAnswer((_) async => Future.value());
    localeCubit = LocaleCubit();
  });

  tearDown(() {
    localeCubit.close();
  });

  test('use the best matching supported locale as initial state', () {
    // assert
    expect(localeCubit.state, isA<Locale>());
    expect(LocaleUtils.supportedLocales, contains(localeCubit.state));
  });

  test('save the state to storage on locale change', () {
    // arrange
    final locale = Locale('en', 'US');
    localeCubit.setLocale(locale);

    // act
    localeCubit.setLocale(Locale('fr', 'FR'));

    // assert
    verify(
      () => mockStorage.write('LocaleCubit', {
        'languageCode': 'fr',
        'countryCode': 'FR',
      }),
    ).called(1);
  });

  test(
    'retrieve the last state from storage when instantiated',
    () {
      // arrange
      when(
        () => mockStorage.read('LocaleCubit'),
      ).thenReturn({'languageCode': 'en', 'countryCode': 'US'});

      // act
      localeCubit = LocaleCubit();

      // assert
      expect(localeCubit.state, equals(Locale('en', 'US')));
    },
  );

  test('use best supported locale if stored locale language code is null', () {
    // arrange
    when(
      () => mockStorage.read('LocaleCubit'),
    ).thenReturn({'languageCode': null, 'countryCode': 'US'});

    // act
    localeCubit = LocaleCubit();

    // assert
    expect(localeCubit.state, LocaleUtils.findBestSupportedLocale());
  });

  group('setLocale', () {
    test('emit the new locale', () {
      // arrange
      final locale = Locale('en', 'US');

      // act
      localeCubit.setLocale(locale);

      // assert
      expect(localeCubit.state, equals(locale));
    });

    test(
      'emit a locale even when provided with only a languageCode',
      () {
        // arrange
        final locale = Locale('en');

        // act
        localeCubit.setLocale(locale);

        // assert
        expect(localeCubit.state, equals(locale));
      },
    );
  });
}
