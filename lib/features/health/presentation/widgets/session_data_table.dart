import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/workout_session.dart';

class SessionDataTable extends StatelessWidget {
  const SessionDataTable({
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

  final List<WorkoutSession> items;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(WorkoutSession item) onItemTap;
  final void Function(WorkoutSession item) onItemEdit;
  final void Function(int itemId) onItemDelete;
  final int? selectedItemId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
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
    );
  }

  List<DataColumn> _buildColumns(dynamic l10n) {
    return [
      DataColumn(
        label: Text(l10n.sessionTableColumnId),
        numeric: true,
        onSort: (int ci, bool asc) => onSort(ci, asc),
      ),
      DataColumn(
        label: Text(l10n.sessionDuration),
        onSort: (int ci, bool asc) => onSort(ci, asc),
      ),
      DataColumn(
        label: Text(l10n.sessionCaloriesBurned),
        numeric: true,
        onSort: (int ci, bool asc) => onSort(ci, asc),
      ),
      if (!compact)
        DataColumn(
          label: Text(l10n.sessionAvgBpm),
          numeric: true,
          onSort: (int ci, bool asc) => onSort(ci, asc),
        ),
      if (!compact)
        DataColumn(
          label: Text(l10n.sessionMaxBpm),
          numeric: true,
          onSort: (int ci, bool asc) => onSort(ci, asc),
        ),
      if (!compact)
        DataColumn(
          label: Text(l10n.sessionWaterIntake),
          numeric: true,
          onSort: (int ci, bool asc) => onSort(ci, asc),
        ),
      DataColumn(label: Text(l10n.sessionTableColumnActions)),
    ];
  }

  List<DataRow> _buildRows(BuildContext context, l10n) {
    return items.map((item) {
      final isSelected = selectedItemId == item.id;

      return DataRow(
        selected: isSelected,
        color: isSelected
            ? WidgetStatePropertyAll(context.colorScheme.primaryContainer.withAlpha(64))
            : null,
        onSelectChanged: (_) => onItemTap(item),
        cells: [
          DataCell(Text('#${item.id}')),
          DataCell(Text(item.duration)),
          DataCell(Text(item.caloriesBurned.toStringAsFixed(1))),
          if (!compact) DataCell(Text('${item.avgBpm}')),
          if (!compact) DataCell(Text('${item.maxBpm}')),
          if (!compact) DataCell(Text(item.waterIntake.toStringAsFixed(1))),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  tooltip: l10n.sessionTableViewTooltip,
                  onPressed: () => onItemTap(item),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: l10n.sessionFormEditTitle,
                  onPressed: () => onItemEdit(item),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outlined, size: 20, color: context.colorScheme.error),
                  tooltip: l10n.sessionDeleteDialogConfirmButton,
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
