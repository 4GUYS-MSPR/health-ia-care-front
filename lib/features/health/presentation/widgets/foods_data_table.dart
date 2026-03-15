import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/nutrition_food.dart';

/// A data table widget for displaying foods with sorting capabilities.
class FoodsDataTable extends StatelessWidget {
  const FoodsDataTable({
    super.key,
    required this.foods,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onFoodTap,
    required this.onFoodEdit,
    required this.onFoodDelete,
    this.selectedFoodId,
    this.compact = false,
  });

  final List<NutritionFood> foods;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(NutritionFood food) onFoodTap;
  final void Function(NutritionFood food) onFoodEdit;
  final void Function(int foodId) onFoodDelete;
  final int? selectedFoodId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          showCheckboxColumn: false,
          headingRowColor: WidgetStatePropertyAll(
            context.colorScheme.surfaceContainerHighest.withAlpha(128),
          ),
          columns: _buildColumns(context, l10n),
          rows: _buildRows(context, l10n),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(BuildContext context, l10n) {
    return [
      DataColumn(
        label: Text(l10n.foodTableColumnId),
        numeric: true,
        onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text(l10n.foodTableColumnLabel),
        onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text(l10n.foodTableColumnCalories),
        numeric: true,
        onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
      ),
      if (!compact)
        DataColumn(
          label: Text(l10n.foodTableColumnProtein),
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
        ),
      if (!compact)
        DataColumn(
          label: Text(l10n.foodTableColumnCarbs),
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
        ),
      if (!compact)
        DataColumn(
          label: Text(l10n.foodTableColumnFat),
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
        ),
      DataColumn(
        label: Text(l10n.foodTableColumnCategory),
        onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text(l10n.foodTableColumnActions),
      ),
    ];
  }

  List<DataRow> _buildRows(BuildContext context, l10n) {
    return foods.map((food) {
      final isSelected = selectedFoodId == food.id;

      return DataRow(
        selected: isSelected,
        color: isSelected
            ? WidgetStatePropertyAll(
                context.colorScheme.primaryContainer.withAlpha(64),
              )
            : null,
        onSelectChanged: (_) => onFoodTap(food),
        cells: [
          DataCell(Text('#${food.id}')),
          DataCell(
            Text(
              food.label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(Text('${food.calories} kcal')),
          if (!compact) DataCell(Text('${food.protein.toStringAsFixed(1)}g')),
          if (!compact) DataCell(Text('${food.carbohydrates.toStringAsFixed(1)}g')),
          if (!compact) DataCell(Text('${food.fat.toStringAsFixed(1)}g')),
          DataCell(_buildCategoryChip(context, food.category)),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  tooltip: l10n.foodTableViewTooltip,
                  onPressed: () => onFoodTap(food),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: l10n.foodFormEditTitle,
                  onPressed: () => onFoodEdit(food),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outlined,
                    size: 20,
                    color: context.colorScheme.error,
                  ),
                  tooltip: l10n.foodDeleteDialogConfirmButton,
                  onPressed: () => onFoodDelete(food.id),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    // Simple color mapping for common categories
    final color = category.toLowerCase().contains('fruit')
        ? Colors.orange
        : category.toLowerCase().contains('vegetable') || category.toLowerCase().contains('veggie')
        ? Colors.green
        : category.toLowerCase().contains('protein') || category.toLowerCase().contains('meat')
        ? Colors.red
        : category.toLowerCase().contains('dairy')
        ? Colors.blue
        : category.toLowerCase().contains('grain') || category.toLowerCase().contains('cereal')
        ? Colors.brown
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        category,
        style: context.textTheme.labelSmall?.copyWith(
          color: color.shade700,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
