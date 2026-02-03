import '../../../../core/errors/failures.dart';

abstract class NutritionFailure extends Failure {
  const NutritionFailure({required super.debugMessage});
}

class NutritionConnectionFailure extends NutritionFailure {
  const NutritionConnectionFailure()
      : super( debugMessage: "Pas de connexion internet");
}

class NutritionServerFailure extends NutritionFailure {
  const NutritionServerFailure()
      : super( debugMessage: "Erreur serveur");
}
