part of 'exercises_bloc.dart';

sealed class ExercisesEvent extends Equatable {
  const ExercisesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadExercisesRequested extends ExercisesEvent {
  const LoadExercisesRequested();
}

final class RefreshExercisesRequested extends ExercisesEvent {
  const RefreshExercisesRequested();
}

final class CreateExerciseRequested extends ExercisesEvent {
  final String imageUrl;
  final int? category;
  final List<int>? bodyParts;
  final List<int>? equipments;
  final List<int>? secondaryMuscles;
  final List<int>? targetMuscles;

  const CreateExerciseRequested({
    required this.imageUrl,
    this.category,
    this.bodyParts,
    this.equipments,
    this.secondaryMuscles,
    this.targetMuscles,
  });

  @override
  List<Object?> get props => [imageUrl, category, bodyParts, equipments, secondaryMuscles, targetMuscles];
}

final class UpdateExerciseRequested extends ExercisesEvent {
  final int id;
  final String? imageUrl;
  final int? category;
  final List<int>? bodyParts;
  final List<int>? equipments;
  final List<int>? secondaryMuscles;
  final List<int>? targetMuscles;

  const UpdateExerciseRequested({
    required this.id,
    this.imageUrl,
    this.category,
    this.bodyParts,
    this.equipments,
    this.secondaryMuscles,
    this.targetMuscles,
  });

  @override
  List<Object?> get props => [id, imageUrl, category, bodyParts, equipments, secondaryMuscles, targetMuscles];
}

final class DeleteExerciseRequested extends ExercisesEvent {
  final int id;
  const DeleteExerciseRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

final class GetExercisesPageRequested extends ExercisesEvent {
  final int offset;
  final int limit;
  const GetExercisesPageRequested({required this.offset, required this.limit});

  @override
  List<Object?> get props => [offset, limit];
}

final class ExercisesNextPageRequested extends ExercisesEvent {
  const ExercisesNextPageRequested();
}

final class ExercisesPreviousPageRequested extends ExercisesEvent {
  const ExercisesPreviousPageRequested();
}
