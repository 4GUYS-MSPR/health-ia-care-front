import 'package:equatable/equatable.dart';

class EnumItem extends Equatable {
  final int id;
  final String value;
  final DateTime? createdAt;

  const EnumItem({
    required this.id,
    required this.value,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, value, createdAt];
}
