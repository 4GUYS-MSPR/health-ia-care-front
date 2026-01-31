import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/nutrition_food.dart';

abstract interface class NutritionRepository {
  TaskEither<Failure, List<NutritionFood>> getFoods();
}
