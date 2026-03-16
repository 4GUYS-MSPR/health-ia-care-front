import 'package:equatable/equatable.dart';

class WorkoutSession extends Equatable {
  final int id;
  final double caloriesBurned;
  final String duration;
  final int avgBpm;
  final int maxBpm;
  final int restingBpm;
  final double waterIntake;
  final List<int> exercices;
  final int member;
  final DateTime? createdAt;

  const WorkoutSession({
    required this.id,
    required this.caloriesBurned,
    required this.duration,
    required this.avgBpm,
    required this.maxBpm,
    required this.restingBpm,
    required this.waterIntake,
    this.exercices = const [],
    required this.member,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    caloriesBurned,
    duration,
    avgBpm,
    maxBpm,
    restingBpm,
    waterIntake,
    exercices,
    member,
    createdAt,
  ];
}
