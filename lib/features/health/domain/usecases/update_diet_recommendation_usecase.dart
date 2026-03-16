import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diet_recommendation.dart';
import '../repositories/diet_recommendation_repository.dart';

class UpdateDietRecommendationUsecase with LoggerMixin implements Usecase<DietRecommendation, UpdateDietRecommendationParams> {
  final DietRecommendationRepository repository;

  UpdateDietRecommendationUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.UpdateDietRecommendationUsecase';

  @override
  TaskEither<Failure, DietRecommendation> call(UpdateDietRecommendationParams params) {
    logger.finest('UpdateDietRecommendationUsecase called for id=${params.id}');
    final updatedRecommendation = DietRecommendation(
      id: params.id,
      adherenceToDietPlan: params.adherenceToDietPlan ?? 0.0,
      bloodPressure: params.bloodPressure ?? 0,
      cholesterol: params.cholesterol ?? 0.0,
      dailyCaloricIntake: params.dailyCaloricIntake ?? 0,
      dietaryNutrientImbalanceScore: params.dietaryNutrientImbalanceScore ?? 0.0,
      glucose: params.glucose ?? 0.0,
      weeklyExerciseHours: params.weeklyExerciseHours ?? 0.0,
      activity: params.activity,
      allergies: params.allergies ?? [],
      dietaryRestrictions: params.dietaryRestrictions ?? [],
      diseaseType: params.diseaseType,
      member: params.member,
      preferredCuisine: params.preferredCuisine,
      severity: params.severity,
    );
    return repository.updateDietRecommendation(params.id, updatedRecommendation);
  }
}

class UpdateDietRecommendationParams extends Equatable {
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

  const UpdateDietRecommendationParams({
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
    severity,
  ];
}
