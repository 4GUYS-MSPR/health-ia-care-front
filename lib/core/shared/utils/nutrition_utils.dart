import '../../../../features/health/domain/entities/nutrition_food.dart';

// Computes the average of a nutritional property across all foods.
double average(List<NutritionFood> foods, double Function(NutritionFood food) property) {
  if (foods.isEmpty) return 0;
  return foods.fold(0.0, (sum, food) => sum + property(food)) / foods.length;
}

// Groups foods by a key (category or meal type) and counts them.
Map<String, int> countByGroup(
  List<NutritionFood> foods,
  String Function(NutritionFood food) extractGroup,
) {
  final counts = <String, int>{};
  for (final food in foods) {
    final groupName = extractGroup(food);
    if (groupName.isEmpty) continue;
    counts[groupName] = (counts[groupName] ?? 0) + 1;
  }
  return counts;
}
