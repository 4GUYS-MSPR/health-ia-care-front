import 'package:get_it/get_it.dart';

import '../../shared/cubits/locale_cubit/locale_cubit.dart';
import '../../shared/cubits/theme_cubit/theme_cubit.dart';

void registerCubits(GetIt sl) {
  sl.registerLazySingleton(() => LocaleCubit());
  sl.registerLazySingleton(() => ThemeCubit());
}
