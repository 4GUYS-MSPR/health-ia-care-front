import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/diet_recommendation.dart';

class DietStatsCard extends StatelessWidget {
  const DietStatsCard({super.key, required this.items});

  final List<DietRecommendation> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                Icon(Icons.analytics_outlined, color: context.colorScheme.primary),
                const SizedBox(width: 12),
                Text(l10n.dietStatsTitle, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow(context, Icons.restaurant_menu, l10n.dietStatsTotal, '${items.length}'),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildStatRow(context, Icons.local_fire_department, l10n.dietStatsAvgCalories, stats.avgCalories.toStringAsFixed(0)),
              const SizedBox(height: 8),
              _buildStatRow(context, Icons.favorite_outlined, l10n.dietStatsAvgBloodPressure, stats.avgBloodPressure.toStringAsFixed(0)),
              const SizedBox(height: 8),
              _buildStatRow(context, Icons.water_drop_outlined, l10n.dietStatsAvgCholesterol, stats.avgCholesterol.toStringAsFixed(1)),
              const SizedBox(height: 8),
              _buildStatRow(context, Icons.bloodtype_outlined, l10n.dietStatsAvgGlucose, stats.avgGlucose.toStringAsFixed(1)),
              const SizedBox(height: 8),
              _buildStatRow(context, Icons.check_circle_outlined, l10n.dietStatsAvgAdherence, '${stats.avgAdherence.toStringAsFixed(0)}%'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(label, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(value, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  _DietStats _calculateStats() {
    if (items.isEmpty) {
      return const _DietStats(avgCalories: 0, avgBloodPressure: 0, avgCholesterol: 0, avgGlucose: 0, avgAdherence: 0);
    }

    double totalCalories = 0;
    double totalBP = 0;
    double totalCholesterol = 0;
    double totalGlucose = 0;
    double totalAdherence = 0;

    for (final item in items) {
      totalCalories += item.dailyCaloricIntake;
      totalBP += item.bloodPressure;
      totalCholesterol += item.cholesterol;
      totalGlucose += item.glucose;
      totalAdherence += item.adherenceToDietPlan;
    }

    final n = items.length;
    return _DietStats(
      avgCalories: totalCalories / n,
      avgBloodPressure: totalBP / n,
      avgCholesterol: totalCholesterol / n,
      avgGlucose: totalGlucose / n,
      avgAdherence: (totalAdherence / n) * 100,
    );
  }
}

class _DietStats {
  final double avgCalories;
  final double avgBloodPressure;
  final double avgCholesterol;
  final double avgGlucose;
  final double avgAdherence;

  const _DietStats({
    required this.avgCalories,
    required this.avgBloodPressure,
    required this.avgCholesterol,
    required this.avgGlucose,
    required this.avgAdherence,
  });
}
