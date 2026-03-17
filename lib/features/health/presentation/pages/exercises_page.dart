import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/shared/layouts/responsive_layout_builder.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../domain/entities/enum_item.dart';
import '../../domain/entities/exercise.dart';
import '../blocs/exercises_bloc.dart';
import '../layouts/exercise_compact_layout.dart';
import '../layouts/exercise_large_layout.dart';
import '../layouts/exercise_medium_layout.dart';
import '../widgets/exercise_delete_dialog.dart';
import '../widgets/exercise_form_dialog.dart';
import '../widgets/health_error_banner.dart';

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({
    super.key,
    required this.createBloc,
    required this.loadEnumByCandidates,
  });

  final ExercisesBloc Function() createBloc;
  final Future<List<EnumItem>> Function(List<String> candidates) loadEnumByCandidates;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => createBloc()..add(const LoadExercisesRequested()),
      child: _ExercisesPageContent(
        loadEnumByCandidates: loadEnumByCandidates,
      ),
    );
  }
}

class _ExercisesPageContent extends StatefulWidget {
  const _ExercisesPageContent({
    required this.loadEnumByCandidates,
  });

  final Future<List<EnumItem>> Function(List<String> candidates) loadEnumByCandidates;

  @override
  State<_ExercisesPageContent> createState() => _ExercisesPageContentState();
}

class _ExercisesPageContentState extends State<_ExercisesPageContent> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  Exercise? _selectedItem;
  bool _showCreateForm = false;
  PaginationInfo? _lastKnownPagination;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExercisesBloc, ExercisesState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final l10n = context.l10n;
        final items = _getItemsFromState(state);
        final pagination = _getPaginationFromState(state);
        final isLoading = _isLoadingState(state);
        final sortedItems = _sortItems(items);
        final errorMessage = switch (state) {
          ExercisesError(:final failure) => failure.debugMessage ?? l10n.exercisesErrorLoading,
          _ => null,
        };

        return Column(
          children: [
            if (errorMessage != null)
              HealthErrorBanner(
                message: errorMessage,
                onRetry: _onRefresh,
              ),
            Expanded(
              child: ResponsiveLayoutBuilder(
                compact: ExerciseCompactLayout(
                  items: sortedItems,
                  pagination: pagination,
                  isLoading: isLoading,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: _onSort,
                  onItemSelected: _onItemSelected,
                  onItemEdit: _showEditDialog,
                  onItemDelete: _showDeleteDialog,
                  onAdd: _showCreateDialog,
                  onImportExport: _onImportExport,
                  onRefresh: _onRefresh,
                  onNextPage: _onNextPage,
                  onPreviousPage: _onPreviousPage,
                ),
                medium: ExerciseMediumLayout(
                  items: sortedItems,
                  pagination: pagination,
                  isLoading: isLoading,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: _onSort,
                  onItemSelected: _onItemSelected,
                  onItemEdit: _showEditDialog,
                  onItemDelete: _showDeleteDialog,
                  onAdd: _showCreateDialog,
                  onImportExport: _onImportExport,
                  onRefresh: _onRefresh,
                  onNextPage: _onNextPage,
                  onPreviousPage: _onPreviousPage,
                ),
                large: ExerciseLargeLayout(
                  items: sortedItems,
                  pagination: pagination,
                  selectedItem: _selectedItem,
                  isLoading: isLoading,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  showCreateForm: _showCreateForm,
                  onSort: _onSort,
                  onItemSelected: _onItemSelected,
                  onItemEdit: _showEditDialog,
                  onItemDelete: _showDeleteDialog,
                  onAdd: _showCreateDialog,
                  onImportExport: _onImportExport,
                  onRefresh: _onRefresh,
                  onCloseDetails: _onCloseDetails,
                  onToggleCreateForm: _onToggleCreateForm,
                  onItemCreated: _onItemCreated,
                  loadEnumByCandidates: widget.loadEnumByCandidates,
                  onNextPage: _onNextPage,
                  onPreviousPage: _onPreviousPage,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  PaginationInfo? _getPaginationFromState(ExercisesState state) {
    return switch (state) {
      ExercisesLoaded(:final pagination) => _lastKnownPagination = pagination,
      _ => _lastKnownPagination,
    };
  }

  List<Exercise> _getItemsFromState(ExercisesState state) {
    return switch (state) {
      ExercisesLoaded(:final items) => items,
      ExerciseCreating(:final existingItems) => existingItems,
      ExerciseCreated(:final allItems) => allItems,
      ExerciseUpdating(:final existingItems) => existingItems,
      ExerciseUpdated(:final allItems) => allItems,
      ExerciseDeleting(:final existingItems) => existingItems,
      ExerciseDeleted(:final remainingItems) => remainingItems,
      _ => [],
    };
  }

  bool _isLoadingState(ExercisesState state) {
    return switch (state) {
      ExercisesInitial() || ExercisesLoading() => true,
      ExerciseCreating() || ExerciseUpdating() || ExerciseDeleting() => true,
      _ => false,
    };
  }

  List<Exercise> _sortItems(List<Exercise> items) {
    final sorted = List<Exercise>.from(items);
    sorted.sort((a, b) {
      int comparison;
      switch (_sortColumnIndex) {
        case 0:
          comparison = a.id.compareTo(b.id);
        case 1:
          comparison = a.imageUrl.compareTo(b.imageUrl);
        case 2:
          comparison = (a.category ?? 0).compareTo(b.category ?? 0);
        case 3:
          comparison = a.targetMuscles.length.compareTo(b.targetMuscles.length);
        case 4:
          comparison = a.bodyParts.length.compareTo(b.bodyParts.length);
        case 5:
          comparison = a.equipments.length.compareTo(b.equipments.length);
        default:
          comparison = a.id.compareTo(b.id);
      }
      return _sortAscending ? comparison : -comparison;
    });
    return sorted;
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _onItemSelected(Exercise item) {
    setState(() {
      _selectedItem = item;
      _showCreateForm = false;
    });
  }

  void _onCloseDetails() {
    setState(() => _selectedItem = null);
  }

  void _onImportExport() {
    context.pushNamed(AppRoutes.exercisesImport);
  }

  void _onToggleCreateForm() {
    setState(() {
      _showCreateForm = !_showCreateForm;
      if (_showCreateForm) _selectedItem = null;
    });
  }

  void _onItemCreated() {
    setState(() => _showCreateForm = false);
  }

  void _onRefresh() {
    context.read<ExercisesBloc>().add(const RefreshExercisesRequested());
  }

  void _handleStateChanges(BuildContext context, ExercisesState state) {
    final l10n = context.l10n;

    switch (state) {
      case ExerciseCreated(:final item):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.exerciseSuccessCreated), behavior: SnackBarBehavior.floating));
        setState(() {
          _selectedItem = item;
          _showCreateForm = false;
        });
      case ExerciseUpdated(:final item):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.exerciseSuccessUpdated), behavior: SnackBarBehavior.floating));
        if (_selectedItem?.id == item.id) setState(() => _selectedItem = item);
      case ExerciseDeleted():
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.exerciseSuccessDeleted), behavior: SnackBarBehavior.floating));
        setState(() => _selectedItem = null);
      case ExercisesError(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(failure.debugMessage ?? l10n.exercisesErrorLoading),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.colorScheme.error,
        ));
      default:
        break;
    }
  }

  Future<void> _showCreateDialog() async {
    final data = await ExerciseFormDialog.show(
      context,
      loadEnumByCandidates: widget.loadEnumByCandidates,
    );
    if (data != null && mounted) {
      context.read<ExercisesBloc>().add(
        CreateExerciseRequested(
          imageUrl: data.imageUrl,
          category: data.category,
          bodyParts: data.bodyParts,
          equipments: data.equipments,
          secondaryMuscles: data.secondaryMuscles,
          targetMuscles: data.targetMuscles,
        ),
      );
    }
  }

  Future<void> _showEditDialog(Exercise item) async {
    final data = await ExerciseFormDialog.show(
      context,
      item: item,
      loadEnumByCandidates: widget.loadEnumByCandidates,
    );
    if (data != null && mounted) {
      context.read<ExercisesBloc>().add(
        UpdateExerciseRequested(
          id: item.id,
          imageUrl: data.imageUrl,
          category: data.category,
          bodyParts: data.bodyParts,
          equipments: data.equipments,
          secondaryMuscles: data.secondaryMuscles,
          targetMuscles: data.targetMuscles,
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(int itemId) async {
    final confirmed = await ExerciseDeleteDialog.show(context);
    if (confirmed && mounted) {
      context.read<ExercisesBloc>().add(DeleteExerciseRequested(id: itemId));
    }
  }

  void _onNextPage() {
    context.read<ExercisesBloc>().add(const ExercisesNextPageRequested());
  }

  void _onPreviousPage() {
    context.read<ExercisesBloc>().add(const ExercisesPreviousPageRequested());
  }
}
