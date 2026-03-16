import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/workout_session.dart';
import '../repositories/session_repository.dart';

class CreateSessionUsecase with LoggerMixin implements Usecase<WorkoutSession, CreateSessionParams> {
  final SessionRepository repository;

  CreateSessionUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.CreateSessionUsecase';

  @override
  TaskEither<Failure, WorkoutSession> call(CreateSessionParams params) {
    logger.finest('CreateSessionUsecase called');
    final newSession = WorkoutSession(
      id: 0, // Assigned by backend
      caloriesBurned: params.caloriesBurned,
      duration: params.duration,
      avgBpm: params.avgBpm,
      maxBpm: params.maxBpm,
      restingBpm: params.restingBpm,
      waterIntake: params.waterIntake,
      member: params.member,
      exercices: params.exercices ?? [],
    );
    return repository.createSession(newSession);
  }
}

class CreateSessionParams extends Equatable {
  final double caloriesBurned;
  final String duration;
  final int avgBpm;
  final int maxBpm;
  final int restingBpm;
  final double waterIntake;
  final int member;
  final List<int>? exercices;

  const CreateSessionParams({
    required this.caloriesBurned,
    required this.duration,
    required this.avgBpm,
    required this.maxBpm,
    required this.restingBpm,
    required this.waterIntake,
    required this.member,
    this.exercices,
  });

  @override
  List<Object?> get props => [caloriesBurned, duration, avgBpm, maxBpm, restingBpm, waterIntake, member, exercices];
}
