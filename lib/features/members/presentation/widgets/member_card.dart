import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/subscription.dart';

/// A card widget displaying member information.
class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    required this.member,
    this.onEdit,
    this.onDelete,
  });

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
            if (member.objectives.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildObjectives(context),
            ],
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
              Row(
                children: [
                  _SubscriptionChip(subscription: member.subscription),
                  const SizedBox(width: 8),
                  _LevelChip(level: member.level),
                ],
              ),
            ],
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
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined),
                      const SizedBox(width: 8),
                      Text(l10n.memberFormEditTitle),
                    ],
                  ),
                ),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outlined,
                        color: context.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.memberDeleteDialogConfirmButton,
                        style: TextStyle(color: context.colorScheme.error),
                      ),
                    ],
                  ),
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
        _MetricItem(
          icon: Icons.cake_outlined,
          label: l10n.memberCardAge,
          value: member.age?.toString() ?? l10n.memberCardNotSpecified,
        ),
        _MetricItem(
          icon: Icons.height,
          label: l10n.memberCardHeight,
          value: '${member.height.toStringAsFixed(1)} cm',
        ),
        _MetricItem(
          icon: Icons.monitor_weight_outlined,
          label: l10n.memberCardWeight,
          value: '${member.weight.toStringAsFixed(1)} kg',
        ),
        _MetricItem(
          icon: Icons.speed_outlined,
          label: l10n.memberCardBmi,
          value: member.bmi.toStringAsFixed(1),
        ),
        _MetricItem(
          icon: Icons.water_drop_outlined,
          label: l10n.memberCardFatPercentage,
          value: '${member.fatPercentage.toStringAsFixed(1)}%',
        ),
        _MetricItem(
          icon: Icons.fitness_center,
          label: l10n.memberCardWorkoutFrequency,
          value: '${member.workoutFrequency}x',
        ),
      ],
    );
  }

  Widget _buildObjectives(BuildContext context) {
    final l10n = context.l10n;

    if (member.objectives.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memberCardObjectives,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: member.objectives.map((objective) {
            return Chip(
              label: Text(
                objective.description,
                style: context.textTheme.bodySmall,
              ),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(
          _getGenderIcon(),
          size: 16,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          _getGenderLabel(context),
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        if (member.createdAt != null) ...[
          const Spacer(),
          Text(
            _formatDate(member.createdAt!),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  IconData _getGenderIcon() {
    return switch (member.gender) {
      Gender.male => Icons.male,
      Gender.female => Icons.female,
      Gender.unknow => Icons.person_outline,
    };
  }

  String _getGenderLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (member.gender) {
      Gender.male => l10n.memberGenderMale,
      Gender.female => l10n.memberGenderFemale,
      Gender.unknow => l10n.memberGenderUnknown,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionChip extends StatelessWidget {
  final Subscription subscription;

  const _SubscriptionChip({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color) = switch (subscription) {
      Subscription.free => (l10n.memberSubscriptionFree, Colors.grey),
      Subscription.premium => (l10n.memberSubscriptionPremium, Colors.amber),
      Subscription.premiumPlus => (l10n.memberSubscriptionPremiumPlus, Colors.purple),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final Level level;

  const _LevelChip({required this.level});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = switch (level) {
      Level.beginner => l10n.memberLevelBeginner,
      Level.intermediate => l10n.memberLevelIntermediate,
      Level.expert => l10n.memberLevelExpert,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
