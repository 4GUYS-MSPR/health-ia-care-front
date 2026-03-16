import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/workout_session.dart';

class SessionCard extends StatelessWidget {
  final WorkoutSession item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SessionCard({super.key, required this.item, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 24),
            _buildMetrics(context),
            const SizedBox(height: 12),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: context.colorScheme.primaryContainer,
          child: Icon(Icons.timer_outlined, color: context.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${l10n.sessionLabel} #${item.id}',
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (onEdit != null || onDelete != null)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit?.call();
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (context) => [
              if (onEdit != null)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [const Icon(Icons.edit_outlined), const SizedBox(width: 8), Text(l10n.sessionFormEditTitle)]),
                ),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outlined, color: context.colorScheme.error),
                    const SizedBox(width: 8),
                    Text(l10n.sessionDeleteDialogConfirmButton, style: TextStyle(color: context.colorScheme.error)),
                  ]),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildMetrics(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _MetricItem(icon: Icons.timer, label: l10n.sessionDuration, value: item.duration),
        _MetricItem(icon: Icons.local_fire_department, label: l10n.sessionCaloriesBurned, value: item.caloriesBurned.toStringAsFixed(1)),
        _MetricItem(icon: Icons.favorite, label: l10n.sessionAvgBpm, value: '${item.avgBpm}'),
        _MetricItem(icon: Icons.favorite_border, label: l10n.sessionMaxBpm, value: '${item.maxBpm}'),
        _MetricItem(icon: Icons.hotel, label: l10n.sessionRestingBpm, value: '${item.restingBpm}'),
        _MetricItem(icon: Icons.water_drop_outlined, label: l10n.sessionWaterIntake, value: item.waterIntake.toStringAsFixed(1)),
        _MetricItem(icon: Icons.fitness_center, label: l10n.sessionExercisesCount, value: '${item.exercices.length}'),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Text('#${item.id}', style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.colorScheme.primary),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                Text(value, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
