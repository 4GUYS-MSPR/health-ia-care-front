import '../../../../core/errors/failures.dart';

sealed class DietRecommendationFailure extends Failure {
  const DietRecommendationFailure({super.debugMessage});
}

class DietRecommendationNotFoundException extends DietRecommendationFailure {
  final int id;
  const DietRecommendationNotFoundException({required this.id, super.debugMessage});

  @override
  List<Object?> get props => [id, debugMessage];
}

class DietRecommendationCreationFailure extends DietRecommendationFailure {
  const DietRecommendationCreationFailure({super.debugMessage});
}

class DietRecommendationUpdateFailure extends DietRecommendationFailure {
  final int id;
  const DietRecommendationUpdateFailure({required this.id, super.debugMessage});

  @override
  List<Object?> get props => [id, debugMessage];
}

class DietRecommendationDeleteFailure extends DietRecommendationFailure {
  final int id;
  const DietRecommendationDeleteFailure({required this.id, super.debugMessage});

  @override
  List<Object?> get props => [id, debugMessage];
}

class DietRecommendationsFetchFailure extends DietRecommendationFailure {
  const DietRecommendationsFetchFailure({super.debugMessage});
}
