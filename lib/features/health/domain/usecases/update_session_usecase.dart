import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/workout_session.dart';
import '../repositories/session_repository.dart';

class UpdateSessionUsecase with LoggerMixin implements Usecase<WorkoutSession, UpdateSessionParams> {
  final SessionRepository repository;

  UpdateSessionUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.UpdateSessionUsecase';

  @override
  TaskEither<Failure, WorkoutSession> call(UpdateSessionParams params) {
    logger.finest('UpdateSessionUsecase called for id=${params.id}');
    final updatedSession = WorkoutSession(
      id: params.id,
      caloriesBurned: params.caloriesBurned ?? 0.0,
      duration: params.duration ?? '',
      avgBpm: params.avgBpm ?? 0,
      maxBpm: params.maxBpm ?? 0,
      restingBpm: params.restingBpm ?? 0,
      waterIntake: params.waterIntake ?? 0.0,
      member: params.member ?? 0,
      exercices: params.exercices ?? [],
    );
    return repository.updateSession(params.id, updatedSession);
  }
}

class UpdateSessionParams extends Equatable {
  final int id;
  final double? caloriesBurned;
  final String? duration;
  final int? avgBpm;
  final int? maxBpm;
  final int? restingBpm;
  final double? waterIntake;
  final int? member;
  final List<int>? exercices;

  const UpdateSessionParams({
    required this.id,
    this.caloriesBurned,
    this.duration,
    this.avgBpm,
    this.maxBpm,
    this.restingBpm,
    this.waterIntake,
    this.member,
    this.exercices,
  });

  @override
  List<Object?> get props => [id, caloriesBurned, duration, avgBpm, maxBpm, restingBpm, waterIntake, member, exercices];
}
