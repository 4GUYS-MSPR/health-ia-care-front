import '../../../../core/errors/failures.dart';

/// Base class for member-related failures.
sealed class NutritionFailure extends Failure {
  const NutritionFailure({super.debugMessage});
}

/// Member was not found.
class FoodNotFoundException extends NutritionFailure {
  final int foodId;

  const FoodNotFoundException({
    required this.foodId,
    super.debugMessage,
  });

  @override
  List<Object?> get props => [
    foodId,
    debugMessage,
  ];
}

/// Failed to create a new member.
class FoodCreationFailure extends NutritionFailure {
  const FoodCreationFailure({super.debugMessage});
}

/// Failed to update member.
class FoodUpdateFailure extends NutritionFailure {
  final int foodId;

  const FoodUpdateFailure({
    required this.foodId,
    super.debugMessage,
  });

  @override
  List<Object?> get props => [
    foodId,
    debugMessage,
  ];
}

/// Failed to delete member.
class FoodDeleteFailure extends NutritionFailure {
  final int foodId;

  const FoodDeleteFailure({
    required this.foodId,
    super.debugMessage,
  });

  @override
  List<Object?> get props => [
    foodId,
    debugMessage,
  ];
}

/// Failed to fetch members list.
class FoodsFetchFailure extends NutritionFailure {
  const FoodsFetchFailure({super.debugMessage});
}

/// Validation error for member data.
class FoodValidationFailure extends NutritionFailure {
  final String field;

  const FoodValidationFailure({
    required this.field,
    super.debugMessage,
  });

  @override
  List<Object?> get props => [
    field,
    debugMessage,
  ];
}