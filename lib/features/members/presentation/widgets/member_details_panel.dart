import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/subscription.dart';

/// A panel widget displaying detailed member information.
class MemberDetailsPanel extends StatelessWidget {
  const MemberDetailsPanel({
    super.key,
    required this.member,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  final Member member;
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
                  _buildProfileSection(context, l10n),
                  const SizedBox(height: 24),
                  _buildMetricsSection(context, l10n),
                  const SizedBox(height: 24),
                  _buildObjectivesSection(context, l10n),
                  if (member.createdAt != null) ...[
                    const SizedBox(height: 24),
                    _buildMetadataSection(context, l10n),
                  ],
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
            child: Icon(
              _getGenderIcon(),
              color: context.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Member #${member.id}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getLevelLabel(l10n),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memberDetailsProfile,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          Icons.person_outline,
          l10n.memberFormGenderLabel,
          _getGenderLabel(l10n),
        ),
        _buildInfoRow(
          context,
          Icons.cake_outlined,
          l10n.memberFormAgeLabel,
          member.age?.toString() ?? l10n.memberCardNotSpecified,
        ),
        _buildInfoRow(
          context,
          Icons.star_outline,
          l10n.memberFormSubscriptionLabel,
          _getSubscriptionLabel(l10n),
        ),
      ],
    );
  }

  Widget _buildMetricsSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memberDetailsMetrics,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.height,
                label: l10n.memberCardHeight,
                value: '${member.height.toStringAsFixed(1)} cm',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.monitor_weight_outlined,
                label: l10n.memberCardWeight,
                value: '${member.weight.toStringAsFixed(1)} kg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.speed_outlined,
                label: l10n.memberCardBmi,
                value: member.bmi.toStringAsFixed(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.water_drop_outlined,
                label: l10n.memberCardFatPercentage,
                value: '${member.fatPercentage.toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MetricCard(
          icon: Icons.fitness_center,
          label: l10n.memberCardWorkoutFrequency,
          value: '${member.workoutFrequency}x / week',
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildObjectivesSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memberCardObjectives,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (member.objectives.isEmpty)
          Text(
            l10n.memberDetailsNoObjectives,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: member.objectives.map((objective) {
              return Chip(
                avatar: Icon(
                  Icons.flag_outlined,
                  size: 16,
                  color: context.colorScheme.primary,
                ),
                label: Text(objective.description),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memberDetailsMetadata,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          Icons.calendar_today_outlined,
          l10n.memberDetailsCreatedAt,
          _formatDate(member.createdAt!),
        ),
        if (member.clientId != null)
          _buildInfoRow(
            context,
            Icons.tag,
            l10n.memberDetailsClientId,
            '#${member.clientId}',
          ),
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
              label: Text(
                l10n.memberDeleteDialogConfirmButton,
                style: TextStyle(color: context.colorScheme.error),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.memberFormEditTitle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
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
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGenderIcon() {
    return switch (member.gender) {
      Gender.male => Icons.male,
      Gender.female => Icons.female,
      Gender.unknow => Icons.person_outline,
    };
  }

  String _getGenderLabel(dynamic l10n) {
    return switch (member.gender) {
      Gender.male => l10n.memberGenderMale,
      Gender.female => l10n.memberGenderFemale,
      Gender.unknow => l10n.memberGenderUnknown,
    };
  }

  String _getLevelLabel(dynamic l10n) {
    return switch (member.level) {
      Level.beginner => l10n.memberLevelBeginner,
      Level.intermediate => l10n.memberLevelIntermediate,
      Level.expert => l10n.memberLevelExpert,
    };
  }

  String _getSubscriptionLabel(dynamic l10n) {
    return switch (member.subscription) {
      Subscription.free => l10n.memberSubscriptionFree,
      Subscription.premium => l10n.memberSubscriptionPremium,
      Subscription.premiumPlus => l10n.memberSubscriptionPremiumPlus,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
