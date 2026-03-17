import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/food_import_row.dart';

/// Dialog for editing a single CSV row before import.
class FoodCsvRowEditDialog extends StatefulWidget {
  final FoodImportRow row;

  const FoodCsvRowEditDialog({super.key, required this.row});

  /// Shows the dialog and returns the updated [FoodCsvRow], or null if cancelled.
  static Future<FoodImportRow?> show(BuildContext context, FoodImportRow row) {
    return showDialog<FoodImportRow>(
      context: context,
      builder: (context) => FoodCsvRowEditDialog(row: row),
    );
  }

  @override
  State<FoodCsvRowEditDialog> createState() => _FoodCsvRowEditDialogState();
}

class _FoodCsvRowEditDialogState extends State<FoodCsvRowEditDialog> {
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
  late final TextEditingController _categoryController;
  late final TextEditingController _mealTypeController;

  @override
  void initState() {
    super.initState();
    final r = widget.row;
    _labelController = TextEditingController(text: r.label);
    _caloriesController = TextEditingController(text: r.calories.toString());
    _proteinController = TextEditingController(text: r.protein.toString());
    _carbohydratesController = TextEditingController(text: r.carbohydrates.toString());
    _fatController = TextEditingController(text: r.fat.toString());
    _fiberController = TextEditingController(text: r.fiber.toString());
    _sugarsController = TextEditingController(text: r.sugars.toString());
    _sodiumController = TextEditingController(text: r.sodium.toString());
    _cholesterolController = TextEditingController(text: r.cholesterol.toString());
    _waterIntakeController = TextEditingController(text: r.waterIntake.toString());
    _categoryController = TextEditingController(text: r.category);
    _mealTypeController = TextEditingController(text: r.mealType);
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
    _categoryController.dispose();
    _mealTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errors = widget.row.errors;

    return AlertDialog(
      title: Text('Edit Row #${widget.row.index}'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errors.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${errors.length} error(s) to fix:',
                          style: TextStyle(
                            color: context.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...errors.entries.map(
                          (e) => Text(
                            '• ${e.key}: ${e.value}',
                            style: TextStyle(color: context.colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildTextField(
                  controller: _labelController,
                  label: 'Label',
                  hasError: errors.containsKey('label'),
                  errorText: errors['label'],
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildIntField(
                        controller: _caloriesController,
                        label: 'Calories',
                        hasError: errors.containsKey('calories'),
                        errorText: errors['calories'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDoubleField(
                        controller: _proteinController,
                        label: 'Protein',
                        hasError: errors.containsKey('protein'),
                        errorText: errors['protein'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDoubleField(
                        controller: _carbohydratesController,
                        label: 'Carbohydrates',
                        hasError: errors.containsKey('carbohydrates'),
                        errorText: errors['carbohydrates'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDoubleField(
                        controller: _fatController,
                        label: 'Fat',
                        hasError: errors.containsKey('fat'),
                        errorText: errors['fat'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDoubleField(
                        controller: _fiberController,
                        label: 'Fiber',
                        hasError: errors.containsKey('fiber'),
                        errorText: errors['fiber'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDoubleField(
                        controller: _sugarsController,
                        label: 'Sugars',
                        hasError: errors.containsKey('sugars'),
                        errorText: errors['sugars'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildIntField(
                        controller: _sodiumController,
                        label: 'Sodium',
                        hasError: errors.containsKey('sodium'),
                        errorText: errors['sodium'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildIntField(
                        controller: _cholesterolController,
                        label: 'Cholesterol',
                        hasError: errors.containsKey('cholesterol'),
                        errorText: errors['cholesterol'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildIntField(
                  controller: _waterIntakeController,
                  label: 'Water Intake',
                  hasError: errors.containsKey('water_intake'),
                  errorText: errors['water_intake'],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _categoryController,
                        label: 'Category',
                        hasError: errors.containsKey('category'),
                        errorText: errors['category'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _mealTypeController,
                        label: 'Meal Type',
                        hasError: errors.containsKey('meal_type'),
                        errorText: errors['meal_type'],
                      ),
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
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.row.copyWith(
      label: _labelController.text.trim(),
      calories: int.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0.0,
      carbohydrates: double.tryParse(_carbohydratesController.text) ?? 0.0,
      fat: double.tryParse(_fatController.text) ?? 0.0,
      fiber: double.tryParse(_fiberController.text) ?? 0.0,
      sugars: double.tryParse(_sugarsController.text) ?? 0.0,
      sodium: int.tryParse(_sodiumController.text) ?? 0,
      cholesterol: int.tryParse(_cholesterolController.text) ?? 0,
      waterIntake: int.tryParse(_waterIntakeController.text) ?? 0,
      category: _categoryController.text.trim(),
      mealType: _mealTypeController.text.trim(),
      errors: const {}, // Clear errors, will be re-validated by bloc
    );

    Navigator.of(context).pop(updated);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool hasError = false,
    String? errorText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: hasError ? errorText : null,
      ),
      validator: validator,
    );
  }

  Widget _buildIntField({
    required TextEditingController controller,
    required String label,
    bool hasError = false,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: hasError ? errorText : null,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (int.tryParse(v) == null) return 'Must be an integer';
        if (int.parse(v) < 0) return 'Must be ≥ 0';
        return null;
      },
    );
  }

  Widget _buildDoubleField({
    required TextEditingController controller,
    required String label,
    bool hasError = false,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: hasError ? errorText : null,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (double.tryParse(v) == null) return 'Must be a number';
        if (double.parse(v) < 0) return 'Must be ≥ 0';
        return null;
      },
    );
  }
}
