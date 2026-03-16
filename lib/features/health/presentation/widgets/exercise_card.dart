import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/exercise.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExerciseCard({super.key, required this.item, this.onEdit, this.onDelete});

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
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            item.imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => CircleAvatar(
              backgroundColor: context.colorScheme.primaryContainer,
              child: Icon(Icons.fitness_center, color: context.colorScheme.onPrimaryContainer),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${l10n.exerciseLabel} #${item.id}',
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
                  child: Row(children: [const Icon(Icons.edit_outlined), const SizedBox(width: 8), Text(l10n.exerciseFormEditTitle)]),
                ),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outlined, color: context.colorScheme.error),
                    const SizedBox(width: 8),
                    Text(l10n.exerciseDeleteDialogConfirmButton, style: TextStyle(color: context.colorScheme.error)),
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
        _MetricItem(icon: Icons.category_outlined, label: l10n.exerciseTableColumnCategory, value: '${item.category ?? '-'}'),
        _MetricItem(icon: Icons.track_changes, label: l10n.exerciseTargetMuscles, value: '${item.targetMuscles.length}'),
        _MetricItem(icon: Icons.accessibility_new, label: l10n.exerciseBodyParts, value: '${item.bodyParts.length}'),
        _MetricItem(icon: Icons.hardware, label: l10n.exerciseTableColumnEquipments, value: '${item.equipments.length}'),
        _MetricItem(icon: Icons.sports_gymnastics, label: l10n.exerciseTableColumnSecondary, value: '${item.secondaryMuscles.length}'),
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
