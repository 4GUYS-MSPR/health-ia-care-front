import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class GetAllExercisesUsecase with LoggerMixin implements Usecase<List<Exercise>, NoParams> {
  final ExerciseRepository repository;

  GetAllExercisesUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.GetAllExercisesUsecase';

  @override
  TaskEither<Failure, List<Exercise>> call(NoParams params) {
    logger.finest('GetAllExercisesUsecase called');
    return repository.getAllExercises();
  }
}
