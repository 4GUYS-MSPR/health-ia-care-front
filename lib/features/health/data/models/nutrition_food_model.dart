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
    required super.category,
    required super.mealType,
  });

  factory NutritionFoodModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final mealType = json['meal_type'];

    String parseValue(dynamic field, {String fallback = 'Unknown'}) {
      if (field == null) return fallback;
      if (field is String) return field;
      if (field is Map<String, dynamic> && field.containsKey('value')) {
        final v = field['value'];
        if (v is String && v.isNotEmpty) return v;
      }
      return fallback;
    }

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
      category: parseValue(category, fallback: 'Uncategorized'),
      mealType: parseValue(mealType, fallback: 'Unknown'),
    );
  }

  Map<String, dynamic> toJson() {
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
      'category': category,
      'meal_type': mealType,
    };
  }
}
