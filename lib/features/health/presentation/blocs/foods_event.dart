part of 'foods_bloc.dart';

/// Base class for all food events.
sealed class FoodsEvent extends Equatable {
  const FoodsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all foods.
final class LoadFoodsRequested extends FoodsEvent {
  const LoadFoodsRequested();
}

/// Event to refresh foods list.
final class RefreshFoodsRequested extends FoodsEvent {
  const RefreshFoodsRequested();
}

/// Event to create a new food.
final class CreateFoodRequested extends FoodsEvent {
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

  const CreateFoodRequested({
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

/// Event to update an existing food.
final class UpdateFoodRequested extends FoodsEvent {
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

  const UpdateFoodRequested({
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

/// Event to delete a food.
final class DeleteFoodRequested extends FoodsEvent {
  final int id;

  const DeleteFoodRequested({required this.id});

  @override
  List<Object?> get props => [id];
}