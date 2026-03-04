import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/nutrition_food.dart';
import '../errors/nutrition_failure.dart';
import '../repositories/nutrition_repository.dart';

/// Updates an existing food with validation.
class UpdateFoodUsecase with LoggerMixin implements Usecase<NutritionFood, UpdateFoodUsecaseParams> {
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
    return repository.updateFood(
      params.id,
      label: params.label,
      calories: params.calories,
      protein: params.protein,
      carbohydrates: params.carbohydrates,
      fat: params.fat,
      fiber: params.fiber,
      sugars: params.sugars,
      sodium: params.sodium,
      cholesterol: params.cholesterol,
      waterIntake: params.waterIntake,
      category: params.category,
      mealType: params.mealType,
    );
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
  final String? category;
  final String? mealType;

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
    this.category,
    this.mealType,
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
    category,
    mealType,
  ];
}