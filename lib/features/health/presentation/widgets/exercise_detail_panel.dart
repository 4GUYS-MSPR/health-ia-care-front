import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/exercise.dart';

class ExerciseDetailPanel extends StatelessWidget {
  const ExerciseDetailPanel({
    super.key,
    required this.item,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  final Exercise item;
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
                  _buildImageSection(context),
                  const SizedBox(height: 24),
                  _buildMusclesSection(context, l10n),
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
            child: Icon(Icons.fitness_center, color: context.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.exerciseLabel} #${item.id}',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${l10n.exerciseTableColumnCategory}: ${item.category ?? '-'}',
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

  Widget _buildImageSection(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        item.imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 200,
          color: context.colorScheme.surfaceContainerHighest,
          child: Icon(Icons.fitness_center, size: 64, color: context.colorScheme.outline),
        ),
      ),
    );
  }

  Widget _buildMusclesSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.exerciseDetailsMuscles, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: context.colorScheme.primary)),
        const SizedBox(height: 12),
        _buildInfoRow(context, Icons.track_changes, l10n.exerciseTargetMuscles, '${item.targetMuscles.length} muscles'),
        _buildInfoRow(context, Icons.sports_gymnastics, l10n.exerciseTableColumnSecondary, '${item.secondaryMuscles.length} muscles'),
        _buildInfoRow(context, Icons.accessibility_new, l10n.exerciseBodyParts, '${item.bodyParts.length} parts'),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.exerciseDetailsInfo, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: context.colorScheme.primary)),
        const SizedBox(height: 12),
        _buildInfoRow(context, Icons.info_outline, l10n.exerciseTableColumnId, '#${item.id}'),
        _buildInfoRow(context, Icons.category_outlined, l10n.exerciseTableColumnCategory, '${item.category ?? '-'}'),
        _buildInfoRow(context, Icons.hardware, l10n.exerciseTableColumnEquipments, '${item.equipments.length} items'),
        if (item.client != null) _buildInfoRow(context, Icons.person, l10n.exerciseClient, '${item.client}'),
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
              label: Text(l10n.exerciseDetailsDelete, style: TextStyle(color: context.colorScheme.error)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.exerciseDetailsEdit),
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
