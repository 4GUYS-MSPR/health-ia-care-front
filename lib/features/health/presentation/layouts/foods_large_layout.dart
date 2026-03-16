import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../../../core/shared/widgets/pagination_controls.dart';
import '../../domain/entities/enum_item.dart';
import '../../domain/entities/nutrition_food.dart';
import '../widgets/food_detail_panel.dart';
import '../widgets/food_form_panel.dart';
import '../widgets/food_stats_card.dart';
import '../widgets/foods_data_table.dart';

/// Large layout for displaying foods with data table.
class FoodsLargeLayout extends StatelessWidget {
  const FoodsLargeLayout({
    super.key,
    required this.foods,
    required this.selectedFood,
    required this.isLoading,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.showCreateForm,
    required this.onSort,
    required this.onFoodSelected,
    required this.onFoodEdit,
    required this.onFoodDelete,
    required this.onAddFood,
    required this.onRefresh,
    required this.onCloseDetails,
    required this.onToggleCreateForm,
    required this.onFoodCreated,
    required this.loadEnumByCandidates,
    this.pagination,
    required this.onNextPage,
    required this.onPreviousPage,
  });

  final List<NutritionFood> foods;
  final NutritionFood? selectedFood;
  final bool isLoading;
  final int sortColumnIndex;
  final bool sortAscending;
  final bool showCreateForm;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(NutritionFood food) onFoodSelected;
  final void Function(NutritionFood food) onFoodEdit;
  final void Function(int foodId) onFoodDelete;
  final VoidCallback onAddFood;
  final VoidCallback onRefresh;
  final VoidCallback onCloseDetails;
  final VoidCallback onToggleCreateForm;
  final VoidCallback onFoodCreated;
  final Future<List<EnumItem>> Function(List<String> candidates)
      loadEnumByCandidates;
  final PaginationInfo? pagination;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildMainContent(context),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: _buildSidePanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final l10n = context.l10n;

    return Card(
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
                    selectedFoodId: selectedFood?.id,
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
    );
  }

  Widget _buildSidePanel(BuildContext context) {
    final l10n = context.l10n;

    if (showCreateForm) {
      return FoodFormPanel(
        onCancel: onToggleCreateForm,
        onSaved: onFoodCreated,
        loadEnumByCandidates: loadEnumByCandidates,
      );
    }

    if (selectedFood != null) {
      return FoodDetailsPanel(
        food: selectedFood!,
        onClose: onCloseDetails,
        onEdit: () => onFoodEdit(selectedFood!),
        onDelete: () => onFoodDelete(selectedFood!.id),
      );
    }

    return Column(
      children: [
        FoodStatsCard(foods: foods),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.foodFormCreateTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.foodsEmptyStateDescription,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onToggleCreateForm,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.foodsAddButton),
                ),
              ],
            ),
          ),
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
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
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
          FilledButton.icon(
            onPressed: onToggleCreateForm,
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
}
