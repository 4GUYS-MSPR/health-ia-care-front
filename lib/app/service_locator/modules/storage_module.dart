import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

void registerStorage(GetIt sl) {
  sl.registerLazySingleton(
    () => FlutterSecureStorage(),
  );
}
