import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../../../core/shared/widgets/pagination_controls.dart';
import '../../domain/entities/workout_session.dart';
import '../widgets/health_stat_card.dart';
import '../widgets/session_data_table.dart';

class SessionMediumLayout extends StatelessWidget {
  const SessionMediumLayout({
    super.key,
    required this.items,
    required this.isLoading,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onItemSelected,
    required this.onItemEdit,
    required this.onItemDelete,
    required this.onAdd,
    required this.onRefresh,
    this.pagination,
    required this.onNextPage,
    required this.onPreviousPage,
  });

  final List<WorkoutSession> items;
  final bool isLoading;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(WorkoutSession item) onItemSelected;
  final void Function(WorkoutSession item) onItemEdit;
  final void Function(int itemId) onItemDelete;
  final VoidCallback onAdd;
  final VoidCallback onRefresh;
  final PaginationInfo? pagination;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          if (items.isNotEmpty)
            SizedBox(
              height: 100,
              child: _buildQuickStats(context, l10n),
            ),
          if (items.isNotEmpty) const SizedBox(height: 16),
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
                        if (items.isEmpty)
                          _buildEmptyState(context, l10n)
                        else
                          SessionDataTable(
                            items: items,
                            sortColumnIndex: sortColumnIndex,
                            sortAscending: sortAscending,
                            onSort: onSort,
                            onItemTap: onItemSelected,
                            onItemEdit: onItemEdit,
                            onItemDelete: onItemDelete,
                          ),
                        if (isLoading) _buildLoadingOverlay(context),
                      ],
                    ),
                  ),
                  if (pagination != null)
                    PaginationControls(
                      pagination: pagination!,
                      onNext: onNextPage,
                      onPrevious: onPreviousPage,
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
        HealthStatCard(
          icon: Icons.timer_outlined,
          label: l10n.sessionStatsTotal,
          value: '${items.length}',
          tone: HealthStatTone.primary,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.local_fire_department,
          label: l10n.sessionStatsAvgCalories,
          value: stats.avgCalories.toStringAsFixed(1),
          tone: HealthStatTone.warm,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.favorite,
          label: l10n.sessionStatsAvgBpm,
          value: stats.avgBpm.toStringAsFixed(0),
          tone: HealthStatTone.success,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.water_drop_outlined,
          label: l10n.sessionStatsAvgDuration,
          value: stats.avgWater.toStringAsFixed(1),
          tone: HealthStatTone.cool,
        ),
      ],
    );
  }

  _QuickStats _calculateQuickStats() {
    if (items.isEmpty) return const _QuickStats(avgCalories: 0, avgBpm: 0, avgWater: 0);
    double totalCal = 0, totalBpm = 0, totalWater = 0;
    for (final item in items) {
      totalCal += item.caloriesBurned;
      totalBpm += item.avgBpm;
      totalWater += item.waterIntake;
    }
    final n = items.length;
    return _QuickStats(avgCalories: totalCal / n, avgBpm: totalBpm / n, avgWater: totalWater / n);
  }

  Widget _buildHeader(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            l10n.sessionsPageTitle,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          if (items.isNotEmpty) Chip(label: Text('${items.length}'), visualDensity: VisualDensity.compact),
          const Spacer(),
          IconButton.outlined(onPressed: onRefresh, icon: const Icon(Icons.refresh), tooltip: l10n.sessionsRefreshButton),
          const SizedBox(width: 8),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(l10n.sessionAddButton)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 64, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(l10n.sessionsEmptyState, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.sessionsEmptyStateDescription, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(l10n.sessionAddButton)),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: context.colorScheme.surface.withAlpha(128),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _QuickStats {
  final double avgCalories;
  final double avgBpm;
  final double avgWater;
  const _QuickStats({required this.avgCalories, required this.avgBpm, required this.avgWater});
}
