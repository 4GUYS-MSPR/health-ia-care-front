import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/diet_recommendation.dart';

class DietDetailPanel extends StatelessWidget {
  const DietDetailPanel({
    super.key,
    required this.item,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  final DietRecommendation item;
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
                  _buildHealthSection(context, l10n),
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
            child: Icon(Icons.restaurant_outlined, color: context.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.dietRecommendationLabel} #${item.id}',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${l10n.dietDailyCaloricIntake}: ${item.dailyCaloricIntake}',
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

  Widget _buildHealthSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dietDetailsHealthMetrics, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: context.colorScheme.primary)),
        const SizedBox(height: 12),
        _buildInfoRow(context, Icons.favorite_outlined, l10n.dietBloodPressure, '${item.bloodPressure}'),
        _buildInfoRow(context, Icons.water_drop_outlined, l10n.dietCholesterol, item.cholesterol.toStringAsFixed(1)),
        _buildInfoRow(context, Icons.bloodtype_outlined, l10n.dietGlucose, item.glucose.toStringAsFixed(1)),
        _buildInfoRow(context, Icons.local_fire_department, l10n.dietDailyCaloricIntake, '${item.dailyCaloricIntake}'),
        _buildInfoRow(context, Icons.directions_run, l10n.dietWeeklyExerciseHours, item.weeklyExerciseHours.toStringAsFixed(1)),
        _buildInfoRow(context, Icons.check_circle_outlined, l10n.dietAdherence, '${(item.adherenceToDietPlan * 100).toStringAsFixed(0)}%'),
        _buildInfoRow(context, Icons.balance_outlined, l10n.dietNutrientImbalance, item.dietaryNutrientImbalanceScore.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dietDetailsInfo, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: context.colorScheme.primary)),
        const SizedBox(height: 12),
        _buildInfoRow(context, Icons.info_outline, l10n.dietTableColumnId, '#${item.id}'),
        if (item.activity != null) _buildInfoRow(context, Icons.sports, l10n.dietActivity, '${item.activity}'),
        if (item.diseaseType != null) _buildInfoRow(context, Icons.medical_information, l10n.dietDiseaseType, '${item.diseaseType}'),
        if (item.severity != null) _buildInfoRow(context, Icons.priority_high, l10n.dietSeverity, '${item.severity}'),
        if (item.member != null) _buildInfoRow(context, Icons.person, l10n.dietMember, '${item.member}'),
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
              label: Text(l10n.dietDetailsDelete, style: TextStyle(color: context.colorScheme.error)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.dietDetailsEdit),
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
