import 'package:flutter/material.dart';

import '../../domain/entities/enum_item.dart';
import '../../domain/entities/exercise.dart';

class ExerciseFormData {
  final String imageUrl;
  final int? category;
  final List<int>? bodyParts;
  final List<int>? equipments;
  final List<int>? secondaryMuscles;
  final List<int>? targetMuscles;

  const ExerciseFormData({
    required this.imageUrl,
    this.category,
    this.bodyParts,
    this.equipments,
    this.secondaryMuscles,
    this.targetMuscles,
  });
}

class _ExerciseOptions {
  final List<EnumItem> categories;
  final List<EnumItem> bodyParts;
  final List<EnumItem> equipments;
  final List<EnumItem> muscles;

  const _ExerciseOptions({
    required this.categories,
    required this.bodyParts,
    required this.equipments,
    required this.muscles,
  });
}

class ExerciseFormDialog extends StatefulWidget {
  final Exercise? item;
  final Future<List<EnumItem>> Function(List<String> candidates)
      loadEnumByCandidates;

  const ExerciseFormDialog({
    super.key,
    this.item,
    required this.loadEnumByCandidates,
  });

  static Future<ExerciseFormData?> show(
    BuildContext context, {
    Exercise? item,
    required Future<List<EnumItem>> Function(List<String> candidates)
        loadEnumByCandidates,
  }) {
    return showDialog<ExerciseFormData>(
      context: context,
      builder: (context) => ExerciseFormDialog(
        item: item,
        loadEnumByCandidates: loadEnumByCandidates,
      ),
    );
  }

  @override
  State<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<ExerciseFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _imageUrlController;
  late final Future<_ExerciseOptions> _optionsFuture;

  int? _selectedCategory;
  late List<int> _selectedBodyParts;
  late List<int> _selectedEquipments;
  late List<int> _selectedSecondaryMuscles;
  late List<int> _selectedTargetMuscles;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _imageUrlController = TextEditingController(text: item?.imageUrl ?? '');
    _selectedCategory = item?.category;
    _selectedBodyParts = List.from(item?.bodyParts ?? []);
    _selectedEquipments = List.from(item?.equipments ?? []);
    _selectedSecondaryMuscles = List.from(item?.secondaryMuscles ?? []);
    _selectedTargetMuscles = List.from(item?.targetMuscles ?? []);

    _optionsFuture = Future.wait([
      widget.loadEnumByCandidates(
          const ['ExerciseCategory', 'Category', 'ExerciceCategory']),
      widget.loadEnumByCandidates(
          const ['BodyPart', 'BodyParts', 'ExerciceBodyPart']),
      widget.loadEnumByCandidates(
          const ['Equipment', 'Equipement', 'Equipments']),
      widget.loadEnumByCandidates(
          const ['Muscle', 'TargetMuscle', 'SecondaryMuscle']),
    ]).then(
      (results) => _ExerciseOptions(
        categories: results[0],
        bodyParts: results[1],
        equipments: results[2],
        muscles: results[3],
      ),
    );
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(ExerciseFormData(
        imageUrl: _imageUrlController.text.trim(),
        category: _selectedCategory,
        bodyParts: _selectedBodyParts.isEmpty ? null : _selectedBodyParts,
        equipments: _selectedEquipments.isEmpty ? null : _selectedEquipments,
        secondaryMuscles:
            _selectedSecondaryMuscles.isEmpty ? null : _selectedSecondaryMuscles,
        targetMuscles:
            _selectedTargetMuscles.isEmpty ? null : _selectedTargetMuscles,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Exercise' : 'Add Exercise'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<_ExerciseOptions>(
                  future: _optionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Failed to load options',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final opts = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int?>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('None'),
                            ),
                            ...opts.categories.map(
                              (e) => DropdownMenuItem<int?>(
                                value: e.id,
                                child: Text(e.value),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v),
                        ),
                        const SizedBox(height: 16),
                        _buildMultiSelect(
                          'Target Muscles',
                          opts.muscles,
                          _selectedTargetMuscles,
                        ),
                        const SizedBox(height: 16),
                        _buildMultiSelect(
                          'Body Parts',
                          opts.bodyParts,
                          _selectedBodyParts,
                        ),
                        const SizedBox(height: 16),
                        _buildMultiSelect(
                          'Equipments',
                          opts.equipments,
                          _selectedEquipments,
                        ),
                        const SizedBox(height: 16),
                        _buildMultiSelect(
                          'Secondary Muscles',
                          opts.muscles,
                          _selectedSecondaryMuscles,
                        ),
                      ],
                    );
                  },
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

  Widget _buildMultiSelect(
      String label, List<EnumItem> options, List<int> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        options.isEmpty
            ? const Text(
                'No options available',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              )
            : Wrap(
                spacing: 6,
                runSpacing: 4,
                children: options.map((e) {
                  final isSelected = selected.contains(e.id);
                  return FilterChip(
                    label: Text(e.value),
                    selected: isSelected,
                    onSelected: (v) => setState(() {
                      if (v) {
                        selected.add(e.id);
                      } else {
                        selected.remove(e.id);
                      }
                    }),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
