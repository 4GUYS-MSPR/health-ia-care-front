import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../../../core/shared/widgets/pagination_controls.dart';
import '../../domain/entities/nutrition_food.dart';
import '../widgets/foods_data_table.dart';
import '../widgets/health_stat_card.dart';

/// Medium layout for displaying foods.
class FoodsMediumLayout extends StatelessWidget {
  const FoodsMediumLayout({
    super.key,
    required this.foods,
    required this.isLoading,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onFoodSelected,
    required this.onFoodEdit,
    required this.onFoodDelete,
    required this.onAddFood,
    required this.onImportExport,
    required this.onRefresh,
    this.pagination,
    required this.onNextPage,
    required this.onPreviousPage,
  });

  final List<NutritionFood> foods;
  final bool isLoading;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(NutritionFood food) onFoodSelected;
  final void Function(NutritionFood food) onFoodEdit;
  final void Function(int foodId) onFoodDelete;
  final VoidCallback onAddFood;
  final VoidCallback onImportExport;
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
          if (foods.isNotEmpty)
            SizedBox(
              height: 100,
              child: _buildQuickStats(context, l10n),
            ),
          if (foods.isNotEmpty) const SizedBox(height: 16),
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
                        if (foods.isEmpty)
                          _buildEmptyState(context, l10n)
                        else
                          FoodsDataTable(
                            foods: foods,
                            sortColumnIndex: sortColumnIndex,
                            sortAscending: sortAscending,
                            onSort: onSort,
                            onFoodTap: onFoodSelected,
                            onFoodEdit: onFoodEdit,
                            onFoodDelete: onFoodDelete,
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
          icon: Icons.restaurant,
          label: l10n.foodStatsTotal,
          value: '${foods.length}',
          tone: HealthStatTone.primary,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.local_fire_department,
          label: l10n.foodStatsAvgCalories,
          value: stats.avgCalories.toStringAsFixed(0),
          tone: HealthStatTone.warm,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.grain,
          label: l10n.foodStatsAvgProtein,
          value: '${stats.avgProtein.toStringAsFixed(1)}g',
          tone: HealthStatTone.success,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.bubble_chart,
          label: l10n.foodStatsAvgCarbs,
          value: '${stats.avgCarbs.toStringAsFixed(1)}g',
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
            l10n.foodsPageTitle,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          if (foods.isNotEmpty)
            Chip(
              label: Text('${foods.length}'),
              visualDensity: VisualDensity.compact,
            ),
          const Spacer(),
          IconButton.outlined(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.foodsRefreshButton,
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onImportExport,
            icon: const Icon(Icons.swap_vert),
            label: Text(l10n.importExportButton),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onAddFood,
            icon: const Icon(Icons.add),
            label: Text(l10n.foodsAddButton),
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
            Icons.restaurant_outlined,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.foodsEmptyState,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.foodsEmptyStateDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAddFood,
            icon: const Icon(Icons.add),
            label: Text(l10n.foodsAddButton),
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
    if (foods.isEmpty) {
      return const _QuickStats(avgCalories: 0, avgProtein: 0, avgCarbs: 0);
    }

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;

    for (final food in foods) {
      totalCalories += food.calories;
      totalProtein += food.protein;
      totalCarbs += food.carbohydrates;
    }

    return _QuickStats(
      avgCalories: totalCalories / foods.length,
      avgProtein: totalProtein / foods.length,
      avgCarbs: totalCarbs / foods.length,
    );
  }
}

class _QuickStats {
  final double avgCalories;
  final double avgProtein;
  final double avgCarbs;

  const _QuickStats({
    required this.avgCalories,
    required this.avgProtein,
    required this.avgCarbs,
  });
}
