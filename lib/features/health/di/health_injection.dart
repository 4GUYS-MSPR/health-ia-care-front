import 'package:get_it/get_it.dart';

import '../../../core/network/network_info.dart';
import '../data/datasources/diet_recommendation_remote_data_source.dart';
import '../data/datasources/enum_remote_data_source.dart';
import '../data/repositories/enum_repository_impl.dart';
import '../domain/repositories/enum_repository.dart';
import '../domain/usecases/get_health_enums_usecase.dart';
import '../data/datasources/exercise_remote_data_source.dart';
import '../data/datasources/nutrition_remote_data_source.dart';
import '../data/datasources/session_remote_data_source.dart';
import '../data/repositories/diet_recommendation_repository_impl.dart';
import '../data/repositories/exercise_repository_impl.dart';
import '../data/repositories/nutrition_repository_impl.dart';
import '../data/repositories/session_repository_impl.dart';
import '../domain/repositories/diet_recommendation_repository.dart';
import '../domain/repositories/exercise_repository.dart';
import '../domain/repositories/nutrition_repository.dart';
import '../domain/repositories/session_repository.dart';
import '../domain/usecases/create_diet_recommendation_usecase.dart';
import '../domain/usecases/create_exercise_usecase.dart';
import '../domain/usecases/create_food_usecase.dart';
import '../domain/usecases/create_session_usecase.dart';
import '../domain/usecases/delete_diet_recommendation_usecase.dart';
import '../domain/usecases/delete_exercise_usecase.dart';
import '../domain/usecases/delete_food_usecase.dart';
import '../domain/usecases/delete_session_usecase.dart';
import '../domain/usecases/get_all_diet_recommendations_usecase.dart';
import '../domain/usecases/get_all_exercises_usecase.dart';
import '../domain/usecases/export_foods_usecase.dart';
import '../domain/usecases/get_all_foods_usecase.dart';
import '../domain/usecases/get_all_sessions_usecase.dart';
import '../domain/usecases/get_food_usecase.dart';
import '../domain/usecases/update_diet_recommendation_usecase.dart';
import '../domain/usecases/update_exercise_usecase.dart';
import '../domain/usecases/import_foods_usecase.dart';
import '../domain/usecases/update_food_usecase.dart';
import '../domain/usecases/update_session_usecase.dart';
import '../presentation/blocs/diet_recommendations_bloc.dart';
import '../presentation/blocs/exercises_bloc.dart';
import '../presentation/blocs/food_import_bloc.dart';
import '../presentation/blocs/foods_bloc.dart';
import '../presentation/blocs/sessions_bloc.dart';

void registerNutritionFeature(GetIt sl) {
  _registerDatasources(sl);
  _registerRepositories(sl);
  _registerUsecases(sl);
  _registerBlocsAndCubits(sl);
}

void registerDietRecommendationFeature(GetIt sl) {
  _registerDietRecommendationDatasources(sl);
  _registerDietRecommendationRepositories(sl);
  _registerDietRecommendationUsecases(sl);
  _registerDietRecommendationBlocs(sl);
}

void registerSharedHealthDatasources(GetIt sl) {
  sl.registerFactory<HealthEnumRemoteDataSource>(
    () => HealthEnumRemoteDataSourceImpl(client: sl()),
  );

  sl.registerFactory<EnumRepository>(
    () => EnumRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerFactory(
    () => GetHealthEnumsUsecase(repository: sl()),
  );
}

void registerExerciseFeature(GetIt sl) {
  _registerExerciseDatasources(sl);
  _registerExerciseRepositories(sl);
  _registerExerciseUsecases(sl);
  _registerExerciseBlocs(sl);
}

void registerSessionFeature(GetIt sl) {
  _registerSessionDatasources(sl);
  _registerSessionRepositories(sl);
  _registerSessionUsecases(sl);
  _registerSessionBlocs(sl);
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

  sl.registerFactory(
    () => ImportFoodsUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => ExportFoodsUsecase(repository: sl()),
  );
}

void _registerBlocsAndCubits(GetIt sl) {
  sl.registerFactory(
    () => FoodsBloc(
      getAllFoodsUsecase: sl(),
      createFoodUsecase: sl(),
      updateFoodUsecase: sl(),
      deleteFoodUsecase: sl(),
      dataSource: sl(),
    ),
  );

  sl.registerFactory(
    () => FoodImportBloc(
      importFoodsUsecase: sl(),
      exportFoodsUsecase: sl(),
    ),
  );
}

// --- Diet Recommendation Feature ---

void _registerDietRecommendationDatasources(GetIt sl) {
  sl.registerFactory<DietRecommendationRemoteDataSource>(
    () => DietRecommendationRemoteDataSourceImpl(
      client: sl(),
    ),
  );
}

void _registerDietRecommendationRepositories(GetIt sl) {
  sl.registerFactory<DietRecommendationRepository>(
    () => DietRecommendationRepositoryImpl(
      remoteDatasource: sl(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
}

void _registerDietRecommendationUsecases(GetIt sl) {
  sl.registerFactory(
    () => GetAllDietRecommendationsUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => CreateDietRecommendationUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => UpdateDietRecommendationUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => DeleteDietRecommendationUsecase(repository: sl()),
  );
}

void _registerDietRecommendationBlocs(GetIt sl) {
  sl.registerFactory(
    () => DietRecommendationsBloc(
      getAllDietRecommendationsUsecase: sl(),
      createDietRecommendationUsecase: sl(),
      updateDietRecommendationUsecase: sl(),
      deleteDietRecommendationUsecase: sl(),
      dataSource: sl(),
    ),
  );
}

// --- Exercise Feature ---

void _registerExerciseDatasources(GetIt sl) {
  sl.registerFactory<ExerciseRemoteDataSource>(
    () => ExerciseRemoteDataSourceImpl(
      client: sl(),
    ),
  );
}

void _registerExerciseRepositories(GetIt sl) {
  sl.registerFactory<ExerciseRepository>(
    () => ExerciseRepositoryImpl(
      remoteDatasource: sl(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
}

void _registerExerciseUsecases(GetIt sl) {
  sl.registerFactory(
    () => GetAllExercisesUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => CreateExerciseUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => UpdateExerciseUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => DeleteExerciseUsecase(repository: sl()),
  );
}

void _registerExerciseBlocs(GetIt sl) {
  sl.registerFactory(
    () => ExercisesBloc(
      getAllExercisesUsecase: sl(),
      createExerciseUsecase: sl(),
      updateExerciseUsecase: sl(),
      deleteExerciseUsecase: sl(),
      dataSource: sl(),
    ),
  );
}

// --- Session Feature ---

void _registerSessionDatasources(GetIt sl) {
  sl.registerFactory<SessionRemoteDataSource>(
    () => SessionRemoteDataSourceImpl(
      client: sl(),
    ),
  );
}

void _registerSessionRepositories(GetIt sl) {
  sl.registerFactory<SessionRepository>(
    () => SessionRepositoryImpl(
      remoteDatasource: sl(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
}

void _registerSessionUsecases(GetIt sl) {
  sl.registerFactory(
    () => GetAllSessionsUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => CreateSessionUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => UpdateSessionUsecase(repository: sl()),
  );

  sl.registerFactory(
    () => DeleteSessionUsecase(repository: sl()),
  );
}

void _registerSessionBlocs(GetIt sl) {
  sl.registerFactory(
    () => SessionsBloc(
      getAllSessionsUsecase: sl(),
      createSessionUsecase: sl(),
      updateSessionUsecase: sl(),
      deleteSessionUsecase: sl(),
      dataSource: sl(),
    ),
  );
}
