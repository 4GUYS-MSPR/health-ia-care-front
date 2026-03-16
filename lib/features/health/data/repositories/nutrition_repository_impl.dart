import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/nutrition_food.dart';
import '../../domain/errors/nutrition_failure.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_remote_data_source.dart';
import '../models/nutrition_food_model.dart';

/// Repository implementation for nutrition food operations.
///
/// Coordinates network checks and remote datasource calls.
class NutritionRepositoryImpl with LoggerMixin implements NutritionRepository {
  final NutritionRemoteDataSource remoteDatasources;
  final NetworkInfo networkInfo;

  NutritionRepositoryImpl({
    required this.remoteDatasources,
    required this.networkInfo,
  });

  @override
  String get loggerName => 'Health.Data.NutritionRepository';

  /// Checks for internet connectivity.
  TaskEither<Failure, Unit> _checkInternetConnection() {
    return TaskEither.tryCatch(
      () async {
        final isConnected = await networkInfo.isConnected;
        if (!isConnected) {
          logger.warning('No internet connection');
          throw const NoInternetConnectionFailure();
        }
        return unit;
      },
      (error, _) {
        if (error is Failure) return error;
        return const NoInternetConnectionFailure();
      },
    );
  }

  @override
  TaskEither<Failure, NutritionFood> createFood(NutritionFood food) {
    logger.finest('createFood called');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final data = NutritionFoodModel.fromEntity(food).toMap();
          final createdFood = await remoteDatasources.createFood(
            label: data['label'],
            calories: data['calories'],
            protein: data['protein'],
            carbohydrates: data['carbohydrates'],
            fat: data['fat'],
            fiber: data['fiber'],
            sugars: data['sugars'],
            sodium: data['sodium'],
            cholesterol: data['cholesterol'],
            waterIntake: data['water_intake'],
            categoryId: data['category'],
            mealTypeId: data['meal_type'],
          );
          logger.fine('Food created with id=${createdFood.id}');
          return createdFood;
        },
        (error, stackTrace) {
          logger.severe('Failed to create food', error, stackTrace);
          if (error is Failure) return error;
          return const FoodCreationFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteFood(int id) {
    logger.finest('deleteFood called for id=$id');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          await remoteDatasources.deleteFood(id);
          logger.fine('Food $id deleted');
          return unit;
        },
        (error, stackTrace) {
          logger.severe('Failed to delete food $id', error, stackTrace);
          if (error is Failure) return error;
          return FoodDeleteFailure(
            foodId: id,
            debugMessage: 'Unexpected error',
          );
        },
      ),
    );
  }

  @override
  TaskEither<Failure, List<NutritionFood>> getAllFoods() {
    logger.finest('getAllFoods called');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final foods = await remoteDatasources.getFoods();
          logger.fine('Retrieved ${foods.length} foods');
          return foods;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch foods', error, stackTrace);
          if (error is Failure) return error;
          return const FoodsFetchFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, NutritionFood> getFood(int id) {
    logger.finest('getFood called for id=$id');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final food = await remoteDatasources.getFood(id);
          logger.fine('Retrieved food $id');
          return food;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch food $id', error, stackTrace);
          if (error is Failure) return error;
          return FoodNotFoundException(
            foodId: id,
            debugMessage: 'Unexpected error',
          );
        },
      ),
    );
  }

  @override
  TaskEither<Failure, NutritionFood> updateFood(int id, NutritionFood food) {
    logger.finest('updateFood called for id=$id');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final data = NutritionFoodModel.fromEntity(food).toMap();
          final updatedFood = await remoteDatasources.updateFood(
            id,
            label: data['label'],
            calories: data['calories'],
            protein: data['protein'],
            carbohydrates: data['carbohydrates'],
            fat: data['fat'],
            fiber: data['fiber'],
            sugars: data['sugars'],
            sodium: data['sodium'],
            cholesterol: data['cholesterol'],
            waterIntake: data['water_intake'],
            categoryId: data['category'],
            mealTypeId: data['meal_type'],
          );
          logger.fine('Food $id updated');
          return updatedFood;
        },
        (error, stackTrace) {
          logger.severe('Failed to update food $id', error, stackTrace);
          if (error is Failure) return error;
          return FoodUpdateFailure(
            foodId: id,
            debugMessage: 'Unexpected error',
          );
        },
      ),
    );
  }
}
