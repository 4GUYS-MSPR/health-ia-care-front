import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/shared/layouts/responsive_layout_builder.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../../../features/members/domain/entities/member.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_session.dart';
import '../blocs/sessions_bloc.dart';
import '../layouts/session_compact_layout.dart';
import '../layouts/session_large_layout.dart';
import '../layouts/session_medium_layout.dart';
import '../widgets/session_delete_dialog.dart';
import '../widgets/session_form_dialog.dart';
import '../widgets/health_error_banner.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({
    super.key,
    required this.createBloc,
    required this.loadMembers,
    required this.loadExercises,
  });

  final SessionsBloc Function() createBloc;
  final Future<List<Member>> Function() loadMembers;
  final Future<List<Exercise>> Function() loadExercises;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => createBloc()..add(const LoadSessionsRequested()),
      child: _SessionsPageContent(
        loadMembers: loadMembers,
        loadExercises: loadExercises,
      ),
    );
  }
}

class _SessionsPageContent extends StatefulWidget {
  const _SessionsPageContent({
    required this.loadMembers,
    required this.loadExercises,
  });

  final Future<List<Member>> Function() loadMembers;
  final Future<List<Exercise>> Function() loadExercises;

  @override
  State<_SessionsPageContent> createState() => _SessionsPageContentState();
}

class _SessionsPageContentState extends State<_SessionsPageContent> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  WorkoutSession? _selectedItem;
  bool _showCreateForm = false;
  PaginationInfo? _lastKnownPagination;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionsBloc, SessionsState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final l10n = context.l10n;
        final items = _getItemsFromState(state);
        final pagination = _getPaginationFromState(state);
        final isLoading = _isLoadingState(state);
        final sortedItems = _sortItems(items);
        final errorMessage = switch (state) {
          SessionsError(:final failure) => failure.debugMessage ?? l10n.sessionsErrorLoading,
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
                compact: SessionCompactLayout(
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
                medium: SessionMediumLayout(
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
                large: SessionLargeLayout(
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
                  loadMembers: widget.loadMembers,
                  loadExercises: widget.loadExercises,
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

  PaginationInfo? _getPaginationFromState(SessionsState state) {
    return switch (state) {
      SessionsLoaded(:final pagination) => _lastKnownPagination = pagination,
      _ => _lastKnownPagination,
    };
  }

  List<WorkoutSession> _getItemsFromState(SessionsState state) {
    return switch (state) {
      SessionsLoaded(:final items) => items,
      SessionCreating(:final existingItems) => existingItems,
      SessionCreated(:final allItems) => allItems,
      SessionUpdating(:final existingItems) => existingItems,
      SessionUpdated(:final allItems) => allItems,
      SessionDeleting(:final existingItems) => existingItems,
      SessionDeleted(:final remainingItems) => remainingItems,
      _ => [],
    };
  }

  bool _isLoadingState(SessionsState state) {
    return switch (state) {
      SessionsInitial() || SessionsLoading() => true,
      SessionCreating() || SessionUpdating() || SessionDeleting() => true,
      _ => false,
    };
  }

  List<WorkoutSession> _sortItems(List<WorkoutSession> items) {
    final sorted = List<WorkoutSession>.from(items);
    sorted.sort((a, b) {
      int comparison;
      switch (_sortColumnIndex) {
        case 0:
          comparison = a.id.compareTo(b.id);
        case 1:
          comparison = a.duration.compareTo(b.duration);
        case 2:
          comparison = a.caloriesBurned.compareTo(b.caloriesBurned);
        case 3:
          comparison = a.avgBpm.compareTo(b.avgBpm);
        case 4:
          comparison = a.maxBpm.compareTo(b.maxBpm);
        case 5:
          comparison = a.waterIntake.compareTo(b.waterIntake);
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

  void _onItemSelected(WorkoutSession item) {
    setState(() {
      _selectedItem = item;
      _showCreateForm = false;
    });
  }

  void _onCloseDetails() {
    setState(() => _selectedItem = null);
  }

  void _onImportExport() {
    context.pushNamed(AppRoutes.sessionsImport);
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
    context.read<SessionsBloc>().add(const RefreshSessionsRequested());
  }

  void _handleStateChanges(BuildContext context, SessionsState state) {
    final l10n = context.l10n;

    switch (state) {
      case SessionCreated(:final item):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sessionSuccessCreated), behavior: SnackBarBehavior.floating));
        setState(() {
          _selectedItem = item;
          _showCreateForm = false;
        });
      case SessionUpdated(:final item):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sessionSuccessUpdated), behavior: SnackBarBehavior.floating));
        if (_selectedItem?.id == item.id) setState(() => _selectedItem = item);
      case SessionDeleted():
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sessionSuccessDeleted), behavior: SnackBarBehavior.floating));
        setState(() => _selectedItem = null);
      case SessionsError(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(failure.debugMessage ?? l10n.sessionsErrorLoading),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.colorScheme.error,
        ));
      default:
        break;
    }
  }

  Future<void> _showCreateDialog() async {
    final data = await SessionFormDialog.show(
      context,
      loadMembers: widget.loadMembers,
      loadExercises: widget.loadExercises,
    );
    if (data != null && mounted) {
      context.read<SessionsBloc>().add(
        CreateSessionRequested(
          caloriesBurned: data.caloriesBurned,
          duration: data.duration,
          avgBpm: data.avgBpm,
          maxBpm: data.maxBpm,
          restingBpm: data.restingBpm,
          waterIntake: data.waterIntake,
          member: data.member,
          exercices: data.exercices,
        ),
      );
    }
  }

  Future<void> _showEditDialog(WorkoutSession item) async {
    final data = await SessionFormDialog.show(
      context,
      item: item,
      loadMembers: widget.loadMembers,
      loadExercises: widget.loadExercises,
    );
    if (data != null && mounted) {
      context.read<SessionsBloc>().add(
        UpdateSessionRequested(
          id: item.id,
          caloriesBurned: data.caloriesBurned,
          duration: data.duration,
          avgBpm: data.avgBpm,
          maxBpm: data.maxBpm,
          restingBpm: data.restingBpm,
          waterIntake: data.waterIntake,
          member: data.member,
          exercices: data.exercices,
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(int itemId) async {
    final confirmed = await SessionDeleteDialog.show(context);
    if (confirmed && mounted) {
      context.read<SessionsBloc>().add(DeleteSessionRequested(id: itemId));
    }
  }

  void _onNextPage() {
    context.read<SessionsBloc>().add(const SessionsNextPageRequested());
  }

  void _onPreviousPage() {
    context.read<SessionsBloc>().add(const SessionsPreviousPageRequested());
  }
}
