import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/member.dart';
import '../widgets/members_data_table.dart';

/// Medium layout for members page - table with optional stats panel.
class MembersMediumLayout extends StatelessWidget {
  const MembersMediumLayout({
    super.key,
    required this.members,
    required this.isLoading,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onMemberSelected,
    required this.onMemberEdit,
    required this.onMemberDelete,
    required this.onAddMember,
    required this.onImportExport,
    required this.onRefresh,
  });

  final List<Member> members;
  final bool isLoading;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(Member member) onMemberSelected;
  final void Function(Member member) onMemberEdit;
  final void Function(int memberId) onMemberDelete;
  final VoidCallback onAddMember;
  final VoidCallback onImportExport;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Stats summary row
          if (members.isNotEmpty)
            SizedBox(
              height: 100,
              child: _buildQuickStats(context, l10n),
            ),
          if (members.isNotEmpty) const SizedBox(height: 16),
          // Main table
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildHeader(context, l10n),
                  const Divider(height: 1),
                  Expanded(
                    child: Stack(
                      children: [
                        if (members.isEmpty)
                          _buildEmptyState(context, l10n)
                        else
                          MembersDataTable(
                            members: members,
                            sortColumnIndex: sortColumnIndex,
                            sortAscending: sortAscending,
                            onSort: onSort,
                            onMemberTap: onMemberSelected,
                            onMemberEdit: onMemberEdit,
                            onMemberDelete: onMemberDelete,
                          ),
                        if (isLoading) _buildLoadingOverlay(context),
                      ],
                    ),
                  ),
                ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, l10n) {
    final stats = _calculateQuickStats();

    return Row(
      children: [
        _QuickStatCard(
          icon: Icons.people,
          label: l10n.memberStatsTotal,
          value: '${members.length}',
          color: context.colorScheme.primary,
        ),
        const SizedBox(width: 16),
        _QuickStatCard(
          icon: Icons.speed_outlined,
          label: l10n.memberStatsAvgBmi,
          value: stats.avgBmi.toStringAsFixed(1),
          color: Colors.orange,
        ),
        const SizedBox(width: 16),
        _QuickStatCard(
          icon: Icons.fitness_center,
          label: l10n.memberStatsAvgWorkout,
          value: '${stats.avgWorkout.toStringAsFixed(1)}x',
          color: Colors.green,
        ),
        const SizedBox(width: 16),
        _QuickStatCard(
          icon: Icons.star,
          label: l10n.memberStatsPremium,
          value: '${stats.premiumCount}',
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            l10n.membersPageTitle,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          if (members.isNotEmpty)
            Chip(
              label: Text('${members.length}'),
              visualDensity: VisualDensity.compact,
            ),
          const Spacer(),
          IconButton.outlined(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.membersRefreshButton,
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onImportExport,
            icon: const Icon(Icons.swap_vert),
            label: Text(l10n.importExportButton),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onAddMember,
            icon: const Icon(Icons.add),
            label: Text(l10n.membersAddButton),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.membersEmptyState,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.membersEmptyStateDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAddMember,
            icon: const Icon(Icons.add),
            label: Text(l10n.membersAddButton),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: context.colorScheme.surface.withAlpha(128),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  _QuickStats _calculateQuickStats() {
    if (members.isEmpty) {
      return const _QuickStats(avgBmi: 0, avgWorkout: 0, premiumCount: 0);
    }

    double totalBmi = 0;
    int totalWorkout = 0;
    int premiumCount = 0;

    for (final member in members) {
      totalBmi += member.bmi;
      totalWorkout += member.workoutFrequency;
      if (member.subscription.index > 0) {
        premiumCount++;
      }
    }

    return _QuickStats(
      avgBmi: totalBmi / members.length,
      avgWorkout: totalWorkout / members.length,
      premiumCount: premiumCount,
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStats {
  final double avgBmi;
  final double avgWorkout;
  final int premiumCount;

  const _QuickStats({
    required this.avgBmi,
    required this.avgWorkout,
    required this.premiumCount,
  });
}
