import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../core/network/network_info.dart';
import '../../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../interceptors/auth_interceptor.dart';

void registerNetwork(GetIt sl) {
  final connectionChecker = InternetConnectionChecker.createInstance();

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: connectionChecker),
  );

  final baseUrl = dotenv.get(
    "API_URL",
    fallback: "https://health-ia.host-dcode.fr",
  );

  sl.registerLazySingleton<Dio>(
    () {
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add auth interceptor to automatically include token in requests
      // and handle 401 refresh+retry
      dio.interceptors.add(
        AuthInterceptor(
          authLocalDatasource: sl<AuthLocalDatasource>(),
          dio: dio,
        ),
      );

      return dio;
    },
  );
}
