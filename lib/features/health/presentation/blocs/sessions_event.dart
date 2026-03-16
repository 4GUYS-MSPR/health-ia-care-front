part of 'sessions_bloc.dart';

sealed class SessionsEvent extends Equatable {
  const SessionsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSessionsRequested extends SessionsEvent {
  const LoadSessionsRequested();
}

final class RefreshSessionsRequested extends SessionsEvent {
  const RefreshSessionsRequested();
}

final class CreateSessionRequested extends SessionsEvent {
  final double caloriesBurned;
  final String duration;
  final int avgBpm;
  final int maxBpm;
  final int restingBpm;
  final double waterIntake;
  final int member;
  final List<int>? exercices;

  const CreateSessionRequested({
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

final class UpdateSessionRequested extends SessionsEvent {
  final int id;
  final double? caloriesBurned;
  final String? duration;
  final int? avgBpm;
  final int? maxBpm;
  final int? restingBpm;
  final double? waterIntake;
  final int? member;
  final List<int>? exercices;

  const UpdateSessionRequested({
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

final class DeleteSessionRequested extends SessionsEvent {
  final int id;
  const DeleteSessionRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

final class GetSessionsPageRequested extends SessionsEvent {
  final int offset;
  final int limit;
  const GetSessionsPageRequested({required this.offset, required this.limit});

  @override
  List<Object?> get props => [offset, limit];
}

final class SessionsNextPageRequested extends SessionsEvent {
  const SessionsNextPageRequested();
}

final class SessionsPreviousPageRequested extends SessionsEvent {
  const SessionsPreviousPageRequested();
}
