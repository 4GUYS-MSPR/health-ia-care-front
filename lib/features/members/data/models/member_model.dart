import 'dart:convert';

import '../../domain/entities/gender.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/objective.dart';
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

  /// Converts [objectives] to a list of integer IDs for API requests.
  /// Objectives whose description is a numeric string are sent as their integer
  /// value; text-only descriptions are sent as-is and the API will handle them.
  static List<dynamic> objectivesToApi(List<Objective> objectives) {
    return objectives.map((o) {
      final id = int.tryParse(o.description);
      return id ?? o.description;
    }).toList();
  }

  /// Deserializes a `Map` from the API into a [MemberModel].
  factory MemberModel.fromMap(Map<String, dynamic> map) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      if (value is Map) {
        return parseInt(value['id'] ?? value['value'] ?? value['pk']);
      }
      return null;
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      if (value is Map) {
        return parseDouble(value['value']);
      }
      return 0;
    }

    DateTime? parseDateTime(dynamic value) {
      if (value is String) return DateTime.tryParse(value);
      if (value is Map) {
        return parseDateTime(value['value'] ?? value['date'] ?? value['created_at']);
      }
      return null;
    }

    Gender parseGender(int? genderInt) {
      return switch (genderInt) {
        0 => .male,
        1 => .female,
        _ => .unknow,
      };
    }

    int parseEnumIndex(dynamic value) {
      return parseInt(value) ?? 0;
    }

    return MemberModel(
      id: parseInt(map['id']) ?? 0,
      age: parseInt(map['age']),
      bmi: parseDouble(map['bmi']),
      fatPercentage: parseDouble(map['fat_percentage']),
      height: parseDouble(map['height']),
      weight: parseDouble(map['weight']),
      workoutFrequency: parseInt(map['workout_frequency']) ?? 0,
      createdAt: parseDateTime(map['create_at']),
      clientId: parseInt(map['client']),
      gender: parseGender(parseInt(map['gender'])),
      level: Level.values[parseEnumIndex(map['level']).clamp(0, Level.values.length - 1)],
      subscription: Subscription.values[
        parseEnumIndex(map['subscription']).clamp(0, Subscription.values.length - 1)
      ],
      objectives: (map['objectives'] as List<dynamic>? ?? [])
          .map((objective) {
            if (objective is int) {
              return ObjectiveModel(
                description: objective.toString(),
                createdAt: DateTime.fromMillisecondsSinceEpoch(0),
              );
            }
            if (objective is Map) {
              return ObjectiveModel.fromMap(Map<String, dynamic>.from(objective));
            }
            return ObjectiveModel(
              description: objective.toString(),
              createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            );
          })
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
