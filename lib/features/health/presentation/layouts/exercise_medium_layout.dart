import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../../../core/shared/widgets/pagination_controls.dart';
import '../../domain/entities/exercise.dart';
import '../widgets/exercise_data_table.dart';
import '../widgets/health_stat_card.dart';

class ExerciseMediumLayout extends StatelessWidget {
  const ExerciseMediumLayout({
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

  final List<Exercise> items;
  final bool isLoading;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(Exercise item) onItemSelected;
  final void Function(Exercise item) onItemEdit;
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
                          ExerciseDataTable(
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
    return Row(
      children: [
        HealthStatCard(
          icon: Icons.fitness_center,
          label: l10n.exerciseStatsTotal,
          value: '${items.length}',
          tone: HealthStatTone.primary,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.track_changes,
          label: l10n.exerciseStatsAvgTargetMuscles,
          value: _avgTargetMuscles().toStringAsFixed(1),
          tone: HealthStatTone.warm,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.accessibility_new,
          label: l10n.exerciseStatsAvgBodyParts,
          value: _avgBodyParts().toStringAsFixed(1),
          tone: HealthStatTone.success,
        ),
        const SizedBox(width: 16),
        HealthStatCard(
          icon: Icons.build_outlined,
          label: l10n.exerciseStatsAvgEquipments,
          value: _avgEquipments().toStringAsFixed(1),
          tone: HealthStatTone.cool,
        ),
      ],
    );
  }

  double _avgTargetMuscles() {
    if (items.isEmpty) return 0;
    return items.fold<int>(0, (sum, e) => sum + e.targetMuscles.length) / items.length;
  }

  double _avgBodyParts() {
    if (items.isEmpty) return 0;
    return items.fold<int>(0, (sum, e) => sum + e.bodyParts.length) / items.length;
  }

  double _avgEquipments() {
    if (items.isEmpty) return 0;
    return items.fold<int>(0, (sum, e) => sum + e.equipments.length) / items.length;
  }

  Widget _buildHeader(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            l10n.exercisesPageTitle,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          if (items.isNotEmpty) Chip(label: Text('${items.length}'), visualDensity: VisualDensity.compact),
          const Spacer(),
          IconButton.outlined(onPressed: onRefresh, icon: const Icon(Icons.refresh), tooltip: l10n.exercisesRefreshButton),
          const SizedBox(width: 8),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(l10n.exerciseAddButton)),
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
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(l10n.exerciseAddButton)),
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
