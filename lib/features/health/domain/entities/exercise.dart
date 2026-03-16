import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final int id;
  final String imageUrl;
  final DateTime? createdAt;
  final int? category;
  final int? client;
  final List<int> bodyParts;
  final List<int> equipments;
  final List<int> secondaryMuscles;
  final List<int> targetMuscles;

  const Exercise({
    required this.id,
    required this.imageUrl,
    this.createdAt,
    this.category,
    this.client,
    this.bodyParts = const [],
    this.equipments = const [],
    this.secondaryMuscles = const [],
    this.targetMuscles = const [],
  });

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    createdAt,
    category,
    client,
    bodyParts,
    equipments,
    secondaryMuscles,
    targetMuscles,
  ];
}
