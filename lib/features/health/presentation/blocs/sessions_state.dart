part of 'sessions_bloc.dart';

sealed class SessionsState extends Equatable {
  const SessionsState();

  @override
  List<Object?> get props => [];
}

final class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

final class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

final class SessionsLoaded extends SessionsState {
  final List<WorkoutSession> items;
  final PaginationInfo? pagination;

  const SessionsLoaded({required this.items, this.pagination});

  @override
  List<Object?> get props => [items, pagination];
}

final class SessionsError extends SessionsState {
  final Failure failure;
  const SessionsError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

final class SessionCreating extends SessionsState {
  final List<WorkoutSession> existingItems;
  const SessionCreating({required this.existingItems});

  @override
  List<Object?> get props => [existingItems];
}

final class SessionCreated extends SessionsState {
  final WorkoutSession item;
  final List<WorkoutSession> allItems;

  const SessionCreated({required this.item, required this.allItems});

  @override
  List<Object?> get props => [item, allItems];
}

final class SessionUpdating extends SessionsState {
  final List<WorkoutSession> existingItems;
  final int updatingId;

  const SessionUpdating({required this.existingItems, required this.updatingId});

  @override
  List<Object?> get props => [existingItems, updatingId];
}

final class SessionUpdated extends SessionsState {
  final WorkoutSession item;
  final List<WorkoutSession> allItems;

  const SessionUpdated({required this.item, required this.allItems});

  @override
  List<Object?> get props => [item, allItems];
}

final class SessionDeleting extends SessionsState {
  final List<WorkoutSession> existingItems;
  final int deletingId;

  const SessionDeleting({required this.existingItems, required this.deletingId});

  @override
  List<Object?> get props => [existingItems, deletingId];
}

final class SessionDeleted extends SessionsState {
  final int deletedId;
  final List<WorkoutSession> remainingItems;

  const SessionDeleted({required this.deletedId, required this.remainingItems});

  @override
  List<Object?> get props => [deletedId, remainingItems];
}
