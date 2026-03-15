import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/nutrition_remote_data_source.dart';
import '../blocs/foods_bloc.dart';
import '../../../../core/extensions/l10n_extension.dart';

/// A panel widget for creating a new food inline (for large layouts).
// Un formulaire simple pour ajouter un aliment, version débutant
class FoodFormPanel extends StatefulWidget {
  const FoodFormPanel({super.key, required this.onCancel, required this.onSaved});
  final VoidCallback onCancel;
  final VoidCallback onSaved;
  @override
  State<FoodFormPanel> createState() => _FoodFormPanelState();
}

class _FoodFormPanelState extends State<FoodFormPanel> {
  final _formKey = GlobalKey<FormState>();
  // Un contrôleur par champ
  final _labelController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbohydratesController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarsController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _cholesterolController = TextEditingController();
  final _waterIntakeController = TextEditingController();

  // Futures pour récupérer les listes d'options
  late Future<List<String>> _categoryOptionsFuture;
  late Future<List<String>> _mealTypeOptionsFuture;
  String? _selectedCategory;
  String? _selectedMealType;

  @override
  void initState() {
    super.initState();
    final datasource = GetIt.I<NutritionRemoteDataSource>();
    _categoryOptionsFuture = datasource.getFoodCategories();
    _mealTypeOptionsFuture = datasource.getMealTypes();
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
      context.read<FoodsBloc>().add(
        CreateFoodRequested(
          label: _labelController.text,
          calories: int.tryParse(_caloriesController.text) ?? 0,
          protein: double.tryParse(_proteinController.text) ?? 0,
          carbohydrates: double.tryParse(_carbohydratesController.text) ?? 0,
          fat: double.tryParse(_fatController.text) ?? 0,
          fiber: double.tryParse(_fiberController.text) ?? 0,
          sugars: double.tryParse(_sugarsController.text) ?? 0,
          sodium: int.tryParse(_sodiumController.text) ?? 0,
          cholesterol: int.tryParse(_cholesterolController.text) ?? 0,
          waterIntake: int.tryParse(_waterIntakeController.text) ?? 0,
          category: _selectedCategory ?? '',
          mealType: _selectedMealType ?? '',
        ),
      );
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu_outlined, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  l10n.foodFormCreateTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _labelController,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormLabelLabel,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.foodFieldValidationRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _caloriesController,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormCaloriesLabel,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.foodFieldValidationRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _proteinController,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormProteinLabel,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.foodFieldValidationRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _carbohydratesController,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormCarbsLabel,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.foodFieldValidationRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fatController,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormFatLabel,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.foodFieldValidationRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fiberController,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormFiberLabel,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.foodFieldValidationRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sugarsController,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormSugarsLabel,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.foodFieldValidationRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sodiumController,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormSodiumLabel,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.foodFieldValidationRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cholesterolController,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormCholesterolLabel,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.foodFieldValidationRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _waterIntakeController,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormWaterIntakeLabel,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.foodFieldValidationRequired : null,
                    ),
                    const SizedBox(height: 24),
                    // Dropdown pour la catégorie
                    FutureBuilder<List<String>>(
                      future: _categoryOptionsFuture,
                      builder: (context, snapshot) {
                        final options = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: l10n.foodFormCategoryLabel,
                            border: OutlineInputBorder(),
                          ),
                          items: options
                              .map(
                                (value) =>
                                    DropdownMenuItem<String>(value: value, child: Text(value)),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value),
                          validator: (value) => value == null || value.isEmpty
                              ? l10n.foodFieldValidationRequired
                              : null,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Dropdown pour le type de repas
                    FutureBuilder<List<String>>(
                      future: _mealTypeOptionsFuture,
                      builder: (context, snapshot) {
                        final options = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedMealType,
                          decoration: InputDecoration(
                            labelText: l10n.foodFormMealTypeLabel,
                            border: OutlineInputBorder(),
                          ),
                          items: options
                              .map(
                                (value) =>
                                    DropdownMenuItem<String>(value: value, child: Text(value)),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _selectedMealType = value),
                          validator: (value) => value == null || value.isEmpty
                              ? l10n.foodFieldValidationRequired
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    child: Text(l10n.foodFormCancelButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _onSave,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l10n.foodFormCreateButton),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
