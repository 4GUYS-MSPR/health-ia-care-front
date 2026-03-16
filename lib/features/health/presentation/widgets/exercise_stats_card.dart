import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/exercise.dart';

class ExerciseStatsCard extends StatelessWidget {
  const ExerciseStatsCard({super.key, required this.items});

  final List<Exercise> items;

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
                Text(l10n.exerciseStatsTitle, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow(context, Icons.fitness_center, l10n.exerciseStatsTotal, '${items.length}'),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildStatRow(context, Icons.track_changes, l10n.exerciseStatsAvgTargetMuscles, stats.avgTargetMuscles.toStringAsFixed(1)),
              const SizedBox(height: 8),
              _buildStatRow(context, Icons.accessibility_new, l10n.exerciseStatsAvgBodyParts, stats.avgBodyParts.toStringAsFixed(1)),
              const SizedBox(height: 8),
              _buildStatRow(context, Icons.hardware, l10n.exerciseStatsAvgEquipments, stats.avgEquipments.toStringAsFixed(1)),
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

  _ExerciseStats _calculateStats() {
    if (items.isEmpty) return const _ExerciseStats(avgTargetMuscles: 0, avgBodyParts: 0, avgEquipments: 0);

    double totalTarget = 0;
    double totalBody = 0;
    double totalEquip = 0;

    for (final item in items) {
      totalTarget += item.targetMuscles.length;
      totalBody += item.bodyParts.length;
      totalEquip += item.equipments.length;
    }

    final n = items.length;
    return _ExerciseStats(
      avgTargetMuscles: totalTarget / n,
      avgBodyParts: totalBody / n,
      avgEquipments: totalEquip / n,
    );
  }
}

class _ExerciseStats {
  final double avgTargetMuscles;
  final double avgBodyParts;
  final double avgEquipments;

  const _ExerciseStats({required this.avgTargetMuscles, required this.avgBodyParts, required this.avgEquipments});
}
