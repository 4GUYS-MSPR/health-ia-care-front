import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/exercise.dart';

abstract interface class ExerciseRepository {
  TaskEither<Failure, List<Exercise>> getAllExercises();

  TaskEither<Failure, Exercise> getExercise(int id);

  TaskEither<Failure, Exercise> createExercise(Exercise exercise);

  TaskEither<Failure, Exercise> updateExercise(int id, Exercise exercise);

  TaskEither<Failure, Unit> deleteExercise(int id);
}
