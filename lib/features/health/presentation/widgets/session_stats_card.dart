import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/workout_session.dart';

class SessionStatsCard extends StatelessWidget {
  const SessionStatsCard({super.key, required this.items});

  final List<WorkoutSession> items;

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
                Text(l10n.sessionStatsTitle, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow(context, Icons.timer_outlined, l10n.sessionStatsTotal, '${items.length}'),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildStatRow(context, Icons.local_fire_department, l10n.sessionStatsAvgCalories, stats.avgCalories.toStringAsFixed(1)),
              const SizedBox(height: 8),
              _buildStatRow(context, Icons.favorite, l10n.sessionStatsAvgBpm, stats.avgBpm.toStringAsFixed(0)),
              const SizedBox(height: 8),
              _buildStatRow(context, Icons.water_drop_outlined, l10n.sessionStatsAvgDuration, stats.avgWaterIntake.toStringAsFixed(1)),
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

  _SessionStats _calculateStats() {
    if (items.isEmpty) {
      return const _SessionStats(avgCalories: 0, avgBpm: 0, avgWaterIntake: 0);
    }

    double totalCalories = 0;
    double totalBpm = 0;
    double totalWater = 0;

    for (final item in items) {
      totalCalories += item.caloriesBurned;
      totalBpm += item.avgBpm;
      totalWater += item.waterIntake;
    }

    final n = items.length;
    return _SessionStats(
      avgCalories: totalCalories / n,
      avgBpm: totalBpm / n,
      avgWaterIntake: totalWater / n,
    );
  }
}

class _SessionStats {
  final double avgCalories;
  final double avgBpm;
  final double avgWaterIntake;

  const _SessionStats({
    required this.avgCalories,
    required this.avgBpm,
    required this.avgWaterIntake,
  });
}
