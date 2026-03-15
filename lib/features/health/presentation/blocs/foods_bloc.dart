import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../data/datasources/nutrition_remote_data_source.dart';
import '../../domain/entities/nutrition_food.dart';
import '../../domain/usecases/create_food_usecase.dart';
import '../../domain/usecases/delete_food_usecase.dart';
import '../../domain/usecases/get_all_foods_usecase.dart';
import '../../domain/usecases/update_food_usecase.dart';

part 'foods_event.dart';
part 'foods_state.dart';

/// Bloc responsible for managing food operations.
class FoodsBloc extends Bloc<FoodsEvent, FoodsState> with LoggerMixin {
  static const int _defaultPageSize = 20;

  final GetAllFoodsUsecase getAllFoodsUsecase;
  final CreateFoodUsecase createFoodUsecase;
  final UpdateFoodUsecase updateFoodUsecase;
  final DeleteFoodUsecase deleteFoodUsecase;

  late NutritionRemoteDataSource _dataSource;
  PaginationInfo? _currentPagination;

  FoodsBloc({
    required this.getAllFoodsUsecase,
    required this.createFoodUsecase,
    required this.updateFoodUsecase,
    required this.deleteFoodUsecase,
  }) : super(const FoodsInitial()) {
    _dataSource = GetIt.instance<NutritionRemoteDataSource>();

    on<LoadFoodsRequested>(_onLoadFoodsRequested);
    on<RefreshFoodsRequested>(_onRefreshFoodsRequested);
    on<CreateFoodRequested>(_onCreateFoodRequested);
    on<UpdateFoodRequested>(_onUpdateFoodRequested);
    on<DeleteFoodRequested>(_onDeleteFoodRequested);
    on<GetFoodsPageRequested>(_onGetFoodsPageRequested);
    on<NextPageRequested>(_onNextPageRequested);
    on<PreviousPageRequested>(_onPreviousPageRequested);
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
    // Load first page instead of all foods
    await _loadPage(emit, offset: 0, limit: FoodsBloc._defaultPageSize);
  }

  Future<void> _onRefreshFoodsRequested(
    RefreshFoodsRequested event,
    Emitter<FoodsState> emit,
  ) async {
    logger.finest('RefreshFoodsRequested received');
    // Refresh current page or first page
    final offset = _currentPagination?.offset ?? 0;
    final limit = _currentPagination?.limit ?? FoodsBloc._defaultPageSize;
    await _loadPage(emit, offset: offset, limit: limit);
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

    await result.fold<Future<void>>(
      (failure) async {
        logger.warning('Failed to create food: $failure');
        emit(FoodsError(failure: failure));
      },
      (food) async {
        logger.fine('Created food with id=${food.id}');
        final updatedFoods = [...currentFoods, food];
        emit(FoodCreated(food: food, allFoods: updatedFoods));
        // Reload page to get updated pagination
        add(
          GetFoodsPageRequested(
            offset: _currentPagination?.offset ?? 0,
            limit: _currentPagination?.limit ?? _defaultPageSize,
          ),
        );
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

    await result.fold<Future<void>>(
      (failure) async {
        logger.warning('Failed to update food ${event.id}: $failure');
        emit(FoodsError(failure: failure));
      },
      (food) async {
        logger.fine('Updated food ${event.id}');
        final updatedFoods = currentFoods.map((f) => f.id == food.id ? food : f).toList();
        emit(FoodUpdated(food: food, allFoods: updatedFoods));
        // Reload page to get updated pagination
        add(
          GetFoodsPageRequested(
            offset: _currentPagination?.offset ?? 0,
            limit: _currentPagination?.limit ?? _defaultPageSize,
          ),
        );
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

    await result.fold<Future<void>>(
      (failure) async {
        logger.warning('Failed to delete food ${event.id}: $failure');
        emit(FoodsError(failure: failure));
      },
      (_) async {
        logger.fine('Deleted food ${event.id}');
        final remainingFoods = currentFoods.where((f) => f.id != event.id).toList();
        emit(
          FoodDeleted(
            deletedId: event.id,
            remainingFoods: remainingFoods,
          ),
        );
        // Reload page to get updated pagination
        add(
          GetFoodsPageRequested(
            offset: _currentPagination?.offset ?? 0,
            limit: _currentPagination?.limit ?? _defaultPageSize,
          ),
        );
      },
    );
  }

  Future<void> _onGetFoodsPageRequested(
    GetFoodsPageRequested event,
    Emitter<FoodsState> emit,
  ) async {
    logger.finest(
      'GetFoodsPageRequested received with offset=${event.offset}, limit=${event.limit}',
    );
    await _loadPage(emit, offset: event.offset, limit: event.limit);
  }

  Future<void> _onNextPageRequested(
    NextPageRequested event,
    Emitter<FoodsState> emit,
  ) async {
    logger.finest('NextPageRequested received');
    if (_currentPagination == null || !_currentPagination!.hasNextPage) {
      logger.fine('No next page available');
      return;
    }
    await _loadPage(
      emit,
      offset: _currentPagination!.offset + _currentPagination!.limit,
      limit: _currentPagination!.limit,
    );
  }

  Future<void> _onPreviousPageRequested(
    PreviousPageRequested event,
    Emitter<FoodsState> emit,
  ) async {
    logger.finest('PreviousPageRequested received');
    if (_currentPagination == null || !_currentPagination!.hasPreviousPage) {
      logger.fine('No previous page available');
      return;
    }
    final newOffset = (_currentPagination!.offset - _currentPagination!.limit).clamp(
      0,
      _currentPagination!.offset,
    );
    await _loadPage(
      emit,
      offset: newOffset,
      limit: _currentPagination!.limit,
    );
  }

  Future<void> _loadPage(
    Emitter<FoodsState> emit, {
    required int offset,
    required int limit,
  }) async {
    logger.finest('_loadPage called with offset=$offset, limit=$limit');
    emit(const FoodsLoading());

    try {
      final (foods, pagination) = await _dataSource.getFoodsPage(
        offset: offset,
        limit: limit,
      );

      _currentPagination = pagination;

      // Convert models to entities
      final foodEntities = foods.cast<NutritionFood>();

      if (emit.isDone) {
        return;
      }
      logger.fine('Loaded page with ${foodEntities.length} foods');
      emit(FoodsLoaded(foods: foodEntities, pagination: pagination));
    } on ServerErrorFailure catch (e) {
      if (emit.isDone) {
        return;
      }
      logger.severe('Failed to load foods page: $e');
      emit(FoodsError(failure: e));
    } catch (e) {
      if (emit.isDone) {
        return;
      }
      logger.severe('Unexpected error loading foods page: $e');
      emit(
        FoodsError(
          failure: ServerErrorFailure(debugMessage: e.toString()),
        ),
      );
    }
  }
}
