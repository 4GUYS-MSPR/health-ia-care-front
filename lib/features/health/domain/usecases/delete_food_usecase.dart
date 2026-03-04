import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/nutrition_repository.dart';

/// Deletes a food by ID.
class DeleteFoodUsecase with LoggerMixin implements Usecase<Unit, DeleteFoodUsecaseParams> {
  final NutritionRepository repository;

  DeleteFoodUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.DeleteFoodUsecase';

  @override
  TaskEither<Failure, Unit> call(DeleteFoodUsecaseParams params) {
    logger.finest('DeleteFoodUsecase called for id=${params.id}');
    return repository.deleteFood(params.id);
  }
}

/// Parameters for [DeleteFoodUsecase].
class DeleteFoodUsecaseParams extends Equatable {
  final int id;

  const DeleteFoodUsecaseParams({required this.id});

  @override
  List<Object?> get props => [id];
}