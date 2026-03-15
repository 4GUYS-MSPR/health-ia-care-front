import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/nutrition_remote_data_source.dart';
import '../../domain/entities/nutrition_food.dart';

/// Form data for creating/editing a food.
class FoodFormData {
  final String label;
  final int calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double sugars;
  final int sodium;
  final int cholesterol;
  final int waterIntake;
  final String category;
  final String mealType;

  const FoodFormData({
    required this.label,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.sugars,
    required this.sodium,
    required this.cholesterol,
    required this.waterIntake,
    required this.category,
    required this.mealType,
  });
}

/// Dialog for creating or editing a food.
class FoodFormDialog extends StatefulWidget {
  /// The food to edit, or null for creating a new food.
  final NutritionFood? food;

  const FoodFormDialog({super.key, this.food});

  /// Shows the dialog and returns the form data if saved, or null if cancelled.
  static Future<FoodFormData?> show(
    BuildContext context, {
    NutritionFood? food,
  }) {
    return showDialog<FoodFormData>(
      context: context,
      builder: (context) => FoodFormDialog(food: food),
    );
  }

  @override
  State<FoodFormDialog> createState() => _FoodFormDialogState();
}

class _FoodFormDialogState extends State<FoodFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbohydratesController;
  late final TextEditingController _fatController;
  late final TextEditingController _fiberController;
  late final TextEditingController _sugarsController;
  late final TextEditingController _sodiumController;
  late final TextEditingController _cholesterolController;
  late final TextEditingController _waterIntakeController;

  late final Future<List<String>> _categoryOptionsFuture;
  late final Future<List<String>> _mealTypeOptionsFuture;

  String? _selectedCategory;
  String? _selectedMealType;

  bool get _isEditing => widget.food != null;

  @override
  void initState() {
    super.initState();
    final food = widget.food;

    _labelController = TextEditingController(text: food?.label ?? '');
    _caloriesController = TextEditingController(text: food?.calories.toString() ?? '');
    _proteinController = TextEditingController(text: food?.protein.toString() ?? '');
    _carbohydratesController = TextEditingController(text: food?.carbohydrates.toString() ?? '');
    _fatController = TextEditingController(text: food?.fat.toString() ?? '');
    _fiberController = TextEditingController(text: food?.fiber.toString() ?? '');
    _sugarsController = TextEditingController(text: food?.sugars.toString() ?? '');
    _sodiumController = TextEditingController(text: food?.sodium.toString() ?? '');
    _cholesterolController = TextEditingController(text: food?.cholesterol.toString() ?? '');
    _waterIntakeController = TextEditingController(text: food?.waterIntake.toString() ?? '');

    _selectedCategory = food?.category;
    _selectedMealType = food?.mealType;

    final datasource = GetIt.I<NutritionRemoteDataSource>();
    _categoryOptionsFuture = _loadOptions(
      datasource.getFoodCategories,
      _selectedCategory,
    );
    _mealTypeOptionsFuture = _loadOptions(
      datasource.getMealTypes,
      _selectedMealType,
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbohydratesController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarsController.dispose();
    _sodiumController.dispose();
    _cholesterolController.dispose();
    _waterIntakeController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = FoodFormData(
        label: _labelController.text,
        calories: int.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbohydrates: double.parse(_carbohydratesController.text),
        fat: double.parse(_fatController.text),
        fiber: double.parse(_fiberController.text),
        sugars: double.parse(_sugarsController.text),
        sodium: int.parse(_sodiumController.text),
        cholesterol: int.parse(_cholesterolController.text),
        waterIntake: int.parse(_waterIntakeController.text),
        category: _selectedCategory!,
        mealType: _selectedMealType!,
      );
      Navigator.of(context).pop(data);
    }
  }

  Future<List<String>> _loadOptions(
    Future<List<String>> Function() loader,
    String? selected,
  ) async {
    final options = await loader();

    if (selected != null && selected.isNotEmpty && !options.contains(selected)) {
      return [selected, ...options];
    }

    return options;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing ? 'Edit Food' : 'Add Food',
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLabelField(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCaloriesField(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProteinField(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCarbohydratesField(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFatField(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFiberField(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSugarsField(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSodiumField(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCholesterolField(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildWaterIntakeField(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryField(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMealTypeField(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: Text(_isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Widget _buildLabelField() {
    return TextFormField(
      controller: _labelController,
      decoration: const InputDecoration(
        labelText: 'Label',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Label is required';
        }
        return null;
      },
    );
  }

  Widget _buildCaloriesField() {
    return TextFormField(
      controller: _caloriesController,
      decoration: const InputDecoration(
        labelText: 'Calories',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (int.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildProteinField() {
    return TextFormField(
      controller: _proteinController,
      decoration: const InputDecoration(
        labelText: 'Protein (g)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildCarbohydratesField() {
    return TextFormField(
      controller: _carbohydratesController,
      decoration: const InputDecoration(
        labelText: 'Carbs (g)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildFatField() {
    return TextFormField(
      controller: _fatController,
      decoration: const InputDecoration(
        labelText: 'Fat (g)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildFiberField() {
    return TextFormField(
      controller: _fiberController,
      decoration: const InputDecoration(
        labelText: 'Fiber (g)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildSugarsField() {
    return TextFormField(
      controller: _sugarsController,
      decoration: const InputDecoration(
        labelText: 'Sugars (g)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildSodiumField() {
    return TextFormField(
      controller: _sodiumController,
      decoration: const InputDecoration(
        labelText: 'Sodium (mg)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (int.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildCholesterolField() {
    return TextFormField(
      controller: _cholesterolController,
      decoration: const InputDecoration(
        labelText: 'Cholesterol (mg)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (int.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildWaterIntakeField() {
    return TextFormField(
      controller: _waterIntakeController,
      decoration: const InputDecoration(
        labelText: 'Water Intake (ml)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Water intake is required';
        }
        if (int.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  // Affiche la liste des catégories (plus débutant)
  Widget _buildCategoryField() {
    return FutureBuilder<List<String>>(
      future: _categoryOptionsFuture,
      builder: (context, asyncData) {
        // On récupère les options reçues
        final options = asyncData.data ?? <String>[];
        final currentValue = options.contains(_selectedCategory) ? _selectedCategory : null;
        // On affiche le menu déroulant
        return DropdownButtonFormField<String>(
          initialValue: currentValue,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: options
              .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
              .toList(),
          onChanged: asyncData.connectionState == ConnectionState.done
              ? (value) => setState(() => _selectedCategory = value)
              : null,
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        );
      },
    );
  }

  // Affiche la liste des types de repas (plus débutant)
  Widget _buildMealTypeField() {
    return FutureBuilder<List<String>>(
      future: _mealTypeOptionsFuture,
      builder: (context, asyncData) {
        final options = asyncData.data ?? <String>[];
        final currentValue = options.contains(_selectedMealType) ? _selectedMealType : null;
        return DropdownButtonFormField<String>(
          initialValue: currentValue,
          decoration: const InputDecoration(
            labelText: 'Meal Type',
            border: OutlineInputBorder(),
          ),
          items: options
              .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
              .toList(),
          onChanged: asyncData.connectionState == ConnectionState.done
              ? (value) => setState(() => _selectedMealType = value)
              : null,
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        );
      },
    );
  }
}
