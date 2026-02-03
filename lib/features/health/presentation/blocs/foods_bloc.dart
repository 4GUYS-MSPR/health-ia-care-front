import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../domain/entities/nutrition_food.dart';
import '../../domain/usecases/create_food_usecase.dart';
import '../../domain/usecases/delete_food_usecase.dart';
import '../../domain/usecases/get_all_foods_usecase.dart';
import '../../domain/usecases/update_food_usecase.dart';

part 'foods_event.dart';
part 'foods_state.dart';

/// Bloc responsible for managing food operations.
class FoodsBloc extends Bloc<FoodsEvent, FoodsState> with LoggerMixin {
  final GetAllFoodsUsecase getAllFoodsUsecase;
  final CreateFoodUsecase createFoodUsecase;
  final UpdateFoodUsecase updateFoodUsecase;
  final DeleteFoodUsecase deleteFoodUsecase;

  FoodsBloc({
    required this.getAllFoodsUsecase,
    required this.createFoodUsecase,
    required this.updateFoodUsecase,
    required this.deleteFoodUsecase,
  }) : super(const FoodsInitial()) {
    on<LoadFoodsRequested>(_onLoadFoodsRequested);
    on<RefreshFoodsRequested>(_onRefreshFoodsRequested);
    on<CreateFoodRequested>(_onCreateFoodRequested);
    on<UpdateFoodRequested>(_onUpdateFoodRequested);
    on<DeleteFoodRequested>(_onDeleteFoodRequested);
  }

  @override
  String get loggerName => 'Health.Presentation.FoodsBloc';

  /// Gets the current foods list from state if available.
  List<NutritionFood> get _currentFoods {
    final currentState = state;
    return switch (currentState) {
      FoodsLoaded(:final foods) => foods,
      FoodCreating(:final existingFoods) => existingFoods,
      FoodCreated(:final allFoods) => allFoods,
      FoodUpdating(:final existingFoods) => existingFoods,
      FoodUpdated(:final allFoods) => allFoods,
      FoodDeleting(:final existingFoods) => existingFoods,
      FoodDeleted(:final remainingFoods) => remainingFoods,
      _ => [],
    };
  }

  Future<void> _onLoadFoodsRequested(
    LoadFoodsRequested event,
    Emitter<FoodsState> emit,
  ) async {
    logger.finest('LoadFoodsRequested received');
    emit(const FoodsLoading());

    final result = await getAllFoodsUsecase(const NoParams()).run();

    result.fold(
      (failure) {
        logger.warning('Failed to load foods: $failure');
        emit(FoodsError(failure: failure));
      },
      (foods) {
        logger.fine('Loaded ${foods.length} foods');
        emit(FoodsLoaded(foods: foods));
      },
    );
  }

  Future<void> _onRefreshFoodsRequested(
    RefreshFoodsRequested event,
    Emitter<FoodsState> emit,
  ) async {
    logger.finest('RefreshFoodsRequested received');

    // Keep showing current data while refreshing
    final currentFoods = _currentFoods;

    final result = await getAllFoodsUsecase(const NoParams()).run();

    result.fold(
      (failure) {
        logger.warning('Failed to refresh foods: $failure');
        // If we had data before, keep it and show error
        if (currentFoods.isNotEmpty) {
          emit(FoodsLoaded(foods: currentFoods));
        } else {
          emit(FoodsError(failure: failure));
        }
      },
      (foods) {
        logger.fine('Refreshed ${foods.length} foods');
        emit(FoodsLoaded(foods: foods));
      },
    );
  }

  Future<void> _onCreateFoodRequested(
    CreateFoodRequested event,
    Emitter<FoodsState> emit,
  ) async {
    logger.finest('CreateFoodRequested received');
    final currentFoods = _currentFoods;
    emit(FoodCreating(existingFoods: currentFoods));

    final result = await createFoodUsecase(
      CreateFoodUsecaseParams(
        label: event.label,
        calories: event.calories,
        protein: event.protein,
        carbohydrates: event.carbohydrates,
        fat: event.fat,
        fiber: event.fiber,
        sugars: event.sugars,
        sodium: event.sodium,
        cholesterol: event.cholesterol,
        waterIntake: event.waterIntake,
        category: event.category,
        mealType: event.mealType,
      ),
    ).run();

    result.fold(
      (failure) {
        logger.warning('Failed to create food: $failure');
        emit(FoodsError(failure: failure));
      },
      (food) {
        logger.fine('Created food with id=${food.id}');
        final updatedFoods = [...currentFoods, food];
        emit(FoodCreated(food: food, allFoods: updatedFoods));
        // Transition to loaded state
        emit(FoodsLoaded(foods: updatedFoods));
      },
    );
  }

  Future<void> _onUpdateFoodRequested(
    UpdateFoodRequested event,
    Emitter<FoodsState> emit,
  ) async {
    logger.finest('UpdateFoodRequested received for id=${event.id}');
    final currentFoods = _currentFoods;
    emit(FoodUpdating(existingFoods: currentFoods, updatingId: event.id));

    final result = await updateFoodUsecase(
      UpdateFoodUsecaseParams(
        id: event.id,
        label: event.label,
        calories: event.calories,
        protein: event.protein,
        carbohydrates: event.carbohydrates,
        fat: event.fat,
        fiber: event.fiber,
        sugars: event.sugars,
        sodium: event.sodium,
        cholesterol: event.cholesterol,
        waterIntake: event.waterIntake,
        category: event.category,
        mealType: event.mealType,
      ),
    ).run();

    result.fold(
      (failure) {
        logger.warning('Failed to update food ${event.id}: $failure');
        emit(FoodsError(failure: failure));
      },
      (food) {
        logger.fine('Updated food ${event.id}');
        final updatedFoods = currentFoods.map((f) => f.id == food.id ? food : f).toList();
        emit(FoodUpdated(food: food, allFoods: updatedFoods));
        // Transition to loaded state
        emit(FoodsLoaded(foods: updatedFoods));
      },
    );
  }

  Future<void> _onDeleteFoodRequested(
    DeleteFoodRequested event,
    Emitter<FoodsState> emit,
  ) async {
    logger.finest('DeleteFoodRequested received for id=${event.id}');
    final currentFoods = _currentFoods;
    emit(FoodDeleting(existingFoods: currentFoods, deletingId: event.id));

    final result = await deleteFoodUsecase(
      DeleteFoodUsecaseParams(id: event.id),
    ).run();

    result.fold(
      (failure) {
        logger.warning('Failed to delete food ${event.id}: $failure');
        emit(FoodsError(failure: failure));
      },
      (_) {
        logger.fine('Deleted food ${event.id}');
        final remainingFoods = currentFoods.where((f) => f.id != event.id).toList();
        emit(
          FoodDeleted(
            deletedId: event.id,
            remainingFoods: remainingFoods,
          ),
        );
        // Transition to loaded state
        emit(FoodsLoaded(foods: remainingFoods));
      },
    );
  }
}