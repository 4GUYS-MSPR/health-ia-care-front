import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../models/enum_item_model.dart';
import '../models/nutrition_food_model.dart';

/// Remote datasource for nutrition foods API operations.
abstract class NutritionRemoteDataSource {
  Future<List<EnumItemModel>> getFoodCategories();
  Future<List<EnumItemModel>> getMealTypes();
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
    required int categoryId,
    required int mealTypeId,
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
    int? categoryId,
    int? mealTypeId,
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
  Future<List<EnumItemModel>> getFoodCategories() => _fetchEnumItems(_foodCategoryModel);
  @override
  Future<List<EnumItemModel>> getMealTypes() => _fetchEnumItems(_mealTypeModel);
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
    required int categoryId,
    required int mealTypeId,
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
      'category': categoryId,
      'meal_type': mealTypeId,
    };
    try {
      final labelsByModel = await _getFoodLabelsByEnumId();
      final res = await client.post(_foodsEndpoint, data: data);
      return NutritionFoodModel.fromJson(
        res.data as Map<String, dynamic>,
        categoryLabelsById: labelsByModel.categoryLabelsById,
        mealTypeLabelsById: labelsByModel.mealTypeLabelsById,
      );
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
      final labelsByModel = await _getFoodLabelsByEnumId();
      final res = await client.get(_foodsEndpoint);
      final data = _extractResults(res.data);
      return data
          .map(
            (item) => NutritionFoodModel.fromJson(
              item,
              categoryLabelsById: labelsByModel.categoryLabelsById,
              mealTypeLabelsById: labelsByModel.mealTypeLabelsById,
            ),
          )
          .toList();
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
      final labelsByModel = await _getFoodLabelsByEnumId();
      final res = await client.get(
        _foodsEndpoint,
        queryParameters: {'offset': offset, 'limit': limit},
      );
      final data = _extractResults(res.data);
      final foods = data
          .map(
            (item) => NutritionFoodModel.fromJson(
              item,
              categoryLabelsById: labelsByModel.categoryLabelsById,
              mealTypeLabelsById: labelsByModel.mealTypeLabelsById,
            ),
          )
          .toList();
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
      final labelsByModel = await _getFoodLabelsByEnumId();
      final res = await client.get('$_foodsEndpoint$id/');
      return NutritionFoodModel.fromJson(
        res.data as Map<String, dynamic>,
        categoryLabelsById: labelsByModel.categoryLabelsById,
        mealTypeLabelsById: labelsByModel.mealTypeLabelsById,
      );
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
    int? categoryId,
    int? mealTypeId,
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
    if (categoryId != null) data['category'] = categoryId;
    if (mealTypeId != null) data['meal_type'] = mealTypeId;
    try {
      final labelsByModel = await _getFoodLabelsByEnumId();
      final res = await client.patch('$_foodsEndpoint$id/', data: data);
      return NutritionFoodModel.fromJson(
        res.data as Map<String, dynamic>,
        categoryLabelsById: labelsByModel.categoryLabelsById,
        mealTypeLabelsById: labelsByModel.mealTypeLabelsById,
      );
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  Future<List<EnumItemModel>> _fetchEnumItems(String model) async {
    final res = await client.get('$_enumEndpoint$model/');
    final payload = res.data;
    final List<dynamic> results = payload is Map<String, dynamic>
        ? ((payload['results'] as List<dynamic>?) ?? const <dynamic>[])
        : (payload as List<dynamic>? ?? const <dynamic>[]);
    return results
        .whereType<Map<String, dynamic>>()
        .map(EnumItemModel.fromJson)
        .toList();
  }

  Future<_FoodEnumLabels> _getFoodLabelsByEnumId() async {
    final categories = await _fetchEnumItems(_foodCategoryModel);
    final mealTypes = await _fetchEnumItems(_mealTypeModel);

    return _FoodEnumLabels(
      categoryLabelsById: {
        for (final item in categories) item.id: item.value,
      },
      mealTypeLabelsById: {
        for (final item in mealTypes) item.id: item.value,
      },
    );
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

class _FoodEnumLabels {
  final Map<int, String> categoryLabelsById;
  final Map<int, String> mealTypeLabelsById;

  const _FoodEnumLabels({
    required this.categoryLabelsById,
    required this.mealTypeLabelsById,
  });
}
