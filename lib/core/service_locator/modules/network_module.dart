import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../network/network_info.dart';

void registerNetwork(GetIt sl) {
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: sl<InternetConnectionChecker>()),
  );
}
