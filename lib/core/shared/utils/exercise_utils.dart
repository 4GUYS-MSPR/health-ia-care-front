import 'package:health_ia_care_app/features/health/domain/entities/exercise.dart';

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

  static Map<String, int> countByCategory(List<Exercise> exercises) {
    final counts = <String, int>{};
    for (final exercise in exercises) {
      final name = exercise.categoryName?.trim();
      if (name != null && name.isNotEmpty) {
        counts[name] = (counts[name] ?? 0) + 1;
      }
    }
    return counts;
  }

  static Map<String, int> countTargetMuscles(List<Exercise> exercises) {
    final counts = <String, int>{};
    for (final exercise in exercises) {
      for (final muscle in exercise.targetMuscleNames) {
        final muscleName = muscle.trim();
        if (muscleName.isEmpty) continue;
        counts[muscleName] = (counts[muscleName] ?? 0) + 1;
      }
    }
    return counts;
  }

  static Map<String, int> countEquipments(List<Exercise> exercises) {
    final counts = <String, int>{};
    for (final exercise in exercises) {
      for (final equipment in exercise.equipmentNames) {
        final equipmentName = equipment.trim();
        if (equipmentName.isEmpty) continue;
        counts[equipmentName] = (counts[equipmentName] ?? 0) + 1;
      }
    }
    return counts;
  }

  static Map<String, int> countBodyParts(List<Exercise> exercises) {
    final counts = <String, int>{};
    for (final exercise in exercises) {
      for (final part in exercise.bodyPartNames) {
        final partName = part.trim();
        if (partName.isEmpty) continue;
        counts[partName] = (counts[partName] ?? 0) + 1;
      }
    }
    return counts;
  }
}

