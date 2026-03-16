import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/nutrition_food.dart';

abstract interface class NutritionRepository {
  /// Gets all foods.
  TaskEither<Failure, List<NutritionFood>> getAllFoods();

  /// Creates a new food with the given data.
  TaskEither<Failure, NutritionFood> createFood(NutritionFood food);

  /// Gets a single food by [id].
  TaskEither<Failure, NutritionFood> getFood(int id);

  /// Updates a food by [id] with partial data.
  TaskEither<Failure, NutritionFood> updateFood(int id, NutritionFood food);

  /// Deletes a food by [id].
  TaskEither<Failure, Unit> deleteFood(int id);
}
