part of 'diet_recommendations_bloc.dart';

sealed class DietRecommendationsEvent extends Equatable {
  const DietRecommendationsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadDietRecommendationsRequested extends DietRecommendationsEvent {
  const LoadDietRecommendationsRequested();
}

final class RefreshDietRecommendationsRequested extends DietRecommendationsEvent {
  const RefreshDietRecommendationsRequested();
}

final class CreateDietRecommendationRequested extends DietRecommendationsEvent {
  final double adherenceToDietPlan;
  final int bloodPressure;
  final double cholesterol;
  final int dailyCaloricIntake;
  final double dietaryNutrientImbalanceScore;
  final double glucose;
  final double weeklyExerciseHours;
  final int? activity;
  final List<int>? allergies;
  final List<int>? dietaryRestrictions;
  final int? diseaseType;
  final int? member;
  final int? preferredCuisine;
  final int? severity;

  const CreateDietRecommendationRequested({
    required this.adherenceToDietPlan,
    required this.bloodPressure,
    required this.cholesterol,
    required this.dailyCaloricIntake,
    required this.dietaryNutrientImbalanceScore,
    required this.glucose,
    required this.weeklyExerciseHours,
    this.activity,
    this.allergies,
    this.dietaryRestrictions,
    this.diseaseType,
    this.member,
    this.preferredCuisine,
    this.severity,
  });

  @override
  List<Object?> get props => [
    adherenceToDietPlan, bloodPressure, cholesterol, dailyCaloricIntake,
    dietaryNutrientImbalanceScore, glucose, weeklyExerciseHours,
    activity, allergies, dietaryRestrictions, diseaseType, member, preferredCuisine, severity,
  ];
}

final class UpdateDietRecommendationRequested extends DietRecommendationsEvent {
  final int id;
  final double? adherenceToDietPlan;
  final int? bloodPressure;
  final double? cholesterol;
  final int? dailyCaloricIntake;
  final double? dietaryNutrientImbalanceScore;
  final double? glucose;
  final double? weeklyExerciseHours;
  final int? activity;
  final List<int>? allergies;
  final List<int>? dietaryRestrictions;
  final int? diseaseType;
  final int? member;
  final int? preferredCuisine;
  final int? severity;

  const UpdateDietRecommendationRequested({
    required this.id,
    this.adherenceToDietPlan,
    this.bloodPressure,
    this.cholesterol,
    this.dailyCaloricIntake,
    this.dietaryNutrientImbalanceScore,
    this.glucose,
    this.weeklyExerciseHours,
    this.activity,
    this.allergies,
    this.dietaryRestrictions,
    this.diseaseType,
    this.member,
    this.preferredCuisine,
    this.severity,
  });

  @override
  List<Object?> get props => [
    id, adherenceToDietPlan, bloodPressure, cholesterol, dailyCaloricIntake,
    dietaryNutrientImbalanceScore, glucose, weeklyExerciseHours,
    activity, allergies, dietaryRestrictions, diseaseType, member, preferredCuisine, severity,
  ];
}

final class DeleteDietRecommendationRequested extends DietRecommendationsEvent {
  final int id;
  const DeleteDietRecommendationRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

final class GetDietRecommendationsPageRequested extends DietRecommendationsEvent {
  final int offset;
  final int limit;
  const GetDietRecommendationsPageRequested({required this.offset, required this.limit});

  @override
  List<Object?> get props => [offset, limit];
}

final class DietRecommendationsNextPageRequested extends DietRecommendationsEvent {
  const DietRecommendationsNextPageRequested();
}

final class DietRecommendationsPreviousPageRequested extends DietRecommendationsEvent {
  const DietRecommendationsPreviousPageRequested();
}
