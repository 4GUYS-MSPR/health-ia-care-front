import 'package:equatable/equatable.dart';

class DietRecommendation extends Equatable {
  final int id;
  final double adherenceToDietPlan;
  final int bloodPressure;
  final double cholesterol;
  final int dailyCaloricIntake;
  final double dietaryNutrientImbalanceScore;
  final double glucose;
  final double weeklyExerciseHours;
  final int? activity;
  final List<int> allergies;
  final List<int> dietaryRestrictions;
  final int? diseaseType;
  final int? member;
  final int? preferredCuisine;
  final int? recommendation;
  final int? severity;
  final DateTime? createdAt;

  const DietRecommendation({
    required this.id,
    required this.adherenceToDietPlan,
    required this.bloodPressure,
    required this.cholesterol,
    required this.dailyCaloricIntake,
    required this.dietaryNutrientImbalanceScore,
    required this.glucose,
    required this.weeklyExerciseHours,
    this.activity,
    this.allergies = const [],
    this.dietaryRestrictions = const [],
    this.diseaseType,
    this.member,
    this.preferredCuisine,
    this.recommendation,
    this.severity,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    adherenceToDietPlan,
    bloodPressure,
    cholesterol,
    dailyCaloricIntake,
    dietaryNutrientImbalanceScore,
    glucose,
    weeklyExerciseHours,
    activity,
    allergies,
    dietaryRestrictions,
    diseaseType,
    member,
    preferredCuisine,
    recommendation,
    severity,
    createdAt,
  ];
}
