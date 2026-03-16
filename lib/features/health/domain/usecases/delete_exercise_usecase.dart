import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/exercise_repository.dart';

class DeleteExerciseUsecase with LoggerMixin implements Usecase<Unit, DeleteExerciseParams> {
  final ExerciseRepository repository;

  DeleteExerciseUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.DeleteExerciseUsecase';

  @override
  TaskEither<Failure, Unit> call(DeleteExerciseParams params) {
    logger.finest('DeleteExerciseUsecase called for id=${params.id}');
    return repository.deleteExercise(params.id);
  }
}

class DeleteExerciseParams extends Equatable {
  final int id;
  const DeleteExerciseParams({required this.id});

  @override
  List<Object?> get props => [id];
}
