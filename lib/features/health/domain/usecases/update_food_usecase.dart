import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/nutrition_food.dart';
import '../errors/nutrition_failure.dart';
import '../repositories/nutrition_repository.dart';

/// Updates an existing food with validation.
class UpdateFoodUsecase
    with LoggerMixin
    implements Usecase<NutritionFood, UpdateFoodUsecaseParams> {
  final NutritionRepository repository;

  UpdateFoodUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.UpdateFoodUsecase';

  @override
  TaskEither<Failure, NutritionFood> call(UpdateFoodUsecaseParams params) {
    logger.finest('UpdateFoodUsecase called for id=${params.id}');

    // Validation
    if (params.label != null && params.label!.trim().isEmpty) {
      logger.warning('Validation failed: empty label');
      return TaskEither.left(
        const FoodValidationFailure(
          field: 'label',
          debugMessage: 'Label must not be empty',
        ),
      );
    }

    if (params.calories != null && params.calories! < 0) {
      logger.warning('Validation failed: invalid calories');
      return TaskEither.left(
        const FoodValidationFailure(
          field: 'calories',
          debugMessage: 'Calories must be greater or equal to 0',
        ),
      );
    }

    if ((params.protein != null && params.protein! < 0) ||
        (params.carbohydrates != null && params.carbohydrates! < 0) ||
        (params.fat != null && params.fat! < 0)) {
      logger.warning('Validation failed: invalid macros');
      return TaskEither.left(
        const FoodValidationFailure(
          field: 'macros',
          debugMessage: 'Macros must be greater or equal to 0',
        ),
      );
    }

    logger.fine('Validation passed, delegating to repository');
    final updatedFood = NutritionFood(
      id: params.id,
      label: params.label ?? '',
      calories: params.calories ?? 0,
      protein: params.protein ?? 0.0,
      carbohydrates: params.carbohydrates ?? 0.0,
      fat: params.fat ?? 0.0,
      fiber: params.fiber ?? 0.0,
      sugars: params.sugars ?? 0.0,
      sodium: params.sodium ?? 0,
      cholesterol: params.cholesterol ?? 0,
      waterIntake: params.waterIntake ?? 0,
      categoryId: params.categoryId ?? 0,
      mealTypeId: params.mealTypeId ?? 0,
      category: 'Uncategorized', // Resolved by repository/backend
      mealType: 'Unknown', // Resolved by repository/backend
    );
    return repository.updateFood(params.id, updatedFood);
  }
}

/// Parameters for [UpdateFoodUsecase].
class UpdateFoodUsecaseParams extends Equatable {
  final int id;
  final String? label;
  final int? calories;
  final double? protein;
  final double? carbohydrates;
  final double? fat;
  final double? fiber;
  final double? sugars;
  final int? sodium;
  final int? cholesterol;
  final int? waterIntake;
  final int? categoryId;
  final int? mealTypeId;

  const UpdateFoodUsecaseParams({
    required this.id,
    this.label,
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.fiber,
    this.sugars,
    this.sodium,
    this.cholesterol,
    this.waterIntake,
    this.categoryId,
    this.mealTypeId,
  });

  @override
  List<Object?> get props => [
    id,
    label,
    calories,
    protein,
    carbohydrates,
    fat,
    fiber,
    sugars,
    sodium,
    cholesterol,
    waterIntake,
    categoryId,
    mealTypeId,
  ];
}
