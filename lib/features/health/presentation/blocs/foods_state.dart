part of 'foods_bloc.dart';

/// Base class for all food states.
sealed class FoodsState extends Equatable {
  const FoodsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
final class FoodsInitial extends FoodsState {
  const FoodsInitial();
}

/// Loading state while fetching foods.
final class FoodsLoading extends FoodsState {
  const FoodsLoading();
}

/// Loaded state with foods list.
final class FoodsLoaded extends FoodsState {
  final List<NutritionFood> foods;
  final PaginationInfo? pagination;

  const FoodsLoaded({
    required this.foods,
    this.pagination,
  });

  @override
  List<Object?> get props => [foods, pagination];
}


/// Error state with failure information.
final class FoodsError extends FoodsState {
  final Failure failure;

  const FoodsError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

/// State while creating a food.
final class FoodCreating extends FoodsState {
  final List<NutritionFood> existingFoods;

  const FoodCreating({required this.existingFoods});

  @override
  List<Object?> get props => [existingFoods];
}

/// State after food is created successfully.
final class FoodCreated extends FoodsState {
  final NutritionFood food;
  final List<NutritionFood> allFoods;

  const FoodCreated({
    required this.food,
    required this.allFoods,
  });

  @override
  List<Object?> get props => [food, allFoods];
}

/// State while updating a food.
final class FoodUpdating extends FoodsState {
  final List<NutritionFood> existingFoods;
  final int updatingId;

  const FoodUpdating({
    required this.existingFoods,
    required this.updatingId,
  });

  @override
  List<Object?> get props => [existingFoods, updatingId];
}

/// State after food is updated successfully.
final class FoodUpdated extends FoodsState {
  final NutritionFood food;
  final List<NutritionFood> allFoods;

  const FoodUpdated({
    required this.food,
    required this.allFoods,
  });

  @override
  List<Object?> get props => [food, allFoods];
}

/// State while deleting a food.
final class FoodDeleting extends FoodsState {
  final List<NutritionFood> existingFoods;
  final int deletingId;

  const FoodDeleting({
    required this.existingFoods,
    required this.deletingId,
  });

  @override
  List<Object?> get props => [existingFoods, deletingId];
}

/// State after food is deleted successfully.
final class FoodDeleted extends FoodsState {
  final int deletedId;
  final List<NutritionFood> remainingFoods;

  const FoodDeleted({
    required this.deletedId,
    required this.remainingFoods,
  });

  @override
  List<Object?> get props => [deletedId, remainingFoods];
}