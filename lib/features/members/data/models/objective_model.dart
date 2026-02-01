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
    return ObjectiveModel(
      description: map['description'] as String,
      createdAt: DateTime.parse(map['create_at'] as String),
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
