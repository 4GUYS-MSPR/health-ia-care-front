import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../data/datasources/session_remote_data_source.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/usecases/create_session_usecase.dart';
import '../../domain/usecases/delete_session_usecase.dart';
import '../../domain/usecases/get_all_sessions_usecase.dart';
import '../../domain/usecases/update_session_usecase.dart';

part 'sessions_event.dart';
part 'sessions_state.dart';

class SessionsBloc extends Bloc<SessionsEvent, SessionsState> with LoggerMixin {
  static const int _defaultPageSize = 10;

  final GetAllSessionsUsecase getAllSessionsUsecase;
  final CreateSessionUsecase createSessionUsecase;
  final UpdateSessionUsecase updateSessionUsecase;
  final DeleteSessionUsecase deleteSessionUsecase;
  final SessionRemoteDataSource dataSource;
  PaginationInfo? _currentPagination;

  SessionsBloc({
    required this.getAllSessionsUsecase,
    required this.createSessionUsecase,
    required this.updateSessionUsecase,
    required this.deleteSessionUsecase,
    required this.dataSource,
  }) : super(const SessionsInitial()) {
    on<LoadSessionsRequested>(_onLoad);
    on<RefreshSessionsRequested>(_onRefresh);
    on<CreateSessionRequested>(_onCreate);
    on<UpdateSessionRequested>(_onUpdate);
    on<DeleteSessionRequested>(_onDelete);
    on<GetSessionsPageRequested>(_onGetPage);
    on<SessionsNextPageRequested>(_onNextPage);
    on<SessionsPreviousPageRequested>(_onPreviousPage);
  }

  @override
  String get loggerName => 'Health.Presentation.SessionsBloc';

  List<WorkoutSession> get _currentItems {
    final s = state;
    return switch (s) {
      SessionsLoaded(:final items) => items,
      SessionCreating(:final existingItems) => existingItems,
      SessionCreated(:final allItems) => allItems,
      SessionUpdating(:final existingItems) => existingItems,
      SessionUpdated(:final allItems) => allItems,
      SessionDeleting(:final existingItems) => existingItems,
      SessionDeleted(:final remainingItems) => remainingItems,
      _ => [],
    };
  }

  Future<void> _onLoad(LoadSessionsRequested event, Emitter<SessionsState> emit) async {
    await _loadPage(emit, offset: 0, limit: _defaultPageSize);
  }

  Future<void> _onRefresh(RefreshSessionsRequested event, Emitter<SessionsState> emit) async {
    final offset = _currentPagination?.offset ?? 0;
    final limit = _currentPagination?.limit ?? _defaultPageSize;
    await _loadPage(emit, offset: offset, limit: limit);
  }

  Future<void> _onCreate(CreateSessionRequested event, Emitter<SessionsState> emit) async {
    final currentItems = _currentItems;
    emit(SessionCreating(existingItems: currentItems));

    final result = await createSessionUsecase(
      CreateSessionParams(
        caloriesBurned: event.caloriesBurned,
        duration: event.duration,
        avgBpm: event.avgBpm,
        maxBpm: event.maxBpm,
        restingBpm: event.restingBpm,
        waterIntake: event.waterIntake,
        member: event.member,
        exercices: event.exercices,
      ),
    ).run();

    await result.fold<Future<void>>(
      (failure) async => emit(SessionsError(failure: failure)),
      (item) async {
        final updatedItems = [...currentItems, item];
        emit(SessionCreated(item: item, allItems: updatedItems));
        add(GetSessionsPageRequested(
          offset: _currentPagination?.offset ?? 0,
          limit: _currentPagination?.limit ?? _defaultPageSize,
        ));
      },
    );
  }

  Future<void> _onUpdate(UpdateSessionRequested event, Emitter<SessionsState> emit) async {
    final currentItems = _currentItems;
    emit(SessionUpdating(existingItems: currentItems, updatingId: event.id));

    final result = await updateSessionUsecase(
      UpdateSessionParams(
        id: event.id,
        caloriesBurned: event.caloriesBurned,
        duration: event.duration,
        avgBpm: event.avgBpm,
        maxBpm: event.maxBpm,
        restingBpm: event.restingBpm,
        waterIntake: event.waterIntake,
        member: event.member,
        exercices: event.exercices,
      ),
    ).run();

    await result.fold<Future<void>>(
      (failure) async => emit(SessionsError(failure: failure)),
      (item) async {
        final updatedItems = currentItems.map((i) => i.id == item.id ? item : i).toList();
        emit(SessionUpdated(item: item, allItems: updatedItems));
        add(GetSessionsPageRequested(
          offset: _currentPagination?.offset ?? 0,
          limit: _currentPagination?.limit ?? _defaultPageSize,
        ));
      },
    );
  }

  Future<void> _onDelete(DeleteSessionRequested event, Emitter<SessionsState> emit) async {
    final currentItems = _currentItems;
    emit(SessionDeleting(existingItems: currentItems, deletingId: event.id));

    final result = await deleteSessionUsecase(DeleteSessionParams(id: event.id)).run();
    await result.fold<Future<void>>(
      (failure) async => emit(SessionsError(failure: failure)),
      (_) async {
        final remaining = currentItems.where((i) => i.id != event.id).toList();
        emit(SessionDeleted(deletedId: event.id, remainingItems: remaining));
        add(GetSessionsPageRequested(
          offset: _currentPagination?.offset ?? 0,
          limit: _currentPagination?.limit ?? _defaultPageSize,
        ));
      },
    );
  }

  Future<void> _onGetPage(GetSessionsPageRequested event, Emitter<SessionsState> emit) async {
    await _loadPage(emit, offset: event.offset, limit: event.limit);
  }

  Future<void> _onNextPage(SessionsNextPageRequested event, Emitter<SessionsState> emit) async {
    if (_currentPagination == null || !_currentPagination!.hasNextPage) return;
    await _loadPage(emit, offset: _currentPagination!.offset + _currentPagination!.limit, limit: _currentPagination!.limit);
  }

  Future<void> _onPreviousPage(SessionsPreviousPageRequested event, Emitter<SessionsState> emit) async {
    if (_currentPagination == null || !_currentPagination!.hasPreviousPage) return;
    final newOffset = (_currentPagination!.offset - _currentPagination!.limit).clamp(0, _currentPagination!.offset);
    await _loadPage(emit, offset: newOffset, limit: _currentPagination!.limit);
  }

  Future<void> _loadPage(Emitter<SessionsState> emit, {required int offset, required int limit}) async {
    emit(const SessionsLoading());
    try {
      final (items, pagination) = await dataSource.getSessionsPage(offset: offset, limit: limit);
      _currentPagination = pagination;
      if (emit.isDone) return;
      emit(SessionsLoaded(items: items.cast<WorkoutSession>(), pagination: pagination));
    } on ServerErrorFailure catch (e) {
      if (emit.isDone) return;
      emit(SessionsError(failure: e));
    } catch (e) {
      if (emit.isDone) return;
      emit(SessionsError(failure: ServerErrorFailure(debugMessage: e.toString())));
    }
  }
}
