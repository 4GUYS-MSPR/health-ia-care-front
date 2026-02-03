import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/nutrition_food.dart';
import '../repositories/nutrition_repository.dart';

/// Retrieves a single food by ID.
class GetFoodUsecase with LoggerMixin implements Usecase<NutritionFood, GetFoodUsecaseParams> {
  final NutritionRepository repository;

  GetFoodUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.GetFoodUsecase';

  @override
  TaskEither<Failure, NutritionFood> call(GetFoodUsecaseParams params) {
    logger.finest('GetFoodUsecase called for id=${params.id}');
    return repository.getFood(params.id);
  }
}

/// Parameters for [GetFoodUsecase].
class GetFoodUsecaseParams extends Equatable {
  final int id;

  const GetFoodUsecaseParams({required this.id});

  @override
  List<Object?> get props => [id];
}