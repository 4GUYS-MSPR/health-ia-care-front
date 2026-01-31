import '../../../../core/errors/failures.dart';

abstract class NutritionFailure extends Failure {
  const NutritionFailure({required super.message});
}

class NutritionConnectionFailure extends NutritionFailure {
  const NutritionConnectionFailure()
      : super(message: "Pas de connexion internet");
}

class NutritionServerFailure extends NutritionFailure {
  const NutritionServerFailure()
      : super(message: "Erreur serveur");
}
