import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/diet_recommendation.dart';

class DietDataTable extends StatelessWidget {
  const DietDataTable({
    super.key,
    required this.items,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onItemTap,
    required this.onItemEdit,
    required this.onItemDelete,
    this.selectedItemId,
    this.compact = false,
  });

  final List<DietRecommendation> items;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(DietRecommendation item) onItemTap;
  final void Function(DietRecommendation item) onItemEdit;
  final void Function(int itemId) onItemDelete;
  final int? selectedItemId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscending,
            showCheckboxColumn: false,
            headingRowColor: WidgetStatePropertyAll(
              context.colorScheme.surfaceContainerHighest.withAlpha(128),
            ),
            horizontalMargin: compact ? 12 : 16,
            columnSpacing: compact ? 20 : 28,
            dataRowMinHeight: compact ? 44 : 52,
            dataRowMaxHeight: compact ? 56 : 64,
            columns: _buildColumns(l10n),
            rows: _buildRows(context, l10n),
          ),
        ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(dynamic l10n) {
    return [
      DataColumn(
        label: Text(l10n.dietTableColumnId),
        numeric: true,
        onSort: (ci, asc) => onSort(ci, asc),
      ),
      DataColumn(
        label: Text(l10n.dietBloodPressure),
        numeric: true,
        onSort: (int ci, bool asc) => onSort(ci, asc),
      ),
      DataColumn(
        label: Text(l10n.dietCholesterol),
        numeric: true,
        onSort: (ci, asc) => onSort(ci, asc),
      ),
      if (!compact)
        DataColumn(
          label: Text(l10n.dietGlucose),
          numeric: true,
          onSort: (int ci, bool asc) => onSort(ci, asc),
        ),
      if (!compact)
        DataColumn(
          label: Text(l10n.dietDailyCaloricIntake),
          numeric: true,
          onSort: (int ci, bool asc) => onSort(ci, asc),
        ),
      DataColumn(
        label: Text(l10n.dietAdherence),
        numeric: true,
        onSort: (ci, asc) => onSort(ci, asc),
      ),
      DataColumn(label: Text(l10n.dietTableColumnActions)),
    ];
  }

  List<DataRow> _buildRows(BuildContext context, l10n) {
    return items.map((item) {
      final isSelected = selectedItemId == item.id;

      return DataRow(
        selected: isSelected,
        color: isSelected
            ? WidgetStatePropertyAll(
                context.colorScheme.primaryContainer.withAlpha(64),
              )
            : null,
        onSelectChanged: (_) => onItemTap(item),
        cells: [
          DataCell(Text('#${item.id}')),
          DataCell(Text('${item.bloodPressure}')),
          DataCell(Text(item.cholesterol.toStringAsFixed(1))),
          if (!compact) DataCell(Text(item.glucose.toStringAsFixed(1))),
          if (!compact) DataCell(Text('${item.dailyCaloricIntake}')),
          DataCell(Text('${(item.adherenceToDietPlan * 100).toStringAsFixed(0)}%')),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  tooltip: l10n.dietTableViewTooltip,
                  onPressed: () => onItemTap(item),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: l10n.dietFormEditTitle,
                  onPressed: () => onItemEdit(item),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outlined, size: 20, color: context.colorScheme.error),
                  tooltip: l10n.dietDeleteDialogConfirmButton,
                  onPressed: () => onItemDelete(item.id),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}
