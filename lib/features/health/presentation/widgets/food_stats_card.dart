import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../domain/entities/nutrition_food.dart';

/// A card widget displaying aggregated food nutrition statistics.
class FoodStatsCard extends StatelessWidget {
  const FoodStatsCard({
    super.key,
    required this.foods,
  });

  final List<NutritionFood> foods;

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.foodStatsTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              context,
              Icons.restaurant_menu,
              'Total Foods',
              '${foods.length}',
            ),
            const SizedBox(height: 12),
            _buildDistributionSection(
              context,
              'Category Distribution',
              [
                _DistributionItem(
                  label: 'Fruit',
                  count: stats.fruitCount,
                  color: Colors.orange,
                ),
                _DistributionItem(
                  label: 'Vegetable',
                  count: stats.vegetableCount,
                  color: Colors.green,
                ),
                _DistributionItem(
                  label: 'Protein',
                  count: stats.proteinCount,
                  color: Colors.red,
                ),
                _DistributionItem(
                  label: 'Dairy',
                  count: stats.dairyCount,
                  color: Colors.blue,
                ),
                _DistributionItem(
                  label: 'Grain',
                  count: stats.grainCount,
                  color: Colors.brown,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDistributionSection(
              context,
              'Meal Type Distribution',
              [
                _DistributionItem(
                  label: 'Breakfast',
                  count: stats.breakfastCount,
                  color: Colors.amber,
                ),
                _DistributionItem(
                  label: 'Lunch',
                  count: stats.lunchCount,
                  color: Colors.cyan,
                ),
                _DistributionItem(
                  label: 'Dinner',
                  count: stats.dinnerCount,
                  color: Colors.indigo,
                ),
                _DistributionItem(
                  label: 'Snack',
                  count: stats.snackCount,
                  color: Colors.purple,
                ),
              ],
            ),
            if (foods.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                Icons.local_fire_department,
                'Avg Calories',
                stats.avgCalories.toStringAsFixed(0),
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                context,
                Icons.grain,
                'Avg Protein',
                '${stats.avgProtein.toStringAsFixed(1)}g',
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                context,
                Icons.bubble_chart,
                'Avg Carbs',
                '${stats.avgCarbs.toStringAsFixed(1)}g',
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                context,
                Icons.opacity,
                'Avg Fat',
                '${stats.avgFat.toStringAsFixed(1)}g',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionSection(
    BuildContext context,
    String title,
    List<_DistributionItem> items,
  ) {
    final total = items.fold<int>(0, (sum, item) => sum + item.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (total > 0)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: items.map((item) {
                  final percentage = item.count / total;
                  return Expanded(
                    flex: (percentage * 100).round().clamp(1, 100),
                    child: Container(color: item.color),
                  );
                }).toList(),
              ),
            ),
          )
        else
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: items.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.label}: ${item.count}',
                  style: context.textTheme.labelSmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  _FoodStats _calculateStats() {
    int fruitCount = 0;
    int vegetableCount = 0;
    int proteinCount = 0;
    int dairyCount = 0;
    int grainCount = 0;
    int breakfastCount = 0;
    int lunchCount = 0;
    int dinnerCount = 0;
    int snackCount = 0;
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final food in foods) {
      // Count by category
      switch (food.category.toLowerCase()) {
        case 'fruit':
          fruitCount++;
        case 'vegetable':
          vegetableCount++;
        case 'protein':
          proteinCount++;
        case 'dairy':
          dairyCount++;
        case 'grain':
          grainCount++;
      }

      // Count by meal type
      switch (food.mealType.toLowerCase()) {
        case 'breakfast':
          breakfastCount++;
        case 'lunch':
          lunchCount++;
        case 'dinner':
          dinnerCount++;
        case 'snack':
          snackCount++;
      }

      // Calculate averages
      totalCalories += food.calories;
      totalProtein += food.protein;
      totalCarbs += food.carbohydrates;
      totalFat += food.fat;
    }

    return _FoodStats(
      fruitCount: fruitCount,
      vegetableCount: vegetableCount,
      proteinCount: proteinCount,
      dairyCount: dairyCount,
      grainCount: grainCount,
      breakfastCount: breakfastCount,
      lunchCount: lunchCount,
      dinnerCount: dinnerCount,
      snackCount: snackCount,
      avgCalories: foods.isEmpty ? 0 : totalCalories / foods.length,
      avgProtein: foods.isEmpty ? 0 : totalProtein / foods.length,
      avgCarbs: foods.isEmpty ? 0 : totalCarbs / foods.length,
      avgFat: foods.isEmpty ? 0 : totalFat / foods.length,
    );
  }
}

class _DistributionItem {
  final String label;
  final int count;
  final Color color;

  const _DistributionItem({
    required this.label,
    required this.count,
    required this.color,
  });
}

class _FoodStats {
  final int fruitCount;
  final int vegetableCount;
  final int proteinCount;
  final int dairyCount;
  final int grainCount;
  final int breakfastCount;
  final int lunchCount;
  final int dinnerCount;
  final int snackCount;
  final double avgCalories;
  final double avgProtein;
  final double avgCarbs;
  final double avgFat;

  const _FoodStats({
    required this.fruitCount,
    required this.vegetableCount,
    required this.proteinCount,
    required this.dairyCount,
    required this.grainCount,
    required this.breakfastCount,
    required this.lunchCount,
    required this.dinnerCount,
    required this.snackCount,
    required this.avgCalories,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFat,
  });
}
