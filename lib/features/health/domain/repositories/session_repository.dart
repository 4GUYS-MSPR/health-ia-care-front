import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/workout_session.dart';

abstract interface class SessionRepository {
  TaskEither<Failure, List<WorkoutSession>> getAllSessions();

  TaskEither<Failure, WorkoutSession> getSession(int id);

  TaskEither<Failure, WorkoutSession> createSession(WorkoutSession session);

  TaskEither<Failure, WorkoutSession> updateSession(int id, WorkoutSession session);

  TaskEither<Failure, Unit> deleteSession(int id);
}
