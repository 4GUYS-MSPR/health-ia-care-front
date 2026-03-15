import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/nutrition_food.dart';
import '../repositories/nutrition_repository.dart';

/// Retrieves all foods for the current user.
class GetAllFoodsUsecase with LoggerMixin implements Usecase<List<NutritionFood>, NoParams> {
  final NutritionRepository repository;

  GetAllFoodsUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.GetAllFoodsUsecase';

  @override
  TaskEither<Failure, List<NutritionFood>> call(NoParams params) {
    logger.finest('GetAllFoodsUsecase called');
    return repository.getAllFoods();
  }
}

class NoParams {
  const NoParams();
}
