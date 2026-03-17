import 'package:health_ia_care_app/features/health/domain/entities/exercise.dart';

/// Utility functions for exercise data processing and aggregation
class ExerciseUtils {
  // Averages for KPI cards
  static double averageTargetMuscles(List<Exercise> exercises) {
    if (exercises.isEmpty) return 0;
    final total = exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.targetMuscles.length,
    );
    return total / exercises.length;
  }

  static double averageBodyParts(List<Exercise> exercises) {
    if (exercises.isEmpty) return 0;
    final total = exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.bodyParts.length,
    );
    return total / exercises.length;
  }

  static double averageEquipments(List<Exercise> exercises) {
    if (exercises.isEmpty) return 0;
    final total = exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.equipments.length,
    );
    return total / exercises.length;
  }

  // Counts for charts (using display names from API)
  static Map<String, int> countByCategory(List<Exercise> exercises) {
    final counts = <String, int>{};
    for (final exercise in exercises) {
      if (exercise.categoryName != null && exercise.categoryName!.isNotEmpty) {
        counts[exercise.categoryName!] = (counts[exercise.categoryName!] ?? 0) + 1;
      }
    }
    return counts;
  }

  static Map<String, int> countTargetMuscles(List<Exercise> exercises) {
    final counts = <String, int>{};
    for (final exercise in exercises) {
      for (final muscle in exercise.targetMuscleNames) {
        counts[muscle] = (counts[muscle] ?? 0) + 1;
      }
    }
    return counts;
  }

  static Map<String, int> countEquipments(List<Exercise> exercises) {
    final counts = <String, int>{};
    for (final exercise in exercises) {
      for (final equipment in exercise.equipmentNames) {
        counts[equipment] = (counts[equipment] ?? 0) + 1;
      }
    }
    return counts;
  }

  static Map<String, int> countBodyParts(List<Exercise> exercises) {
    final counts = <String, int>{};
    for (final exercise in exercises) {
      for (final part in exercise.bodyPartNames) {
        counts[part] = (counts[part] ?? 0) + 1;
      }
    }
    return counts;
  }
}

