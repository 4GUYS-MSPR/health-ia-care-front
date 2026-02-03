import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../domain/errors/nutrition_failure.dart';
import '../models/nutrition_food_model.dart';

/// Remote datasource for nutrition foods API operations.
abstract interface class NutritionRemoteDataSource {
  /// Creates a new food.
  Future<NutritionFoodModel> createFood({
    required String label,
    required int calories,
    required double protein,
    required double carbohydrates,
    required double fat,
    required double fiber,
    required double sugars,
    required int sodium,
    required int cholesterol,
    required int waterIntake,
    required String category,
    required String mealType,
  });

  /// Deletes a food by [id].
  Future<void> deleteFood(int id);

  /// Gets all foods.
  Future<List<NutritionFoodModel>> getFoods();

  /// Gets a single food by [id].
  Future<NutritionFoodModel> getFood(int id);

  /// Updates a food by [id] with partial data.
  Future<NutritionFoodModel> updateFood(
    int id, {
    String? label,
    int? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugars,
    int? sodium,
    int? cholesterol,
    int? waterIntake,
    String? category,
    String? mealType,
  });
}

class NutritionRemoteDataSourceImpl with LoggerMixin implements NutritionRemoteDataSource {
  static const _foodsEndpoint = '/api/foods/';

  final Dio client;

  NutritionRemoteDataSourceImpl({
    required this.client,
  });

  @override
  String get loggerName => 'Health.Data.NutritionRemoteDataSource';

  @override
  Future<NutritionFoodModel> createFood({
    required String label,
    required int calories,
    required double protein,
    required double carbohydrates,
    required double fat,
    required double fiber,
    required double sugars,
    required int sodium,
    required int cholesterol,
    required int waterIntake,
    required String category,
    required String mealType,
  }) async {
    logger.finest('createFood called');
    logger.finer('Sending POST to $_foodsEndpoint');

    try {
      final data = <String, dynamic>{
        'label': label,
        'calories': calories,
        'protein': protein,
        'carbohydrates': carbohydrates,
        'fat': fat,
        'fiber': fiber,
        'sugars': sugars,
        'sodium': sodium,
        'cholesterol': cholesterol,
        'water_intake': waterIntake,
        'category': category,
        'meal_type': mealType,
      };

      final res = await client.post(
        _foodsEndpoint,
        data: data,
      );

      logger.fine('Food created successfully');
      return NutritionFoodModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      logger.severe('Failed to create food', e, st);
      if (e.response?.statusCode == 400) {
        throw const FoodCreationFailure(
          debugMessage: 'Invalid food data',
        );
      }
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage: e.message,
      );
    }
  }

  @override
  Future<void> deleteFood(int id) async {
    logger.finest('deleteFood called for id=$id');
    logger.finer('Sending DELETE to $_foodsEndpoint$id/');

    try {
      await client.delete('$_foodsEndpoint$id/');
      logger.fine('Food $id deleted successfully');
    } on DioException catch (e, st) {
      logger.severe('Failed to delete food $id', e, st);
      if (e.response?.statusCode == 404) {
        throw FoodNotFoundException(
          foodId: id,
          debugMessage: 'Food not found',
        );
      }
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage: e.message,
      );
    }
  }

  @override
  Future<List<NutritionFoodModel>> getFoods() async {
    logger.finest('getFoods called');
    logger.finer('Sending GET to $_foodsEndpoint');

    try {
      final res = await client.get(_foodsEndpoint);
      final data = res.data as List<dynamic>;

      logger.fine('Retrieved ${data.length} foods');
      return data.map((item) => NutritionFoodModel.fromJson(item)).toList();
    } on DioException catch (e, st) {
      logger.severe('Failed to fetch foods', e, st);
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage: e.message,
      );
    }
  }

  @override
  Future<NutritionFoodModel> getFood(int id) async {
    logger.finest('getFood called for id=$id');
    logger.finer('Sending GET to $_foodsEndpoint$id/');

    try {
      final res = await client.get('$_foodsEndpoint$id/');
      logger.fine('Retrieved food $id');
      return NutritionFoodModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      logger.severe('Failed to fetch food $id', e, st);
      if (e.response?.statusCode == 404) {
        throw FoodNotFoundException(
          foodId: id,
          debugMessage: 'Food not found',
        );
      }
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage: e.message,
      );
    }
  }

  @override
  Future<NutritionFoodModel> updateFood(
    int id, {
    String? label,
    int? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugars,
    int? sodium,
    int? cholesterol,
    int? waterIntake,
    String? category,
    String? mealType,
  }) async {
    logger.finest('updateFood called for id=$id');
    logger.finer('Sending PATCH to $_foodsEndpoint$id/');

    try {
      final data = <String, dynamic>{};

      if (label != null) data['label'] = label;
      if (calories != null) data['calories'] = calories;
      if (protein != null) data['protein'] = protein;
      if (carbohydrates != null) data['carbohydrates'] = carbohydrates;
      if (fat != null) data['fat'] = fat;
      if (fiber != null) data['fiber'] = fiber;
      if (sugars != null) data['sugars'] = sugars;
      if (sodium != null) data['sodium'] = sodium;
      if (cholesterol != null) data['cholesterol'] = cholesterol;
      if (waterIntake != null) data['water_intake'] = waterIntake;
      if (category != null) data['category'] = category;
      if (mealType != null) data['meal_type'] = mealType;

      final res = await client.patch(
        '$_foodsEndpoint$id/',
        data: data,
      );

      logger.fine('Food $id updated successfully');
      return NutritionFoodModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      logger.severe('Failed to update food $id', e, st);
      if (e.response?.statusCode == 404) {
        throw FoodNotFoundException(
          foodId: id,
          debugMessage: 'Food not found',
        );
      }
      if (e.response?.statusCode == 400) {
        throw FoodUpdateFailure(
          foodId: id,
          debugMessage: 'Invalid update data',
        );
      }
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage: e.message,
      );
    }
  }
}