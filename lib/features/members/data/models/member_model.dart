import 'dart:convert';

import '../../domain/entities/gender.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/subscription.dart';
import 'objective_model.dart';

/// Data model for [Member] with (de)serialization helpers.
class MemberModel extends Member {
  const MemberModel({
    required super.id,
    super.age,
    required super.bmi,
    required super.fatPercentage,
    required super.height,
    required super.weight,
    required super.workoutFrequency,
    super.createdAt,
    super.clientId,
    required super.gender,
    required super.level,
    required super.subscription,
    required super.objectives,
  });

  /// Serializes the model to a `Map` for API requests (excludes id).
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'age': age,
      'bmi': bmi,
      'fat_percentage': fatPercentage,
      'height': height,
      'weight': weight,
      'workout_frequency': workoutFrequency,
      'gender': gender.index,
      'level': level.index,
      'subscription': subscription.index,
      'objectives': objectives
          .map((objective) => ObjectiveModel.fromEntity(objective).toMap())
          .toList(),
    };
  }

  /// Serializes the model to a `Map` including all fields.
  Map<String, dynamic> toFullMap() {
    return <String, dynamic>{
      'id': id,
      'age': age,
      'bmi': bmi,
      'fat_percentage': fatPercentage,
      'height': height,
      'weight': weight,
      'workout_frequency': workoutFrequency,
      'create_at': createdAt?.toIso8601String(),
      'client': clientId,
      'gender': gender.index,
      'level': level.index,
      'subscription': subscription.index,
      'objectives': objectives
          .map((objective) => ObjectiveModel.fromEntity(objective).toMap())
          .toList(),
    };
  }

  /// Deserializes a `Map` from the API into a [MemberModel].
  factory MemberModel.fromMap(Map<String, dynamic> map) {
    Gender parseGender(int? genderInt) {
      return switch (genderInt) {
        0 => .male,
        1 => .female,
        _ => .unknow,
      };
    }

    return MemberModel(
      id: map['id'] as int,
      age: map['age'] as int?,
      bmi: map['bmi'] as double,
      fatPercentage: map['fat_percentage'] as double,
      height: map['height'] as double,
      weight: map['weight'] as double,
      workoutFrequency: map['workout_frequency'] as int,
      createdAt: map['create_at'] != null ? DateTime.tryParse(map['create_at'] as String) : null,
      clientId: map['client'] as int?,
      gender: parseGender(map['gender'] as int),
      level: Level.values[map['level'] as int? ?? 0],
      subscription: Subscription.values[map['subscription'] as int? ?? 0],
      objectives: (map['objectives'] as List<dynamic>? ?? [])
          .map((objective) => ObjectiveModel.fromMap(objective as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Encodes the model as a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates a [MemberModel] from a JSON string.
  factory MemberModel.fromJson(String source) => MemberModel.fromMap(
    json.decode(source) as Map<String, dynamic>,
  );

  /// Convenience factory to convert a domain [Member] into a data model.
  factory MemberModel.fromEntity(Member member) {
    return MemberModel(
      id: member.id,
      age: member.age,
      bmi: member.bmi,
      fatPercentage: member.fatPercentage,
      height: member.height,
      weight: member.weight,
      workoutFrequency: member.workoutFrequency,
      createdAt: member.createdAt,
      clientId: member.clientId,
      gender: member.gender,
      level: member.level,
      subscription: member.subscription,
      objectives: member.objectives,
    );
  }
}
