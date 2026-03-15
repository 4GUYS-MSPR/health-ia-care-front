import 'dart:convert';

import '../../domain/entities/objective.dart';

class ObjectiveModel extends Objective {
  const ObjectiveModel({
    required super.description,
    required super.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ObjectiveModel.fromMap(Map<String, dynamic> map) {
    String parseDescription(Map<String, dynamic> value) {
      final raw = value['description'] ?? value['name'] ?? value['label'] ?? value['id'];
      if (raw == null) return '';
      return raw.toString();
    }

    DateTime parseCreatedAt(Map<String, dynamic> value) {
      final raw = value['created_at'] ?? value['create_at'] ?? value['createdAt'];
      if (raw is String) {
        return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return ObjectiveModel(
      description: parseDescription(map),
      createdAt: parseCreatedAt(map),
    );
  }

  String toJson() => json.encode(toMap());

  factory ObjectiveModel.fromJson(String source) => ObjectiveModel.fromMap(
    json.decode(source) as Map<String, dynamic>,
  );

  factory ObjectiveModel.fromEntity(Objective objective) {
    return ObjectiveModel(
      description: objective.description,
      createdAt: objective.createdAt,
    );
  }
}
