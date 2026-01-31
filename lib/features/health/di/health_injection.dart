import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../core/network/network_info.dart';
import '../data/datasources/nutrition_remote_data_source.dart';
import '../data/repositories/nutrition_repository_impl.dart';
import '../domain/repositories/nutrition_repository.dart';
import '../domain/usecases/get_nutrition_foods.dart';

void registerHealthDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<NutritionRemoteDataSource>(
    () => NutritionRemoteDataSourceImpl(
      client: Dio(
        BaseOptions(
          baseUrl: 'http://localhost:5555',
          headers: {},
        ),
      ),
    ),
  );

  // Repositories
  sl.registerLazySingleton<NutritionRepository>(
    () => NutritionRepositoryImpl(
      remoteDataSource: sl<NutritionRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetNutritionFoods>(
    () => GetNutritionFoods(sl<NutritionRepository>()),
  );
}
