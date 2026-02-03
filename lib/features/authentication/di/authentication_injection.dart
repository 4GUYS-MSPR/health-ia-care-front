import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../core/network/network_info.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/restore_user_usecase.dart';
import '../presentation/blocs/auth_bloc/auth_bloc.dart';
import '../presentation/cubits/login_form_cubit/login_form_cubit.dart';
import '../presentation/cubits/login_process_cubit/login_process_cubit.dart';

void registerAuthenticationFeature(GetIt sl) {
  _registerDatasources(sl);
  _registerRepositories(sl);
  _registerUsecases(sl);
  _registerBlocsAndCubits(sl);
}

void _registerDatasources(GetIt sl) {
  sl.registerFactory<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(
      authClient: sl<Dio>(),
    ),
  );
}

void _registerRepositories(GetIt sl) {
  sl.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      localDatasource: sl(),
      remoteDatasource: sl(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
}

void _registerUsecases(GetIt sl) {
  sl.registerFactory(
    () => LoginUsecase(
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => LogoutUsecase(
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => RestoreUserUsecase(
      repository: sl(),
    ),
  );
}

void _registerBlocsAndCubits(GetIt sl) {
  sl.registerLazySingleton(
    () => AuthBloc(
      logoutUsecase: sl(),
      restoreUserUsecase: sl(),
    ),
  );

  sl.registerFactory(
    () => LoginProcessCubit(
      loginUsecase: sl(),
    ),
  );

  sl.registerFactory(
    () => LoginFormCubit(),
  );
}
