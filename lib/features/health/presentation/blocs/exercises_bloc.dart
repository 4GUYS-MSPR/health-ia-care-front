import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../data/datasources/exercise_remote_data_source.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/usecases/create_exercise_usecase.dart';
import '../../domain/usecases/delete_exercise_usecase.dart';
import '../../domain/usecases/get_all_exercises_usecase.dart';
import '../../domain/usecases/update_exercise_usecase.dart';

part 'exercises_event.dart';
part 'exercises_state.dart';

class ExercisesBloc extends Bloc<ExercisesEvent, ExercisesState> with LoggerMixin {
  static const int _defaultPageSize = 10;

  final GetAllExercisesUsecase getAllExercisesUsecase;
  final CreateExerciseUsecase createExerciseUsecase;
  final UpdateExerciseUsecase updateExerciseUsecase;
  final DeleteExerciseUsecase deleteExerciseUsecase;
  final ExerciseRemoteDataSource dataSource;
  PaginationInfo? _currentPagination;

  ExercisesBloc({
    required this.getAllExercisesUsecase,
    required this.createExerciseUsecase,
    required this.updateExerciseUsecase,
    required this.deleteExerciseUsecase,
    required this.dataSource,
  }) : super(const ExercisesInitial()) {
    on<LoadExercisesRequested>(_onLoad);
    on<RefreshExercisesRequested>(_onRefresh);
    on<CreateExerciseRequested>(_onCreate);
    on<UpdateExerciseRequested>(_onUpdate);
    on<DeleteExerciseRequested>(_onDelete);
    on<GetExercisesPageRequested>(_onGetPage);
    on<ExercisesNextPageRequested>(_onNextPage);
    on<ExercisesPreviousPageRequested>(_onPreviousPage);
  }

  @override
  String get loggerName => 'Health.Presentation.ExercisesBloc';

  List<Exercise> get _currentItems {
    final s = state;
    return switch (s) {
      ExercisesLoaded(:final items) => items,
      ExerciseCreating(:final existingItems) => existingItems,
      ExerciseCreated(:final allItems) => allItems,
      ExerciseUpdating(:final existingItems) => existingItems,
      ExerciseUpdated(:final allItems) => allItems,
      ExerciseDeleting(:final existingItems) => existingItems,
      ExerciseDeleted(:final remainingItems) => remainingItems,
      _ => [],
    };
  }

  Future<void> _onLoad(LoadExercisesRequested event, Emitter<ExercisesState> emit) async {
    await _loadPage(emit, offset: 0, limit: _defaultPageSize);
  }

  Future<void> _onRefresh(RefreshExercisesRequested event, Emitter<ExercisesState> emit) async {
    final offset = _currentPagination?.offset ?? 0;
    final limit = _currentPagination?.limit ?? _defaultPageSize;
    await _loadPage(emit, offset: offset, limit: limit);
  }

  Future<void> _onCreate(CreateExerciseRequested event, Emitter<ExercisesState> emit) async {
    final currentItems = _currentItems;
    emit(ExerciseCreating(existingItems: currentItems));

    final result = await createExerciseUsecase(
      CreateExerciseParams(
        imageUrl: event.imageUrl,
        category: event.category,
        bodyParts: event.bodyParts,
        equipments: event.equipments,
        secondaryMuscles: event.secondaryMuscles,
        targetMuscles: event.targetMuscles,
      ),
    ).run();

    await result.fold<Future<void>>(
      (failure) async => emit(ExercisesError(failure: failure)),
      (item) async {
        final updatedItems = [...currentItems, item];
        emit(ExerciseCreated(item: item, allItems: updatedItems));
        add(GetExercisesPageRequested(
          offset: _currentPagination?.offset ?? 0,
          limit: _currentPagination?.limit ?? _defaultPageSize,
        ));
      },
    );
  }

  Future<void> _onUpdate(UpdateExerciseRequested event, Emitter<ExercisesState> emit) async {
    final currentItems = _currentItems;
    emit(ExerciseUpdating(existingItems: currentItems, updatingId: event.id));

    final result = await updateExerciseUsecase(
      UpdateExerciseParams(
        id: event.id,
        imageUrl: event.imageUrl,
        category: event.category,
        bodyParts: event.bodyParts,
        equipments: event.equipments,
        secondaryMuscles: event.secondaryMuscles,
        targetMuscles: event.targetMuscles,
      ),
    ).run();

    await result.fold<Future<void>>(
      (failure) async => emit(ExercisesError(failure: failure)),
      (item) async {
        final updatedItems = currentItems.map((i) => i.id == item.id ? item : i).toList();
        emit(ExerciseUpdated(item: item, allItems: updatedItems));
        add(GetExercisesPageRequested(
          offset: _currentPagination?.offset ?? 0,
          limit: _currentPagination?.limit ?? _defaultPageSize,
        ));
      },
    );
  }

  Future<void> _onDelete(DeleteExerciseRequested event, Emitter<ExercisesState> emit) async {
    final currentItems = _currentItems;
    emit(ExerciseDeleting(existingItems: currentItems, deletingId: event.id));

    final result = await deleteExerciseUsecase(DeleteExerciseParams(id: event.id)).run();
    await result.fold<Future<void>>(
      (failure) async => emit(ExercisesError(failure: failure)),
      (_) async {
        final remaining = currentItems.where((i) => i.id != event.id).toList();
        emit(ExerciseDeleted(deletedId: event.id, remainingItems: remaining));
        add(GetExercisesPageRequested(
          offset: _currentPagination?.offset ?? 0,
          limit: _currentPagination?.limit ?? _defaultPageSize,
        ));
      },
    );
  }

  Future<void> _onGetPage(GetExercisesPageRequested event, Emitter<ExercisesState> emit) async {
    await _loadPage(emit, offset: event.offset, limit: event.limit);
  }

  Future<void> _onNextPage(ExercisesNextPageRequested event, Emitter<ExercisesState> emit) async {
    if (_currentPagination == null || !_currentPagination!.hasNextPage) return;
    await _loadPage(emit, offset: _currentPagination!.offset + _currentPagination!.limit, limit: _currentPagination!.limit);
  }

  Future<void> _onPreviousPage(ExercisesPreviousPageRequested event, Emitter<ExercisesState> emit) async {
    if (_currentPagination == null || !_currentPagination!.hasPreviousPage) return;
    final newOffset = (_currentPagination!.offset - _currentPagination!.limit).clamp(0, _currentPagination!.offset);
    await _loadPage(emit, offset: newOffset, limit: _currentPagination!.limit);
  }

  Future<void> _loadPage(Emitter<ExercisesState> emit, {required int offset, required int limit}) async {
    emit(const ExercisesLoading());
    try {
      final (items, pagination) = await dataSource.getExercisesPage(offset: offset, limit: limit);
      _currentPagination = pagination;
      if (emit.isDone) return;
      emit(ExercisesLoaded(items: items.cast<Exercise>(), pagination: pagination));
    } on ServerErrorFailure catch (e) {
      if (emit.isDone) return;
      emit(ExercisesError(failure: e));
    } catch (e) {
      if (emit.isDone) return;
      emit(ExercisesError(failure: ServerErrorFailure(debugMessage: e.toString())));
    }
  }
}
