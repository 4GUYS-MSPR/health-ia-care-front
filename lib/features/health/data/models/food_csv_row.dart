import 'package:equatable/equatable.dart';

/// Represents a single row parsed from a CSV file for food import.
///
/// Each field stores the raw parsed value plus an optional validation error.
class FoodCsvRow extends Equatable {
  final int index;
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
  final String category;
  final String mealType;
  final Map<String, String> errors;

  const FoodCsvRow({
    required this.index,
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
    required this.category,
    required this.mealType,
    this.errors = const {},
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isValid => !hasErrors;

  FoodCsvRow copyWith({
    int? index,
    String? label,
    int? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugars,
    int? sodium,
    int? cholesterol,
    int? waterIntake,
    String? category,
    String? mealType,
    Map<String, String>? errors,
  }) {
    return FoodCsvRow(
      index: index ?? this.index,
      label: label ?? this.label,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugars: sugars ?? this.sugars,
      sodium: sodium ?? this.sodium,
      cholesterol: cholesterol ?? this.cholesterol,
      waterIntake: waterIntake ?? this.waterIntake,
      category: category ?? this.category,
      mealType: mealType ?? this.mealType,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
    index,
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
    category,
    mealType,
    errors,
  ];
}
