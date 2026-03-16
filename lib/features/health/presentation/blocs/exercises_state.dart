part of 'exercises_bloc.dart';

sealed class ExercisesState extends Equatable {
  const ExercisesState();

  @override
  List<Object?> get props => [];
}

final class ExercisesInitial extends ExercisesState {
  const ExercisesInitial();
}

final class ExercisesLoading extends ExercisesState {
  const ExercisesLoading();
}

final class ExercisesLoaded extends ExercisesState {
  final List<Exercise> items;
  final PaginationInfo? pagination;

  const ExercisesLoaded({required this.items, this.pagination});

  @override
  List<Object?> get props => [items, pagination];
}

final class ExercisesError extends ExercisesState {
  final Failure failure;
  const ExercisesError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

final class ExerciseCreating extends ExercisesState {
  final List<Exercise> existingItems;

  const ExerciseCreating({required this.existingItems});

  @override
  List<Object?> get props => [existingItems];
}

final class ExerciseCreated extends ExercisesState {
  final Exercise item;
  final List<Exercise> allItems;

  const ExerciseCreated({required this.item, required this.allItems});

  @override
  List<Object?> get props => [item, allItems];
}

final class ExerciseUpdating extends ExercisesState {
  final List<Exercise> existingItems;
  final int updatingId;

  const ExerciseUpdating({required this.existingItems, required this.updatingId});

  @override
  List<Object?> get props => [existingItems, updatingId];
}

final class ExerciseUpdated extends ExercisesState {
  final Exercise item;
  final List<Exercise> allItems;

  const ExerciseUpdated({required this.item, required this.allItems});

  @override
  List<Object?> get props => [item, allItems];
}

final class ExerciseDeleting extends ExercisesState {
  final List<Exercise> existingItems;
  final int deletingId;

  const ExerciseDeleting({required this.existingItems, required this.deletingId});

  @override
  List<Object?> get props => [existingItems, deletingId];
}

final class ExerciseDeleted extends ExercisesState {
  final int deletedId;
  final List<Exercise> remainingItems;

  const ExerciseDeleted({required this.deletedId, required this.remainingItems});

  @override
  List<Object?> get props => [deletedId, remainingItems];
}
