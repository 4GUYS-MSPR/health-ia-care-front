import '../../domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.imageUrl,
    super.createdAt,
    super.category,
    super.client,
    super.bodyParts,
    super.equipments,
    super.secondaryMuscles,
    super.targetMuscles,
    super.categoryName,
    super.bodyPartNames,
    super.equipmentNames,
    super.targetMuscleNames,
    super.secondaryMuscleNames,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: _readInt(json['id']) ?? 0,
      imageUrl: json['image_url'] as String,
      createdAt: json['create_at'] != null ? DateTime.tryParse(json['create_at'] as String) : null,
      category: _readInt(json['category']),
      client: _readInt(json['client']),
      bodyParts: _readIntList(json['body_parts']),
      equipments: _readIntList(json['equipments']),
      secondaryMuscles: _readIntList(json['secondary_muscles']),
      targetMuscles: _readIntList(json['target_muscles']),
      categoryName: _readString(json['category']),
      bodyPartNames: _readStringList(json['body_parts']),
      equipmentNames: _readStringList(json['equipments']),
      targetMuscleNames: _readStringList(json['target_muscles']),
      secondaryMuscleNames: _readStringList(json['secondary_muscles']),
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

  static String? _readString(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (raw is Map) {
      final dynamicValue = raw['value'] ?? raw['label'] ?? raw['name'];
      if (dynamicValue is String) {
        final trimmed = dynamicValue.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
    }
    return null;
  }

  static List<String> _readStringList(dynamic raw) {
    if (raw is! List) return const <String>[];
    return raw.map(_readString).whereType<String>().toList();
  }

  factory ExerciseModel.fromEntity(Exercise entity) {
    return ExerciseModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      category: entity.category,
      client: entity.client,
      bodyParts: entity.bodyParts,
      equipments: entity.equipments,
      secondaryMuscles: entity.secondaryMuscles,
      targetMuscles: entity.targetMuscles,
      categoryName: entity.categoryName,
      bodyPartNames: entity.bodyPartNames,
      equipmentNames: entity.equipmentNames,
      targetMuscleNames: entity.targetMuscleNames,
      secondaryMuscleNames: entity.secondaryMuscleNames,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': imageUrl,
      'category': category,
      'body_parts': bodyParts,
      'equipments': equipments,
      'secondary_muscles': secondaryMuscles,
      'target_muscles': targetMuscles,
    };
  }
}
