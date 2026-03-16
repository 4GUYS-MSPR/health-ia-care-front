import '../../../../core/errors/failures.dart';

sealed class ExerciseFailure extends Failure {
  const ExerciseFailure({super.debugMessage});
}

class ExerciseNotFoundException extends ExerciseFailure {
  final int id;
  const ExerciseNotFoundException({required this.id, super.debugMessage});

  @override
  List<Object?> get props => [id, debugMessage];
}

class ExerciseCreationFailure extends ExerciseFailure {
  const ExerciseCreationFailure({super.debugMessage});
}

class ExerciseUpdateFailure extends ExerciseFailure {
  final int id;
  const ExerciseUpdateFailure({required this.id, super.debugMessage});

  @override
  List<Object?> get props => [id, debugMessage];
}

class ExerciseDeleteFailure extends ExerciseFailure {
  final int id;
  const ExerciseDeleteFailure({required this.id, super.debugMessage});

  @override
  List<Object?> get props => [id, debugMessage];
}

class ExercisesFetchFailure extends ExerciseFailure {
  const ExercisesFetchFailure({super.debugMessage});
}
