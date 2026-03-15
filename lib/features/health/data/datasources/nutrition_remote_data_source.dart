import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../models/nutrition_food_model.dart';

/// Remote datasource for nutrition foods API operations.
abstract class NutritionRemoteDataSource {
  Future<List<String>> getFoodCategories();
  Future<List<String>> getMealTypes();
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
  Future<void> deleteFood(int id);
  Future<List<NutritionFoodModel>> getFoods();
  Future<(List<NutritionFoodModel>, PaginationInfo)> getFoodsPage({
    required int offset,
    required int limit,
  });
  Future<NutritionFoodModel> getFood(int id);
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

class NutritionRemoteDataSourceImpl implements NutritionRemoteDataSource {
  static const _foodsEndpoint = '/api/food/';
  static const _enumEndpoint = '/api/enum/';
  static const _foodCategoryModel = 'FoodCategory';
  static const _mealTypeModel = 'MealType';
  final Dio client;
  NutritionRemoteDataSourceImpl({required this.client});

  @override
  Future<List<String>> getFoodCategories() => _fetchEnumValues(_foodCategoryModel);
  @override
  Future<List<String>> getMealTypes() => _fetchEnumValues(_mealTypeModel);
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
    final data = {
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
      'category': await _findEnumId(_foodCategoryModel, category),
      'meal_type': await _findEnumId(_mealTypeModel, mealType),
    };
    try {
      final res = await client.post(_foodsEndpoint, data: data);
      return NutritionFoodModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<void> deleteFood(int id) async {
    try {
      await client.delete('$_foodsEndpoint$id/');
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<List<NutritionFoodModel>> getFoods() async {
    try {
      final res = await client.get(_foodsEndpoint);
      final data = _extractResults(res.data);
      return data.map((item) => NutritionFoodModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<(List<NutritionFoodModel>, PaginationInfo)> getFoodsPage({
    required int offset,
    required int limit,
  }) async {
    try {
      final res = await client.get(
        _foodsEndpoint,
        queryParameters: {'offset': offset, 'limit': limit},
      );
      final data = _extractResults(res.data);
      final foods = data.map((item) => NutritionFoodModel.fromJson(item)).toList();
      final pagination = PaginationInfo.fromResponse(
        res.data is Map<String, dynamic> ? res.data : {'results': data},
        offset,
        limit,
      );
      return (foods, pagination);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<NutritionFoodModel> getFood(int id) async {
    try {
      final res = await client.get('$_foodsEndpoint$id/');
      return NutritionFoodModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
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
    if (category != null) data['category'] = await _findEnumId(_foodCategoryModel, category);
    if (mealType != null) data['meal_type'] = await _findEnumId(_mealTypeModel, mealType);
    try {
      final res = await client.patch('$_foodsEndpoint$id/', data: data);
      return NutritionFoodModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  // Helpers privés ultra-courts
  Future<int> _findEnumId(String model, String value) async {
    final parsedId = int.tryParse(value.trim());
    if (parsedId != null) return parsedId;
    final res = await client.get('$_enumEndpoint$model/');
    final results = (res.data as Map<String, dynamic>)['results'] as List<dynamic>?;
    if (results == null) throw ServerErrorFailure(debugMessage: 'Invalid enum payload for $model');
    for (final item in results) {
      if (item is Map<String, dynamic>) {
        final itemValue = (item['value'] as String?)?.trim().toLowerCase();
        if (itemValue == value.trim().toLowerCase()) return item['id'] as int;
      }
    }
    throw ServerErrorFailure(debugMessage: 'Unknown value $value for $model');
  }

  Future<List<String>> _fetchEnumValues(String model) async {
    final res = await client.get('$_enumEndpoint$model/');
    final results = (res.data as Map<String, dynamic>)['results'] as List<dynamic>?;
    if (results == null) throw ServerErrorFailure(debugMessage: 'Invalid enum payload for $model');
    return [
      for (final item in results)
        if (item is Map<String, dynamic> && item['value'] != null) item['value'].toString().trim(),
    ];
  }

  List<dynamic> _extractResults(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map && payload['results'] is List) return payload['results'];
    if (payload is Map && payload['data'] is List) return payload['data'];
    if (payload is Map && payload['data'] is Map && payload['data']['results'] is List) {
      return payload['data']['results'];
    }
    throw ServerErrorFailure(
      debugMessage: 'Unexpected foods payload format: ${payload.runtimeType}',
    );
  }
}
