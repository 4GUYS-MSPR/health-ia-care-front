import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/nutrition_food.dart';

abstract interface class NutritionRepository {
  /// Gets all foods.
  TaskEither<Failure, List<NutritionFood>> getAllFoods();

  /// Creates a new food with the given data.
  TaskEither<Failure, NutritionFood> createFood({
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

  /// Gets a single food by [id].
  TaskEither<Failure, NutritionFood> getFood(int id);

  /// Updates a food by [id] with partial data.
  TaskEither<Failure, NutritionFood> updateFood(
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

  /// Deletes a food by [id].
  TaskEither<Failure, Unit> deleteFood(int id);
}