import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/nutrition_food.dart';
import '../errors/nutrition_failure.dart';
import '../repositories/nutrition_repository.dart';

/// Handles creation of a new food with validation.
class CreateFoodUsecase
    with LoggerMixin
    implements Usecase<NutritionFood, CreateFoodUsecaseParams> {
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

    if (params.categoryId <= 0 || params.mealTypeId <= 0) {
      logger.warning('Validation failed: category/meal type are required');
      return TaskEither.left(
        const FoodValidationFailure(
          field: 'category',
          debugMessage: 'Category and meal type must be selected',
        ),
      );
    }

    logger.fine('Validation passed, delegating to repository');
    final newFood = NutritionFood(
      id: 0, // Assigned by backend
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
      categoryId: params.categoryId,
      mealTypeId: params.mealTypeId,
      category: 'Uncategorized', // Resolved by repository/backend
      mealType: 'Unknown', // Resolved by repository/backend
    );
    return repository.createFood(newFood);
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
  final int categoryId;
  final int mealTypeId;

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
    required this.categoryId,
    required this.mealTypeId,
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
    categoryId,
    mealTypeId,
  ];
}
