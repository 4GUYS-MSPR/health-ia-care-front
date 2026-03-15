import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/subscription.dart';

/// A card widget displaying aggregated member statistics.
class MemberStatsCard extends StatelessWidget {
  const MemberStatsCard({
    super.key,
    required this.members,
  });

  final List<Member> members;

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
                Icon(
                  Icons.analytics_outlined,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.memberStatsTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              context,
              Icons.people_outline,
              l10n.memberStatsTotal,
              '${members.length}',
            ),
            const SizedBox(height: 12),
            _buildDistributionSection(
              context,
              l10n.memberStatsGenderDistribution,
              [
                _DistributionItem(
                  label: l10n.memberGenderMale,
                  count: stats.maleCount,
                  color: Colors.blue,
                ),
                _DistributionItem(
                  label: l10n.memberGenderFemale,
                  count: stats.femaleCount,
                  color: Colors.pink,
                ),
                _DistributionItem(
                  label: l10n.memberGenderUnknown,
                  count: stats.unknownGenderCount,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDistributionSection(
              context,
              l10n.memberStatsLevelDistribution,
              [
                _DistributionItem(
                  label: l10n.memberLevelBeginner,
                  count: stats.beginnerCount,
                  color: Colors.green,
                ),
                _DistributionItem(
                  label: l10n.memberLevelIntermediate,
                  count: stats.intermediateCount,
                  color: Colors.orange,
                ),
                _DistributionItem(
                  label: l10n.memberLevelExpert,
                  count: stats.expertCount,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDistributionSection(
              context,
              l10n.memberStatsSubscriptionDistribution,
              [
                _DistributionItem(
                  label: l10n.memberSubscriptionFree,
                  count: stats.freeCount,
                  color: Colors.grey,
                ),
                _DistributionItem(
                  label: l10n.memberSubscriptionPremium,
                  count: stats.premiumCount,
                  color: Colors.amber,
                ),
                _DistributionItem(
                  label: l10n.memberSubscriptionPremiumPlus,
                  count: stats.premiumPlusCount,
                  color: Colors.purple,
                ),
              ],
            ),
            if (members.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                Icons.speed_outlined,
                l10n.memberStatsAvgBmi,
                stats.avgBmi.toStringAsFixed(1),
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                context,
                Icons.fitness_center,
                l10n.memberStatsAvgWorkout,
                '${stats.avgWorkout.toStringAsFixed(1)}x',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
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
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionSection(
    BuildContext context,
    String title,
    List<_DistributionItem> items,
  ) {
    final total = items.fold<int>(0, (sum, item) => sum + item.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (total > 0)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: items.map((item) {
                  final percentage = item.count / total;
                  return Expanded(
                    flex: (percentage * 100).round().clamp(1, 100),
                    child: Container(color: item.color),
                  );
                }).toList(),
              ),
            ),
          )
        else
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: items.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.label}: ${item.count}',
                  style: context.textTheme.labelSmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  _MemberStats _calculateStats() {
    int maleCount = 0;
    int femaleCount = 0;
    int unknownGenderCount = 0;
    int beginnerCount = 0;
    int intermediateCount = 0;
    int expertCount = 0;
    int freeCount = 0;
    int premiumCount = 0;
    int premiumPlusCount = 0;
    double totalBmi = 0;
    int totalWorkout = 0;

    for (final member in members) {
      switch (member.gender) {
        case Gender.male:
          maleCount++;
        case Gender.female:
          femaleCount++;
        case Gender.unknow:
          unknownGenderCount++;
      }

      switch (member.level) {
        case Level.beginner:
          beginnerCount++;
        case Level.intermediate:
          intermediateCount++;
        case Level.expert:
          expertCount++;
      }

      switch (member.subscription) {
        case Subscription.free:
          freeCount++;
        case Subscription.premium:
          premiumCount++;
        case Subscription.premiumPlus:
          premiumPlusCount++;
      }

      totalBmi += member.bmi;
      totalWorkout += member.workoutFrequency;
    }

    return _MemberStats(
      maleCount: maleCount,
      femaleCount: femaleCount,
      unknownGenderCount: unknownGenderCount,
      beginnerCount: beginnerCount,
      intermediateCount: intermediateCount,
      expertCount: expertCount,
      freeCount: freeCount,
      premiumCount: premiumCount,
      premiumPlusCount: premiumPlusCount,
      avgBmi: members.isEmpty ? 0 : totalBmi / members.length,
      avgWorkout: members.isEmpty ? 0 : totalWorkout / members.length,
    );
  }
}

class _DistributionItem {
  final String label;
  final int count;
  final Color color;

  const _DistributionItem({
    required this.label,
    required this.count,
    required this.color,
  });
}

class _MemberStats {
  final int maleCount;
  final int femaleCount;
  final int unknownGenderCount;
  final int beginnerCount;
  final int intermediateCount;
  final int expertCount;
  final int freeCount;
  final int premiumCount;
  final int premiumPlusCount;
  final double avgBmi;
  final double avgWorkout;

  const _MemberStats({
    required this.maleCount,
    required this.femaleCount,
    required this.unknownGenderCount,
    required this.beginnerCount,
    required this.intermediateCount,
    required this.expertCount,
    required this.freeCount,
    required this.premiumCount,
    required this.premiumPlusCount,
    required this.avgBmi,
    required this.avgWorkout,
  });
}
