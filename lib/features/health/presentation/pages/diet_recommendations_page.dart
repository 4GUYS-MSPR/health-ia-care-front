import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/shared/layouts/responsive_layout_builder.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../../../features/members/domain/entities/member.dart';
import '../../domain/entities/diet_recommendation.dart';
import '../../domain/entities/enum_item.dart';
import '../blocs/diet_recommendations_bloc.dart';
import '../layouts/diet_compact_layout.dart';
import '../layouts/diet_large_layout.dart';
import '../layouts/diet_medium_layout.dart';
import '../widgets/diet_delete_dialog.dart';
import '../widgets/diet_form_dialog.dart';
import '../widgets/health_error_banner.dart';

class DietRecommendationsPage extends StatelessWidget {
  const DietRecommendationsPage({
    super.key,
    required this.createBloc,
    required this.loadMembers,
    required this.loadEnumByName,
  });

  final DietRecommendationsBloc Function() createBloc;
  final Future<List<Member>> Function() loadMembers;
  final Future<List<EnumItem>> Function(String name) loadEnumByName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => createBloc()..add(const LoadDietRecommendationsRequested()),
      child: _DietRecommendationsPageContent(
        loadMembers: loadMembers,
        loadEnumByName: loadEnumByName,
      ),
    );
  }
}

class _DietRecommendationsPageContent extends StatefulWidget {
  const _DietRecommendationsPageContent({
    required this.loadMembers,
    required this.loadEnumByName,
  });

  final Future<List<Member>> Function() loadMembers;
  final Future<List<EnumItem>> Function(String name) loadEnumByName;

  @override
  State<_DietRecommendationsPageContent> createState() => _DietRecommendationsPageContentState();
}

class _DietRecommendationsPageContentState extends State<_DietRecommendationsPageContent> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  DietRecommendation? _selectedItem;
  bool _showCreateForm = false;
  PaginationInfo? _lastKnownPagination;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DietRecommendationsBloc, DietRecommendationsState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final l10n = context.l10n;
        final items = _getItemsFromState(state);
        final pagination = _getPaginationFromState(state);
        final isLoading = _isLoadingState(state);
        final sortedItems = _sortItems(items);
        final errorMessage = switch (state) {
          DietRecommendationsError(:final failure) => failure.debugMessage ?? l10n.dietRecommendationsErrorLoading,
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
                compact: DietCompactLayout(
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
                medium: DietMediumLayout(
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
                large: DietLargeLayout(
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
                  loadEnumByName: widget.loadEnumByName,
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

  PaginationInfo? _getPaginationFromState(DietRecommendationsState state) {
    return switch (state) {
      DietRecommendationsLoaded(:final pagination) => _lastKnownPagination = pagination,
      _ => _lastKnownPagination,
    };
  }

  List<DietRecommendation> _getItemsFromState(DietRecommendationsState state) {
    return switch (state) {
      DietRecommendationsLoaded(:final items) => items,
      DietRecommendationCreating(:final existingItems) => existingItems,
      DietRecommendationCreated(:final allItems) => allItems,
      DietRecommendationUpdating(:final existingItems) => existingItems,
      DietRecommendationUpdated(:final allItems) => allItems,
      DietRecommendationDeleting(:final existingItems) => existingItems,
      DietRecommendationDeleted(:final remainingItems) => remainingItems,
      _ => [],
    };
  }

  bool _isLoadingState(DietRecommendationsState state) {
    return switch (state) {
      DietRecommendationsInitial() || DietRecommendationsLoading() => true,
      DietRecommendationCreating() || DietRecommendationUpdating() || DietRecommendationDeleting() => true,
      _ => false,
    };
  }

  List<DietRecommendation> _sortItems(List<DietRecommendation> items) {
    final sorted = List<DietRecommendation>.from(items);
    sorted.sort((a, b) {
      int comparison;
      switch (_sortColumnIndex) {
        case 0:
          comparison = a.id.compareTo(b.id);
        case 1:
          comparison = a.bloodPressure.compareTo(b.bloodPressure);
        case 2:
          comparison = a.cholesterol.compareTo(b.cholesterol);
        case 3:
          comparison = a.glucose.compareTo(b.glucose);
        case 4:
          comparison = a.dailyCaloricIntake.compareTo(b.dailyCaloricIntake);
        case 5:
          comparison = a.adherenceToDietPlan.compareTo(b.adherenceToDietPlan);
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

  void _onItemSelected(DietRecommendation item) {
    setState(() {
      _selectedItem = item;
      _showCreateForm = false;
    });
  }

  void _onCloseDetails() {
    setState(() => _selectedItem = null);
  }

  void _onImportExport() {
    context.pushNamed(AppRoutes.dietRecommendationsImport);
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
    context.read<DietRecommendationsBloc>().add(const RefreshDietRecommendationsRequested());
  }

  void _handleStateChanges(BuildContext context, DietRecommendationsState state) {
    final l10n = context.l10n;

    switch (state) {
      case DietRecommendationCreated(:final item):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.dietSuccessCreated), behavior: SnackBarBehavior.floating));
        setState(() {
          _selectedItem = item;
          _showCreateForm = false;
        });
      case DietRecommendationUpdated(:final item):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.dietSuccessUpdated), behavior: SnackBarBehavior.floating));
        if (_selectedItem?.id == item.id) setState(() => _selectedItem = item);
      case DietRecommendationDeleted():
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.dietSuccessDeleted), behavior: SnackBarBehavior.floating));
        setState(() => _selectedItem = null);
      case DietRecommendationsError(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(failure.debugMessage ?? l10n.dietRecommendationsErrorLoading),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.colorScheme.error,
        ));
      default:
        break;
    }
  }

  Future<void> _showCreateDialog() async {
    final data = await DietFormDialog.show(
      context,
      loadMembers: widget.loadMembers,
      loadEnumByName: widget.loadEnumByName,
    );
    if (data != null && mounted) {
      context.read<DietRecommendationsBloc>().add(
        CreateDietRecommendationRequested(
          adherenceToDietPlan: data.adherenceToDietPlan,
          bloodPressure: data.bloodPressure,
          cholesterol: data.cholesterol,
          dailyCaloricIntake: data.dailyCaloricIntake,
          dietaryNutrientImbalanceScore: data.dietaryNutrientImbalanceScore,
          glucose: data.glucose,
          weeklyExerciseHours: data.weeklyExerciseHours,
          activity: data.activity,
          allergies: data.allergies.isEmpty ? null : data.allergies,
          dietaryRestrictions: data.dietaryRestrictions.isEmpty ? null : data.dietaryRestrictions,
          diseaseType: data.diseaseType,
          member: data.member,
          preferredCuisine: data.preferredCuisine,
          severity: data.severity,
        ),
      );
    }
  }

  Future<void> _showEditDialog(DietRecommendation item) async {
    final data = await DietFormDialog.show(
      context,
      item: item,
      loadMembers: widget.loadMembers,
      loadEnumByName: widget.loadEnumByName,
    );
    if (data != null && mounted) {
      context.read<DietRecommendationsBloc>().add(
        UpdateDietRecommendationRequested(
          id: item.id,
          adherenceToDietPlan: data.adherenceToDietPlan,
          bloodPressure: data.bloodPressure,
          cholesterol: data.cholesterol,
          dailyCaloricIntake: data.dailyCaloricIntake,
          dietaryNutrientImbalanceScore: data.dietaryNutrientImbalanceScore,
          glucose: data.glucose,
          weeklyExerciseHours: data.weeklyExerciseHours,
          activity: data.activity,
          diseaseType: data.diseaseType,
          member: data.member,
          preferredCuisine: data.preferredCuisine,
          severity: data.severity,
            allergies: data.allergies.isEmpty ? null : data.allergies,
            dietaryRestrictions: data.dietaryRestrictions.isEmpty ? null : data.dietaryRestrictions,
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(int itemId) async {
    final confirmed = await DietDeleteDialog.show(context);
    if (confirmed && mounted) {
      context.read<DietRecommendationsBloc>().add(DeleteDietRecommendationRequested(id: itemId));
    }
  }

  void _onNextPage() {
    context.read<DietRecommendationsBloc>().add(const DietRecommendationsNextPageRequested());
  }

  void _onPreviousPage() {
    context.read<DietRecommendationsBloc>().add(const DietRecommendationsPreviousPageRequested());
  }
}
