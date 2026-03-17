import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../../../core/shared/widgets/pagination_controls.dart';
import '../../domain/entities/enum_item.dart';
import '../../domain/entities/exercise.dart';
import '../widgets/exercise_data_table.dart';
import '../widgets/exercise_detail_panel.dart';
import '../widgets/exercise_form_panel.dart';
import '../widgets/exercise_stats_card.dart';

class ExerciseLargeLayout extends StatelessWidget {
  const ExerciseLargeLayout({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.isLoading,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.showCreateForm,
    required this.onSort,
    required this.onItemSelected,
    required this.onItemEdit,
    required this.onItemDelete,
    required this.onAdd,
    required this.onImportExport,
    required this.onRefresh,
    required this.onCloseDetails,
    required this.onToggleCreateForm,
    required this.onItemCreated,
    required this.loadEnumByCandidates,
    this.pagination,
    required this.onNextPage,
    required this.onPreviousPage,
  });

  final List<Exercise> items;
  final Exercise? selectedItem;
  final bool isLoading;
  final int sortColumnIndex;
  final bool sortAscending;
  final bool showCreateForm;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(Exercise item) onItemSelected;
  final void Function(Exercise item) onItemEdit;
  final void Function(int itemId) onItemDelete;
  final VoidCallback onAdd;
  final VoidCallback onImportExport;
  final VoidCallback onRefresh;
  final VoidCallback onCloseDetails;
  final VoidCallback onToggleCreateForm;
  final VoidCallback onItemCreated;
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
          Expanded(flex: 3, child: _buildMainContent(context)),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: _buildSidePanel(context)),
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
                if (items.isEmpty)
                  _buildEmptyState(context, l10n)
                else
                  ExerciseDataTable(
                    items: items,
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: sortAscending,
                    onSort: onSort,
                    onItemTap: onItemSelected,
                    onItemEdit: onItemEdit,
                    onItemDelete: onItemDelete,
                    selectedItemId: selectedItem?.id,
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
      return ExerciseFormPanel(
        onCancel: onToggleCreateForm,
        onSaved: onItemCreated,
        loadEnumByCandidates: loadEnumByCandidates,
      );
    }

    if (selectedItem != null) {
      return ExerciseDetailPanel(
        item: selectedItem!,
        onClose: onCloseDetails,
        onEdit: () => onItemEdit(selectedItem!),
        onDelete: () => onItemDelete(selectedItem!.id),
      );
    }

    return Column(
      children: [
        ExerciseStatsCard(items: items),
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
                    Icon(Icons.fitness_center, color: context.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(l10n.exerciseFormCreateTitle, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l10n.exercisesEmptyStateDescription, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onToggleCreateForm,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.exerciseAddButton),
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
          Text(l10n.exercisesPageTitle, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          if (items.isNotEmpty) Chip(label: Text('${items.length}'), visualDensity: VisualDensity.compact),
          const Spacer(),
          IconButton.outlined(onPressed: onRefresh, icon: const Icon(Icons.refresh), tooltip: l10n.exercisesRefreshButton),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onImportExport,
            icon: const Icon(Icons.swap_vert),
            label: Text(l10n.importExportButton),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(onPressed: onToggleCreateForm, icon: const Icon(Icons.add), label: Text(l10n.exerciseAddButton)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center, size: 64, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(l10n.exercisesEmptyState, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.exercisesEmptyStateDescription, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
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
