import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../../../core/shared/widgets/pagination_controls.dart';
import '../../domain/entities/diet_recommendation.dart';
import '../widgets/diet_data_table.dart';
import '../widgets/health_stat_card.dart';

class DietMediumLayout extends StatelessWidget {
  const DietMediumLayout({
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

  final List<DietRecommendation> items;
  final bool isLoading;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(DietRecommendation item) onItemSelected;
  final void Function(DietRecommendation item) onItemEdit;
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
                          DietDataTable(
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
          icon: Icons.restaurant_menu,
          label: l10n.dietStatsTotal,
          value: '${items.length}',
          tone: HealthStatTone.primary,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.local_fire_department,
          label: l10n.dietStatsAvgCalories,
          value: stats.avgCalories.toStringAsFixed(0),
          tone: HealthStatTone.warm,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.favorite_outlined,
          label: l10n.dietStatsAvgBloodPressure,
          value: stats.avgBP.toStringAsFixed(0),
          tone: HealthStatTone.success,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.check_circle_outlined,
          label: l10n.dietStatsAvgAdherence,
          value: '${stats.avgAdherence.toStringAsFixed(0)}%',
          tone: HealthStatTone.cool,
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
            l10n.dietRecommendationsPageTitle,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          if (items.isNotEmpty) Chip(label: Text('${items.length}'), visualDensity: VisualDensity.compact),
          const Spacer(),
          IconButton.outlined(onPressed: onRefresh, icon: const Icon(Icons.refresh), tooltip: l10n.dietRecommendationsRefreshButton),
          const SizedBox(width: 8),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(l10n.dietAddButton)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_outlined, size: 64, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(l10n.dietRecommendationsEmptyState, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.dietRecommendationsEmptyStateDescription, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(l10n.dietAddButton)),
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

  _QuickStats _calculateQuickStats() {
    if (items.isEmpty) return const _QuickStats(avgCalories: 0, avgBP: 0, avgAdherence: 0);
    double totalCal = 0, totalBP = 0, totalAdh = 0;
    for (final item in items) {
      totalCal += item.dailyCaloricIntake;
      totalBP += item.bloodPressure;
      totalAdh += item.adherenceToDietPlan;
    }
    final n = items.length;
    return _QuickStats(avgCalories: totalCal / n, avgBP: totalBP / n, avgAdherence: (totalAdh / n) * 100);
  }
}

class _QuickStats {
  final double avgCalories;
  final double avgBP;
  final double avgAdherence;
  const _QuickStats({required this.avgCalories, required this.avgBP, required this.avgAdherence});
}
