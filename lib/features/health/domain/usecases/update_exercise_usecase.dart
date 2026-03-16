import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class UpdateExerciseUsecase with LoggerMixin implements Usecase<Exercise, UpdateExerciseParams> {
  final ExerciseRepository repository;

  UpdateExerciseUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.UpdateExerciseUsecase';

  @override
  TaskEither<Failure, Exercise> call(UpdateExerciseParams params) {
    logger.finest('UpdateExerciseUsecase called for id=${params.id}');
    final updatedExercise = Exercise(
      id: params.id,
      imageUrl: params.imageUrl ?? '',
      category: params.category,
      bodyParts: params.bodyParts ?? [],
      equipments: params.equipments ?? [],
      secondaryMuscles: params.secondaryMuscles ?? [],
      targetMuscles: params.targetMuscles ?? [],
    );
    return repository.updateExercise(params.id, updatedExercise);
  }
}

class UpdateExerciseParams extends Equatable {
  final int id;
  final String? imageUrl;
  final int? category;
  final List<int>? bodyParts;
  final List<int>? equipments;
  final List<int>? secondaryMuscles;
  final List<int>? targetMuscles;

  const UpdateExerciseParams({
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
