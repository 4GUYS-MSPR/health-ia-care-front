import 'package:dio/dio.dart';

import '../models/nutrition_food_model.dart';

abstract interface class NutritionRemoteDataSource {
  Future<List<NutritionFoodModel>> getFoods();
}

class NutritionRemoteDataSourceImpl implements NutritionRemoteDataSource {
  static const _nutritionPath = '/api/foods/';

  final Dio client;

  NutritionRemoteDataSourceImpl({required this.client});

  @override
  Future<List<NutritionFoodModel>> getFoods() async {
    final response = await client.get(_nutritionPath);
    final items = response.data as List<dynamic>;

    return items
        .whereType<Map<String, dynamic>>()
        .map(NutritionFoodModel.fromJson)
        .toList();
  }
}
