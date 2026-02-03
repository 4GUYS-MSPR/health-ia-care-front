import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../../features/authentication/data/datasources/auth_local_datasource.dart';

void registerStorage(GetIt sl) {
  sl.registerLazySingleton(
    () => FlutterSecureStorage(),
  );

  // Register AuthLocalDatasource here as it's needed by the network interceptor
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(
      secureStorage: sl(),
    ),
  );
}
