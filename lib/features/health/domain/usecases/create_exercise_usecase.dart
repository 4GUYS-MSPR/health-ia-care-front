import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class CreateExerciseUsecase with LoggerMixin implements Usecase<Exercise, CreateExerciseParams> {
  final ExerciseRepository repository;

  CreateExerciseUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.CreateExerciseUsecase';

  @override
  TaskEither<Failure, Exercise> call(CreateExerciseParams params) {
    logger.finest('CreateExerciseUsecase called');
    final newExercise = Exercise(
      id: 0, // Assigned by backend
      imageUrl: params.imageUrl,
      category: params.category,
      bodyParts: params.bodyParts ?? [],
      equipments: params.equipments ?? [],
      secondaryMuscles: params.secondaryMuscles ?? [],
      targetMuscles: params.targetMuscles ?? [],
    );
    return repository.createExercise(newExercise);
  }
}

class CreateExerciseParams extends Equatable {
  final String imageUrl;
  final int? category;
  final List<int>? bodyParts;
  final List<int>? equipments;
  final List<int>? secondaryMuscles;
  final List<int>? targetMuscles;

  const CreateExerciseParams({
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
