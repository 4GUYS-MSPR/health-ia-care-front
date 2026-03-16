import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/diet_recommendation_repository.dart';

class DeleteDietRecommendationUsecase with LoggerMixin implements Usecase<Unit, DeleteDietRecommendationParams> {
  final DietRecommendationRepository repository;

  DeleteDietRecommendationUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.DeleteDietRecommendationUsecase';

  @override
  TaskEither<Failure, Unit> call(DeleteDietRecommendationParams params) {
    logger.finest('DeleteDietRecommendationUsecase called for id=${params.id}');
    return repository.deleteDietRecommendation(params.id);
  }
}

class DeleteDietRecommendationParams extends Equatable {
  final int id;
  const DeleteDietRecommendationParams({required this.id});

  @override
  List<Object?> get props => [id];
}
