import 'package:get_it/get_it.dart';

import '../../../core/network/network_info.dart';
import '../data/datasources/nutrition_remote_data_source.dart';
import '../data/repositories/nutrition_repository_impl.dart';
import '../domain/repositories/nutrition_repository.dart';
import '../domain/usecases/create_food_usecase.dart';
import '../domain/usecases/delete_food_usecase.dart';
import '../domain/usecases/get_all_foods_usecase.dart';
import '../domain/usecases/get_food_usecase.dart';
import '../domain/usecases/update_food_usecase.dart';
import '../presentation/blocs/foods_bloc.dart';

void registerNutritionFeature(GetIt sl) {
  _registerDatasources(sl);
  _registerRepositories(sl);
  _registerUsecases(sl);
  _registerBlocsAndCubits(sl);
}

void _registerDatasources(GetIt sl) {
  sl.registerFactory<NutritionRemoteDataSource>(
    () => NutritionRemoteDataSourceImpl(
      client: sl(),
    ),
  );
}

void _registerRepositories(GetIt sl) {
  sl.registerFactory<NutritionRepository>(
    () => NutritionRepositoryImpl(
      remoteDatasources: sl(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
}

void _registerUsecases(GetIt sl) {
  sl.registerFactory(
    () => GetAllFoodsUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => GetFoodUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => CreateFoodUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => UpdateFoodUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => DeleteFoodUsecase(repository: sl()),
  );
}

void _registerBlocsAndCubits(GetIt sl) {
  sl.registerFactory(
    () => FoodsBloc(
      getAllFoodsUsecase: sl(),
      createFoodUsecase: sl(),
      updateFoodUsecase: sl(),
      deleteFoodUsecase: sl(),
    ),
  );
}
