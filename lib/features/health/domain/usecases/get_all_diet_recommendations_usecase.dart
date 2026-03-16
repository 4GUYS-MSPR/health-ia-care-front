import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diet_recommendation.dart';
import '../repositories/diet_recommendation_repository.dart';

class GetAllDietRecommendationsUsecase with LoggerMixin implements Usecase<List<DietRecommendation>, NoParams> {
  final DietRecommendationRepository repository;

  GetAllDietRecommendationsUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.GetAllDietRecommendationsUsecase';

  @override
  TaskEither<Failure, List<DietRecommendation>> call(NoParams params) {
    logger.finest('GetAllDietRecommendationsUsecase called');
    return repository.getAllDietRecommendations();
  }
}
