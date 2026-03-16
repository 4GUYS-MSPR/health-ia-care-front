import '../../domain/entities/workout_session.dart';

class WorkoutSessionModel extends WorkoutSession {
  const WorkoutSessionModel({
    required super.id,
    required super.caloriesBurned,
    required super.duration,
    required super.avgBpm,
    required super.maxBpm,
    required super.restingBpm,
    required super.waterIntake,
    super.exercices,
    required super.member,
    super.createdAt,
  });

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionModel(
      id: _readInt(json['id']) ?? 0,
      caloriesBurned: (json['calories_burned'] as num).toDouble(),
      duration: json['duration'] as String,
      avgBpm: json['avg_bpm'] as int,
      maxBpm: json['max_bpm'] as int,
      restingBpm: json['resting_bpm'] as int,
      waterIntake: (json['water_intake'] as num).toDouble(),
      exercices: _readIntList(json['exercices']),
      member: _readInt(json['member']) ?? 0,
      createdAt: json['create_at'] != null ? DateTime.tryParse(json['create_at'] as String) : null,
    );
  }

  static int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    if (raw is Map) return _readInt(raw['id']);
    return null;
  }

  static List<int> _readIntList(dynamic raw) {
    if (raw is! List) return const <int>[];
    return raw.map(_readInt).whereType<int>().toList();
  }

  factory WorkoutSessionModel.fromEntity(WorkoutSession entity) {
    return WorkoutSessionModel(
      id: entity.id,
      caloriesBurned: entity.caloriesBurned,
      duration: entity.duration,
      avgBpm: entity.avgBpm,
      maxBpm: entity.maxBpm,
      restingBpm: entity.restingBpm,
      waterIntake: entity.waterIntake,
      exercices: entity.exercices,
      member: entity.member,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'calories_burned': caloriesBurned,
      'duration': duration,
      'avg_bpm': avgBpm,
      'max_bpm': maxBpm,
      'resting_bpm': restingBpm,
      'water_intake': waterIntake,
      'exercices': exercices,
      'member': member,
    };
  }
}
