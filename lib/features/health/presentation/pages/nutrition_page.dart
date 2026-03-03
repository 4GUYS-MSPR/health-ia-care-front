import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/layouts/responsive_layout_builder.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../domain/entities/nutrition_food.dart';
import '../blocs/foods_bloc.dart';
import '../layouts/foods_compact_layout.dart';
import '../layouts/foods_large_layout.dart';
import '../layouts/foods_medium_layout.dart';
import '../widgets/food_delete_dialog.dart';
import '../widgets/food_form_dialog.dart';

/// Page displaying all foods with CRUD functionality.
class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<FoodsBloc>()..add(const LoadFoodsRequested()),
      child: const _NutritionPageContent(),
    );
  }
}

class _NutritionPageContent extends StatefulWidget {
  const _NutritionPageContent();

  @override
  State<_NutritionPageContent> createState() => _NutritionPageContentState();
}

class _NutritionPageContentState extends State<_NutritionPageContent> {
  // Sorting state
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // Selection state
  NutritionFood? _selectedFood;
  bool _showCreateForm = false;
  PaginationInfo? _lastKnownPagination;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodsBloc, FoodsState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final foods = _getFoodsFromState(state);
        final pagination = _getPaginationFromState(state);
        final isLoading = _isLoadingState(state);
        final sortedFoods = _sortFoods(foods);
    
        return ResponsiveLayoutBuilder(
          compact: FoodsCompactLayout(
            foods: sortedFoods,
            pagination: pagination,
            isLoading: isLoading,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSort: _onSort,
            onFoodSelected: _onFoodSelected,
            onFoodEdit: _showEditDialog,
            onFoodDelete: _showDeleteDialog,
            onAddFood: _showCreateDialog,
            onRefresh: _onRefresh,
            onNextPage: _onNextPage,
            onPreviousPage: _onPreviousPage,
          ),
          medium: FoodsMediumLayout(
            foods: sortedFoods,
            pagination: pagination,
            isLoading: isLoading,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSort: _onSort,
            onFoodSelected: _onFoodSelected,
            onFoodEdit: _showEditDialog,
            onFoodDelete: _showDeleteDialog,
            onAddFood: _showCreateDialog,
            onRefresh: _onRefresh,
            onNextPage: _onNextPage,
            onPreviousPage: _onPreviousPage,
          ),
          large: FoodsLargeLayout(
            foods: sortedFoods,
            pagination: pagination,
            selectedFood: _selectedFood,
            isLoading: isLoading,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            showCreateForm: _showCreateForm,
            onSort: _onSort,
            onFoodSelected: _onFoodSelected,
            onFoodEdit: _showEditDialog,
            onFoodDelete: _showDeleteDialog,
            onAddFood: _showCreateDialog,
            onRefresh: _onRefresh,
            onCloseDetails: _onCloseDetails,
            onToggleCreateForm: _onToggleCreateForm,
            onFoodCreated: _onFoodCreated,
            onNextPage: _onNextPage,
            onPreviousPage: _onPreviousPage,
          ),
        );
      },
    );
  }

  PaginationInfo? _getPaginationFromState(FoodsState state) {
    return switch (state) {
      FoodsLoaded(:final pagination) => _lastKnownPagination = pagination,
      _ => _lastKnownPagination,
    };
  }

  List<NutritionFood> _getFoodsFromState(FoodsState state) {
    return switch (state) {
      FoodsLoaded(:final foods) => foods,
      FoodCreating(:final existingFoods) => existingFoods,
      FoodCreated(:final allFoods) => allFoods,
      FoodUpdating(:final existingFoods) => existingFoods,
      FoodUpdated(:final allFoods) => allFoods,
      FoodDeleting(:final existingFoods) => existingFoods,
      FoodDeleted(:final remainingFoods) => remainingFoods,
      _ => [],
    };
  }

  bool _isLoadingState(FoodsState state) {
    return switch (state) {
      FoodsInitial() || FoodsLoading() => true,
      FoodCreating() || FoodUpdating() || FoodDeleting() => true,
      _ => false,
    };
  }

  List<NutritionFood> _sortFoods(List<NutritionFood> foods) {
    final sortedList = List<NutritionFood>.from(foods);

    sortedList.sort((a, b) {
      int comparison;

      switch (_sortColumnIndex) {
        case 0: // ID
          comparison = a.id.compareTo(b.id);
        case 1: // Label
          comparison = a.label.compareTo(b.label);
        case 2: // Calories
          comparison = a.calories.compareTo(b.calories);
        case 3: // Protein
          comparison = a.protein.compareTo(b.protein);
        case 4: // Carbs
          comparison = a.carbohydrates.compareTo(b.carbohydrates);
        case 5: // Fat
          comparison = a.fat.compareTo(b.fat);
        case 6: // Category
          comparison = a.category.compareTo(b.category);
        default:
          comparison = a.id.compareTo(b.id);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sortedList;
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _onFoodSelected(NutritionFood food) {
    setState(() {
      _selectedFood = food;
      _showCreateForm = false;
    });
  }

  void _onCloseDetails() {
    setState(() {
      _selectedFood = null;
    });
  }

  void _onToggleCreateForm() {
    setState(() {
      _showCreateForm = !_showCreateForm;
      if (_showCreateForm) {
        _selectedFood = null;
      }
    });
  }

  void _onFoodCreated() {
    setState(() {
      _showCreateForm = false;
    });
  }

  void _onRefresh() {
    context.read<FoodsBloc>().add(const RefreshFoodsRequested());
  }

  void _handleStateChanges(BuildContext context, FoodsState state) {
    final l10n = context.l10n;

    switch (state) {
      case FoodCreated(:final food):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.foodSuccessCreated),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Auto-select the newly created food on large layouts
        setState(() {
          _selectedFood = food;
          _showCreateForm = false;
        });
      case FoodUpdated(:final food):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.foodSuccessUpdated),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Update selected food if it was the one updated
        if (_selectedFood?.id == food.id) {
          setState(() {
            _selectedFood = food;
          });
        }
      case FoodDeleted():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.foodSuccessDeleted),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Clear selection if deleted food was selected
        setState(() {
          _selectedFood = null;
        });
      case FoodsError(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.debugMessage ?? l10n.foodsErrorLoading),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.colorScheme.error,
          ),
        );
      default:
        break;
    }
  }

  Future<void> _showCreateDialog() async {
    final data = await FoodFormDialog.show(context);
    if (data != null && mounted) {
      context.read<FoodsBloc>().add(
        CreateFoodRequested(
          label: data.label,
          calories: data.calories,
          protein: data.protein,
          carbohydrates: data.carbohydrates,
          fat: data.fat,
          fiber: data.fiber,
          sugars: data.sugars,
          sodium: data.sodium,
          cholesterol: data.cholesterol,
          waterIntake: data.waterIntake,
          category: data.category,
          mealType: data.mealType,
        ),
      );
    }
  }

  Future<void> _showEditDialog(NutritionFood food) async {
    final data = await FoodFormDialog.show(context, food: food);
    if (data != null && mounted) {
      context.read<FoodsBloc>().add(
        UpdateFoodRequested(
          id: food.id,
          label: data.label,
          calories: data.calories,
          protein: data.protein,
          carbohydrates: data.carbohydrates,
          fat: data.fat,
          fiber: data.fiber,
          sugars: data.sugars,
          sodium: data.sodium,
          cholesterol: data.cholesterol,
          waterIntake: data.waterIntake,
          category: data.category,
          mealType: data.mealType,
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(int foodId) async {
    final confirmed = await FoodDeleteDialog.show(context);
    if (confirmed && mounted) {
      context.read<FoodsBloc>().add(
        DeleteFoodRequested(id: foodId),
      );
    }
  }

  void _onNextPage() {
    context.read<FoodsBloc>().add(const NextPageRequested());
  }

  void _onPreviousPage() {
    context.read<FoodsBloc>().add(const PreviousPageRequested());
  }
}
