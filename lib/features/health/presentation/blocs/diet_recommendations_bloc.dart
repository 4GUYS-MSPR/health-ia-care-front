import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../data/datasources/diet_recommendation_remote_data_source.dart';
import '../../domain/entities/diet_recommendation.dart';
import '../../domain/usecases/create_diet_recommendation_usecase.dart';
import '../../domain/usecases/delete_diet_recommendation_usecase.dart';
import '../../domain/usecases/get_all_diet_recommendations_usecase.dart';
import '../../domain/usecases/update_diet_recommendation_usecase.dart';

part 'diet_recommendations_event.dart';
part 'diet_recommendations_state.dart';

class DietRecommendationsBloc extends Bloc<DietRecommendationsEvent, DietRecommendationsState> with LoggerMixin {
  static const int _defaultPageSize = 10;

  final GetAllDietRecommendationsUsecase getAllDietRecommendationsUsecase;
  final CreateDietRecommendationUsecase createDietRecommendationUsecase;
  final UpdateDietRecommendationUsecase updateDietRecommendationUsecase;
  final DeleteDietRecommendationUsecase deleteDietRecommendationUsecase;
  final DietRecommendationRemoteDataSource dataSource;
  PaginationInfo? _currentPagination;

  DietRecommendationsBloc({
    required this.getAllDietRecommendationsUsecase,
    required this.createDietRecommendationUsecase,
    required this.updateDietRecommendationUsecase,
    required this.deleteDietRecommendationUsecase,
    required this.dataSource,
  }) : super(const DietRecommendationsInitial()) {
    on<LoadDietRecommendationsRequested>(_onLoad);
    on<RefreshDietRecommendationsRequested>(_onRefresh);
    on<CreateDietRecommendationRequested>(_onCreate);
    on<UpdateDietRecommendationRequested>(_onUpdate);
    on<DeleteDietRecommendationRequested>(_onDelete);
    on<GetDietRecommendationsPageRequested>(_onGetPage);
    on<DietRecommendationsNextPageRequested>(_onNextPage);
    on<DietRecommendationsPreviousPageRequested>(_onPreviousPage);
  }

  @override
  String get loggerName => 'Health.Presentation.DietRecommendationsBloc';

  List<DietRecommendation> get _currentItems {
    final s = state;
    return switch (s) {
      DietRecommendationsLoaded(:final items) => items,
      DietRecommendationCreating(:final existingItems) => existingItems,
      DietRecommendationCreated(:final allItems) => allItems,
      DietRecommendationUpdating(:final existingItems) => existingItems,
      DietRecommendationUpdated(:final allItems) => allItems,
      DietRecommendationDeleting(:final existingItems) => existingItems,
      DietRecommendationDeleted(:final remainingItems) => remainingItems,
      _ => [],
    };
  }

  Future<void> _onLoad(LoadDietRecommendationsRequested event, Emitter<DietRecommendationsState> emit) async {
    await _loadPage(emit, offset: 0, limit: _defaultPageSize);
  }

  Future<void> _onRefresh(RefreshDietRecommendationsRequested event, Emitter<DietRecommendationsState> emit) async {
    final offset = _currentPagination?.offset ?? 0;
    final limit = _currentPagination?.limit ?? _defaultPageSize;
    await _loadPage(emit, offset: offset, limit: limit);
  }

  Future<void> _onCreate(CreateDietRecommendationRequested event, Emitter<DietRecommendationsState> emit) async {
    final currentItems = _currentItems;
    emit(DietRecommendationCreating(existingItems: currentItems));

    final result = await createDietRecommendationUsecase(
      CreateDietRecommendationParams(
        adherenceToDietPlan: event.adherenceToDietPlan,
        bloodPressure: event.bloodPressure,
        cholesterol: event.cholesterol,
        dailyCaloricIntake: event.dailyCaloricIntake,
        dietaryNutrientImbalanceScore: event.dietaryNutrientImbalanceScore,
        glucose: event.glucose,
        weeklyExerciseHours: event.weeklyExerciseHours,
        activity: event.activity,
        allergies: event.allergies,
        dietaryRestrictions: event.dietaryRestrictions,
        diseaseType: event.diseaseType,
        member: event.member,
        preferredCuisine: event.preferredCuisine,
        severity: event.severity,
      ),
    ).run();

    await result.fold<Future<void>>(
      (failure) async => emit(DietRecommendationsError(failure: failure)),
      (item) async {
        final updatedItems = [...currentItems, item];
        emit(DietRecommendationCreated(item: item, allItems: updatedItems));
        add(GetDietRecommendationsPageRequested(
          offset: _currentPagination?.offset ?? 0,
          limit: _currentPagination?.limit ?? _defaultPageSize,
        ));
      },
    );
  }

  Future<void> _onUpdate(UpdateDietRecommendationRequested event, Emitter<DietRecommendationsState> emit) async {
    final currentItems = _currentItems;
    emit(DietRecommendationUpdating(existingItems: currentItems, updatingId: event.id));

    final result = await updateDietRecommendationUsecase(
      UpdateDietRecommendationParams(
        id: event.id,
        adherenceToDietPlan: event.adherenceToDietPlan,
        bloodPressure: event.bloodPressure,
        cholesterol: event.cholesterol,
        dailyCaloricIntake: event.dailyCaloricIntake,
        dietaryNutrientImbalanceScore: event.dietaryNutrientImbalanceScore,
        glucose: event.glucose,
        weeklyExerciseHours: event.weeklyExerciseHours,
        activity: event.activity,
        allergies: event.allergies,
        dietaryRestrictions: event.dietaryRestrictions,
        diseaseType: event.diseaseType,
        member: event.member,
        preferredCuisine: event.preferredCuisine,
        severity: event.severity,
      ),
    ).run();

    await result.fold<Future<void>>(
      (failure) async => emit(DietRecommendationsError(failure: failure)),
      (item) async {
        final updatedItems = currentItems.map((i) => i.id == item.id ? item : i).toList();
        emit(DietRecommendationUpdated(item: item, allItems: updatedItems));
        add(GetDietRecommendationsPageRequested(
          offset: _currentPagination?.offset ?? 0,
          limit: _currentPagination?.limit ?? _defaultPageSize,
        ));
      },
    );
  }

  Future<void> _onDelete(DeleteDietRecommendationRequested event, Emitter<DietRecommendationsState> emit) async {
    final currentItems = _currentItems;
    emit(DietRecommendationDeleting(existingItems: currentItems, deletingId: event.id));

    final result = await deleteDietRecommendationUsecase(DeleteDietRecommendationParams(id: event.id)).run();
    await result.fold<Future<void>>(
      (failure) async => emit(DietRecommendationsError(failure: failure)),
      (_) async {
        final remaining = currentItems.where((i) => i.id != event.id).toList();
        emit(DietRecommendationDeleted(deletedId: event.id, remainingItems: remaining));
        add(GetDietRecommendationsPageRequested(
          offset: _currentPagination?.offset ?? 0,
          limit: _currentPagination?.limit ?? _defaultPageSize,
        ));
      },
    );
  }

  Future<void> _onGetPage(GetDietRecommendationsPageRequested event, Emitter<DietRecommendationsState> emit) async {
    await _loadPage(emit, offset: event.offset, limit: event.limit);
  }

  Future<void> _onNextPage(DietRecommendationsNextPageRequested event, Emitter<DietRecommendationsState> emit) async {
    if (_currentPagination == null || !_currentPagination!.hasNextPage) return;
    await _loadPage(emit, offset: _currentPagination!.offset + _currentPagination!.limit, limit: _currentPagination!.limit);
  }

  Future<void> _onPreviousPage(DietRecommendationsPreviousPageRequested event, Emitter<DietRecommendationsState> emit) async {
    if (_currentPagination == null || !_currentPagination!.hasPreviousPage) return;
    final newOffset = (_currentPagination!.offset - _currentPagination!.limit).clamp(0, _currentPagination!.offset);
    await _loadPage(emit, offset: newOffset, limit: _currentPagination!.limit);
  }

  Future<void> _loadPage(Emitter<DietRecommendationsState> emit, {required int offset, required int limit}) async {
    emit(const DietRecommendationsLoading());
    try {
      final (items, pagination) = await dataSource.getDietRecommendationsPage(offset: offset, limit: limit);
      _currentPagination = pagination;
      if (emit.isDone) return;
      emit(DietRecommendationsLoaded(items: items.cast<DietRecommendation>(), pagination: pagination));
    } on ServerErrorFailure catch (e) {
      if (emit.isDone) return;
      emit(DietRecommendationsError(failure: e));
    } catch (e) {
      if (emit.isDone) return;
      emit(DietRecommendationsError(failure: ServerErrorFailure(debugMessage: e.toString())));
    }
  }
}
