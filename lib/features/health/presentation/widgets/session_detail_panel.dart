import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/workout_session.dart';

class SessionDetailPanel extends StatelessWidget {
  const SessionDetailPanel({
    super.key,
    required this.item,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkoutSession item;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, l10n),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetricsSection(context, l10n),
                  const SizedBox(height: 24),
                  _buildDetailsSection(context, l10n),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          _buildActions(context, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.colorScheme.primaryContainer,
            child: Icon(Icons.timer_outlined, color: context.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.sessionLabel} #${item.id}',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${l10n.sessionDuration}: ${item.duration}',
                  style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.sessionDetailsMetrics, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: context.colorScheme.primary)),
        const SizedBox(height: 12),
        _buildInfoRow(context, Icons.local_fire_department, l10n.sessionCaloriesBurned, item.caloriesBurned.toStringAsFixed(1)),
        _buildInfoRow(context, Icons.timer, l10n.sessionDuration, item.duration),
        _buildInfoRow(context, Icons.favorite, l10n.sessionAvgBpm, '${item.avgBpm}'),
        _buildInfoRow(context, Icons.favorite_border, l10n.sessionMaxBpm, '${item.maxBpm}'),
        _buildInfoRow(context, Icons.hotel, l10n.sessionRestingBpm, '${item.restingBpm}'),
        _buildInfoRow(context, Icons.water_drop_outlined, l10n.sessionWaterIntake, item.waterIntake.toStringAsFixed(1)),
        _buildInfoRow(context, Icons.fitness_center, l10n.sessionExercisesCount, '${item.exercices.length}'),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.sessionDetailsInfo, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: context.colorScheme.primary)),
        const SizedBox(height: 12),
        _buildInfoRow(context, Icons.info_outline, l10n.sessionTableColumnId, '#${item.id}'),
        _buildInfoRow(context, Icons.person, l10n.sessionMember, '${item.member}'),
        if (item.createdAt != null)
          _buildInfoRow(context, Icons.calendar_today, 'Created', item.createdAt.toString()),
      ],
    );
  }

  Widget _buildActions(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outlined, color: context.colorScheme.error),
              label: Text(l10n.sessionDetailsDelete, style: TextStyle(color: context.colorScheme.error)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.sessionDetailsEdit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
