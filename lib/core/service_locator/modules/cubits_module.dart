import 'package:get_it/get_it.dart';

import '../../shared/cubits/locale_cubit/locale_cubit.dart';

void registerCubits(GetIt sl) {
  sl.registerLazySingleton(() => LocaleCubit());
}
