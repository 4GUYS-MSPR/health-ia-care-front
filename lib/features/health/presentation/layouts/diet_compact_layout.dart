import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../../../core/shared/widgets/pagination_controls.dart';
import '../../domain/entities/diet_recommendation.dart';
import '../widgets/diet_data_table.dart';

class DietCompactLayout extends StatelessWidget {
  const DietCompactLayout({
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
    required this.onImportExport,
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
  final VoidCallback onImportExport;
  final VoidCallback onRefresh;
  final PaginationInfo? pagination;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                      compact: true,
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
          OutlinedButton.icon(
            onPressed: onImportExport,
            icon: const Icon(Icons.swap_vert),
            label: Text(l10n.importExportButton),
          ),
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
}
