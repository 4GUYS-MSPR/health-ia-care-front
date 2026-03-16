import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/diet_recommendation.dart';

abstract interface class DietRecommendationRepository {
  TaskEither<Failure, List<DietRecommendation>> getAllDietRecommendations();

  TaskEither<Failure, DietRecommendation> getDietRecommendation(int id);

  TaskEither<Failure, DietRecommendation> createDietRecommendation(
    DietRecommendation recommendation,
  );

  TaskEither<Failure, DietRecommendation> updateDietRecommendation(
    int id,
    DietRecommendation recommendation,
  );

  TaskEither<Failure, Unit> deleteDietRecommendation(int id);
}
