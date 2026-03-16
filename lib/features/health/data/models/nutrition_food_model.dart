import '../../domain/entities/nutrition_food.dart';

class NutritionFoodModel extends NutritionFood {
  const NutritionFoodModel({
    required super.id,
    required super.label,
    required super.calories,
    required super.protein,
    required super.carbohydrates,
    required super.fat,
    required super.fiber,
    required super.sugars,
    required super.sodium,
    required super.cholesterol,
    required super.waterIntake,
    super.categoryId,
    super.mealTypeId,
    required super.category,
    required super.mealType,
  });

  factory NutritionFoodModel.fromJson(
    Map<String, dynamic> json, {
    Map<int, String>? categoryLabelsById,
    Map<int, String>? mealTypeLabelsById,
  }) {
    int? parseEnumId(dynamic field) {
      if (field is int) return field;
      if (field is num) return field.toInt();
      if (field is String) return int.tryParse(field);
      if (field is Map<String, dynamic>) {
        final dynamic rawId = field['id'] ?? field['pk'] ?? field['value'];
        if (rawId is int) return rawId;
        if (rawId is num) return rawId.toInt();
        if (rawId is String) return int.tryParse(rawId);
      }
      return null;
    }

    String parseEnumLabel(
      dynamic field, {
      required int? id,
      required Map<int, String>? labelsById,
      required String fallback,
    }) {
      if (field is String && field.trim().isNotEmpty) return field.trim();
      if (field is Map<String, dynamic>) {
        final raw = field['value'] ?? field['label'] ?? field['name'];
        if (raw is String && raw.trim().isNotEmpty) return raw.trim();
      }
      if (id != null && labelsById != null && labelsById.containsKey(id)) {
        return labelsById[id]!;
      }
      return fallback;
    }

    final categoryField = json['category'];
    final mealTypeField = json['meal_type'];
    final categoryId = parseEnumId(categoryField);
    final mealTypeId = parseEnumId(mealTypeField);

    return NutritionFoodModel(
      id: json['id'] as int,
      label: json['label'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      sugars: (json['sugars'] as num).toDouble(),
      sodium: json['sodium'] as int,
      cholesterol: json['cholesterol'] as int,
      waterIntake: json['water_intake'] as int,
      categoryId: categoryId,
      mealTypeId: mealTypeId,
      category: parseEnumLabel(
        categoryField,
        id: categoryId,
        labelsById: categoryLabelsById,
        fallback: categoryId?.toString() ?? 'Uncategorized',
      ),
      mealType: parseEnumLabel(
        mealTypeField,
        id: mealTypeId,
        labelsById: mealTypeLabelsById,
        fallback: mealTypeId?.toString() ?? 'Unknown',
      ),
    );
  }

  factory NutritionFoodModel.fromEntity(NutritionFood entity) {
    return NutritionFoodModel(
      id: entity.id,
      label: entity.label,
      calories: entity.calories,
      protein: entity.protein,
      carbohydrates: entity.carbohydrates,
      fat: entity.fat,
      fiber: entity.fiber,
      sugars: entity.sugars,
      sodium: entity.sodium,
      cholesterol: entity.cholesterol,
      waterIntake: entity.waterIntake,
      categoryId: entity.categoryId,
      mealTypeId: entity.mealTypeId,
      category: entity.category,
      mealType: entity.mealType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'fiber': fiber,
      'sugars': sugars,
      'sodium': sodium,
      'cholesterol': cholesterol,
      'water_intake': waterIntake,
      'category': categoryId,
      'meal_type': mealTypeId,
    };
  }
}
