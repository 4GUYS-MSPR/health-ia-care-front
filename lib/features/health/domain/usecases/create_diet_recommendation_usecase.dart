import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diet_recommendation.dart';
import '../repositories/diet_recommendation_repository.dart';

class CreateDietRecommendationUsecase with LoggerMixin implements Usecase<DietRecommendation, CreateDietRecommendationParams> {
  final DietRecommendationRepository repository;

  CreateDietRecommendationUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.CreateDietRecommendationUsecase';

  @override
  TaskEither<Failure, DietRecommendation> call(CreateDietRecommendationParams params) {
    logger.finest('CreateDietRecommendationUsecase called');
    final newRecommendation = DietRecommendation(
      id: 0, // Assigned by backend
      adherenceToDietPlan: params.adherenceToDietPlan,
      bloodPressure: params.bloodPressure,
      cholesterol: params.cholesterol,
      dailyCaloricIntake: params.dailyCaloricIntake,
      dietaryNutrientImbalanceScore: params.dietaryNutrientImbalanceScore,
      glucose: params.glucose,
      weeklyExerciseHours: params.weeklyExerciseHours,
      activity: params.activity,
      allergies: params.allergies ?? [],
      dietaryRestrictions: params.dietaryRestrictions ?? [],
      diseaseType: params.diseaseType,
      member: params.member,
      preferredCuisine: params.preferredCuisine,
      severity: params.severity,
    );
    return repository.createDietRecommendation(newRecommendation);
  }
}

class CreateDietRecommendationParams extends Equatable {
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

  const CreateDietRecommendationParams({
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
    severity,
  ];
}
