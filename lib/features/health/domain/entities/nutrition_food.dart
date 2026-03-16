import 'package:equatable/equatable.dart';

class NutritionFood extends Equatable {
  final int id;
  final String label;
  final int calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugars;
  final int sodium;
  final int cholesterol;
  final int waterIntake;
  final int? categoryId;
  final int? mealTypeId;
  final String category;
  final String mealType;

  const NutritionFood({
    required this.id,
    required this.label,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.sugars,
    required this.sodium,
    required this.cholesterol,
    required this.waterIntake,
    this.categoryId,
    this.mealTypeId,
    required this.category,
    required this.mealType,
  });

  @override
  List<Object?> get props => [
    id,
    label,
    calories,
    protein,
    carbohydrates,
    fat,
    fiber,
    sugars,
    sodium,
    cholesterol,
    waterIntake,
    categoryId,
    mealTypeId,
    category,
    mealType,
  ];
}
