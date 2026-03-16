import '../../domain/entities/enum_item.dart';

class EnumItemModel extends EnumItem {
  const EnumItemModel({
    required super.id,
    required super.value,
    super.createdAt,
  });

  factory EnumItemModel.fromJson(Map<String, dynamic> json) {
    return EnumItemModel(
      id: _readInt(json['id']),
      value: _readValue(json['value']),
      createdAt: json['create_at'] != null ? DateTime.tryParse(json['create_at'] as String) : null,
    );
  }

  static int _readInt(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    if (raw is Map) return _readInt(raw['id']);
    return 0;
  }

  static String _readValue(dynamic raw) {
    if (raw is String) return raw.trim();
    if (raw is Map) {
      final dynamic nested = raw['value'] ?? raw['label'] ?? raw['name'];
      if (nested is String) return nested.trim();
    }
    return raw?.toString() ?? '';
  }
}
