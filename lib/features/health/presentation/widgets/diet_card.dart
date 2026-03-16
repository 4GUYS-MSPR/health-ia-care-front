import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/diet_recommendation.dart';

class DietCard extends StatelessWidget {
  final DietRecommendation item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DietCard({super.key, required this.item, this.onEdit, this.onDelete});

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
          child: Icon(Icons.restaurant_outlined, color: context.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${l10n.dietRecommendationLabel} #${item.id}',
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                  child: Row(children: [const Icon(Icons.edit_outlined), const SizedBox(width: 8), Text(l10n.dietFormEditTitle)]),
                ),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outlined, color: context.colorScheme.error),
                    const SizedBox(width: 8),
                    Text(l10n.dietDeleteDialogConfirmButton, style: TextStyle(color: context.colorScheme.error)),
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
        _MetricItem(icon: Icons.favorite_outlined, label: l10n.dietBloodPressure, value: '${item.bloodPressure}'),
        _MetricItem(icon: Icons.water_drop_outlined, label: l10n.dietCholesterol, value: item.cholesterol.toStringAsFixed(1)),
        _MetricItem(icon: Icons.bloodtype_outlined, label: l10n.dietGlucose, value: item.glucose.toStringAsFixed(1)),
        _MetricItem(icon: Icons.local_fire_department, label: l10n.dietDailyCaloricIntake, value: '${item.dailyCaloricIntake}'),
        _MetricItem(icon: Icons.directions_run, label: l10n.dietWeeklyExerciseHours, value: item.weeklyExerciseHours.toStringAsFixed(1)),
        _MetricItem(icon: Icons.check_circle_outlined, label: l10n.dietAdherence, value: '${(item.adherenceToDietPlan * 100).toStringAsFixed(0)}%'),
        _MetricItem(icon: Icons.balance_outlined, label: l10n.dietNutrientImbalance, value: item.dietaryNutrientImbalanceScore.toStringAsFixed(2)),
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
      width: 140,
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
