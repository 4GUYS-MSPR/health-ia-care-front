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
  final int categoryId;
  final int mealTypeId;

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
  final int? categoryId;
  final int? mealTypeId;

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

/// Event to delete a food.
final class DeleteFoodRequested extends FoodsEvent {
  final int id;

  const DeleteFoodRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event to get a specific page of foods with pagination.
final class GetFoodsPageRequested extends FoodsEvent {
  final int offset;
  final int limit;

  const GetFoodsPageRequested({
    required this.offset,
    required this.limit,
  });

  @override
  List<Object?> get props => [offset, limit];
}

/// Event to load the next page of foods.
final class NextPageRequested extends FoodsEvent {
  const NextPageRequested();
}

/// Event to load the previous page of foods.
final class PreviousPageRequested extends FoodsEvent {
  const PreviousPageRequested();
}
