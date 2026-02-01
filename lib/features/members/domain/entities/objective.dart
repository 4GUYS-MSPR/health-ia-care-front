import 'package:equatable/equatable.dart';

class Objective extends Equatable {
  final String description;
  final DateTime createdAt;

  const Objective({
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    description,
    createdAt,
  ];

  Objective copyWith({
    String? description,
    DateTime? createdAt,
  }) {
    return Objective(
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
