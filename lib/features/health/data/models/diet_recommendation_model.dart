import '../../domain/entities/diet_recommendation.dart';

class DietRecommendationModel extends DietRecommendation {
  const DietRecommendationModel({
    required super.id,
    required super.adherenceToDietPlan,
    required super.bloodPressure,
    required super.cholesterol,
    required super.dailyCaloricIntake,
    required super.dietaryNutrientImbalanceScore,
    required super.glucose,
    required super.weeklyExerciseHours,
    super.activity,
    super.allergies,
    super.dietaryRestrictions,
    super.diseaseType,
    super.member,
    super.preferredCuisine,
    super.recommendation,
    super.severity,
    super.createdAt,
  });

  factory DietRecommendationModel.fromJson(Map<String, dynamic> json) {
    return DietRecommendationModel(
      id: _readInt(json['id']) ?? 0,
      adherenceToDietPlan: (json['adherence_to_diet_plan'] as num).toDouble(),
      bloodPressure: json['blood_pressure'] as int,
      cholesterol: (json['cholesterol'] as num).toDouble(),
      dailyCaloricIntake: json['daily_caloric_intake'] as int,
      dietaryNutrientImbalanceScore: (json['dietary_nutrient_imbalance_score'] as num).toDouble(),
      glucose: (json['glucose'] as num).toDouble(),
      weeklyExerciseHours: (json['weekly_exercise_hours'] as num).toDouble(),
      activity: _readInt(json['activity']),
      allergies: _readIntList(json['allergies']),
      dietaryRestrictions: _readIntList(json['dietary_restrictions']),
      diseaseType: _readInt(json['disease_type']),
      member: _readInt(json['member']),
      preferredCuisine: _readInt(json['preferred_cuisine']),
      recommendation: _readInt(json['recommendation']),
      severity: _readInt(json['severity']),
      createdAt: json['create_at'] != null ? DateTime.tryParse(json['create_at'] as String) : null,
    );
  }

  static int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    if (raw is Map) return _readInt(raw['id']);
    return null;
  }

  static List<int> _readIntList(dynamic raw) {
    if (raw is! List) return const <int>[];
    return raw.map(_readInt).whereType<int>().toList();
  }

  factory DietRecommendationModel.fromEntity(DietRecommendation entity) {
    return DietRecommendationModel(
      id: entity.id,
      adherenceToDietPlan: entity.adherenceToDietPlan,
      bloodPressure: entity.bloodPressure,
      cholesterol: entity.cholesterol,
      dailyCaloricIntake: entity.dailyCaloricIntake,
      dietaryNutrientImbalanceScore: entity.dietaryNutrientImbalanceScore,
      glucose: entity.glucose,
      weeklyExerciseHours: entity.weeklyExerciseHours,
      activity: entity.activity,
      allergies: entity.allergies,
      dietaryRestrictions: entity.dietaryRestrictions,
      diseaseType: entity.diseaseType,
      member: entity.member,
      preferredCuisine: entity.preferredCuisine,
      recommendation: entity.recommendation,
      severity: entity.severity,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adherence_to_diet_plan': adherenceToDietPlan,
      'blood_pressure': bloodPressure,
      'cholesterol': cholesterol,
      'daily_caloric_intake': dailyCaloricIntake,
      'dietary_nutrient_imbalance_score': dietaryNutrientImbalanceScore,
      'glucose': glucose,
      'weekly_exercise_hours': weeklyExerciseHours,
      'activity': activity,
      'allergies': allergies,
      'dietary_restrictions': dietaryRestrictions,
      'disease_type': diseaseType,
      'member': member,
      'preferred_cuisine': preferredCuisine,
      'recommendation': recommendation,
      'severity': severity,
    };
  }
}
