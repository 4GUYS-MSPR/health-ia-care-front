import 'package:equatable/equatable.dart';

class Objective extends Equatable {
  final int? id;
  final String description;
  final DateTime createdAt;

  const Objective({
    this.id,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    description,
    createdAt,
  ];

  Objective copyWith({
    int? id,
    String? description,
    DateTime? createdAt,
  }) {
    return Objective(
      id: id ?? this.id,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
