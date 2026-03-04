import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/nutrition_food.dart';
import '../errors/nutrition_failure.dart';
import '../repositories/nutrition_repository.dart';

/// Handles creation of a new food with validation.
class CreateFoodUsecase with LoggerMixin implements Usecase<NutritionFood, CreateFoodUsecaseParams> {
  final NutritionRepository repository;

  CreateFoodUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.CreateFoodUsecase';

  @override
  TaskEither<Failure, NutritionFood> call(CreateFoodUsecaseParams params) {
    logger.finest('CreateFoodUsecase called');

    // Validation
    if (params.label.trim().isEmpty) {
      logger.warning('Validation failed: empty label');
      return TaskEither.left(
        const FoodValidationFailure(
          field: 'label',
          debugMessage: 'Label must not be empty',
        ),
      );
    }

    if (params.calories < 0) {
      logger.warning('Validation failed: invalid calories');
      return TaskEither.left(
        const FoodValidationFailure(
          field: 'calories',
          debugMessage: 'Calories must be greater or equal to 0',
        ),
      );
    }

    if (params.protein < 0 || params.carbohydrates < 0 || params.fat < 0) {
      logger.warning('Validation failed: invalid macros');
      return TaskEither.left(
        const FoodValidationFailure(
          field: 'macros',
          debugMessage: 'Macros must be greater or equal to 0',
        ),
      );
    }

    logger.fine('Validation passed, delegating to repository');
    return repository.createFood(
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

/// Parameters for [CreateFoodUsecase].
class CreateFoodUsecaseParams extends Equatable {
  final String label;
  final int calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugars;
  final int sodium;
  final int cholesterol;
  final int waterIntake;
  final String category;
  final String mealType;

  const CreateFoodUsecaseParams({
    required this.label,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.sugars,
    required this.sodium,
    required this.cholesterol,
    required this.waterIntake,
    required this.category,
    required this.mealType,
  });

  @override
  List<Object?> get props => [
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