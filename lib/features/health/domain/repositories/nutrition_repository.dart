import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/export_format.dart';
import '../entities/food_import_row.dart';
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

  /// Imports validated rows through backend bulk import endpoint.
  TaskEither<Failure, Unit> importFoods(List<FoodImportRow> rows);

  /// Generic import payload by backend action classname.
  ///
  /// [classname] examples: DietRecommendationAction, ExerciceAction,
  /// FoodAction, MemberAction, SessionAction.
  /// [jsonArrayPayload] must be a JSON-encoded array.
  TaskEither<Failure, Unit> importByClassname({
    required String classname,
    required String jsonArrayPayload,
  });

  /// Exports all foods as serialized content.
  TaskEither<Failure, String> exportFoods(ExportFormat format);

  /// Exports entity data by backend classname as serialized content.
  TaskEither<Failure, String> exportByClassname({
    required String classname,
    required ExportFormat format,
  });
}
