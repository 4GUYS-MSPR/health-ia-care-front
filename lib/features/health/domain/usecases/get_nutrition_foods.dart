import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/nutrition_food.dart';
import '../repositories/nutrition_repository.dart';

class GetNutritionFoods implements Usecase<List<NutritionFood>, NoParams> {
  final NutritionRepository repository;

  const GetNutritionFoods(this.repository);

  @override
  TaskEither<Failure, List<NutritionFood>> call(NoParams params) {
    return repository.getFoods();
  }
}
