import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';

import 'package:health_ia_care_app/core/network/network_info.dart';

class MockInternetConnectionChecker extends Mock implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockConnectionChecker;

  setUp(() {
    mockConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(connectionChecker: mockConnectionChecker);
  });

  group('NetworkInfoImpl', () {
    test('return true when there is a connection', () async {
      // arrange
      when(() => mockConnectionChecker.hasConnection).thenAnswer(
        (_) async => true,
      );

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, true);
      verify(() => mockConnectionChecker.hasConnection).called(1);
      verifyNoMoreInteractions(mockConnectionChecker);
    });

    test('return false when there is no connection', () async {
      // arrange
      when(() => mockConnectionChecker.hasConnection).thenAnswer(
        (_) async => false,
      );

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, false);
      verify(() => mockConnectionChecker.hasConnection).called(1);
      verifyNoMoreInteractions(mockConnectionChecker);
    });
  });
}
