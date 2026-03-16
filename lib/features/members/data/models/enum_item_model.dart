import 'package:equatable/equatable.dart';

/// Represents an enum option returned by the /api/enum/{model}/ endpoint.
///
/// [id] is the real database PK, [value] is the human-readable label.
class EnumItemModel extends Equatable {
  final int id;
  final String value;

  const EnumItemModel({required this.id, required this.value});

  factory EnumItemModel.fromJson(Map<String, dynamic> json) {
    return EnumItemModel(
      id: _readInt(json['id']),
      value: _readString(json['value']),
    );
  }

  static int _readInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  static String _readString(dynamic raw) {
    if (raw is String) return raw.trim();
    if (raw is Map) {
      final nested = raw['value'] ?? raw['label'] ?? raw['name'];
      if (nested is String) return nested.trim();
    }
    return raw?.toString() ?? '';
  }

  @override
  List<Object?> get props => [id, value];
}
