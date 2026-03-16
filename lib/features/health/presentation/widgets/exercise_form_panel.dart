import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../domain/entities/enum_item.dart';
import '../blocs/exercises_bloc.dart';

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

class ExerciseFormPanel extends StatefulWidget {
  const ExerciseFormPanel({
    super.key,
    required this.onCancel,
    required this.onSaved,
    required this.loadEnumByCandidates,
  });
  final VoidCallback onCancel;
  final VoidCallback onSaved;
  final Future<List<EnumItem>> Function(List<String> candidates)
      loadEnumByCandidates;

  @override
  State<ExerciseFormPanel> createState() => _ExerciseFormPanelState();
}

class _ExerciseFormPanelState extends State<ExerciseFormPanel> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();

  late final Future<_ExerciseOptions> _optionsFuture;

  int? _selectedCategory;
  final List<int> _selectedTargetMuscles = [];
  final List<int> _selectedBodyParts = [];
  final List<int> _selectedEquipments = [];
  final List<int> _selectedSecondaryMuscles = [];

  @override
  void initState() {
    super.initState();
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
      context.read<ExercisesBloc>().add(
        CreateExerciseRequested(
          imageUrl: _imageUrlController.text.trim(),
          category: _selectedCategory,
          targetMuscles: _selectedTargetMuscles.isEmpty ? null : _selectedTargetMuscles,
          bodyParts: _selectedBodyParts.isEmpty ? null : _selectedBodyParts,
          equipments: _selectedEquipments.isEmpty ? null : _selectedEquipments,
          secondaryMuscles: _selectedSecondaryMuscles.isEmpty ? null : _selectedSecondaryMuscles,
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
                const Icon(Icons.fitness_center, color: Colors.blue),
                const SizedBox(width: 12),
                Text(l10n.exerciseFormCreateTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close), onPressed: widget.onCancel),
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
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                          labelText: l10n.exerciseFormImageUrl,
                          border: const OutlineInputBorder()),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
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
                              decoration: InputDecoration(
                                  labelText:
                                      l10n.exerciseTableColumnCategory,
                                  border: const OutlineInputBorder()),
                              items: [
                                const DropdownMenuItem<int?>(
                                    value: null, child: Text('None')),
                                ...opts.categories.map((e) =>
                                    DropdownMenuItem<int?>(
                                        value: e.id,
                                        child: Text(e.value))),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedCategory = v),
                            ),
                            const SizedBox(height: 12),
                            _buildMultiSelect(l10n.exerciseTargetMuscles,
                                opts.muscles, _selectedTargetMuscles),
                            const SizedBox(height: 12),
                            _buildMultiSelect(l10n.exerciseBodyParts,
                                opts.bodyParts, _selectedBodyParts),
                            const SizedBox(height: 12),
                            _buildMultiSelect(
                                l10n.exerciseTableColumnEquipments,
                                opts.equipments,
                                _selectedEquipments),
                            const SizedBox(height: 12),
                            _buildMultiSelect(
                                l10n.exerciseTableColumnSecondary,
                                opts.muscles,
                                _selectedSecondaryMuscles),
                          ],
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
                        child: Text(l10n.exerciseFormCancelButton))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: _onSave,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(l10n.exerciseFormCreateButton))),
              ],
            ),
          ),
        ],
      ),
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
            ? const Text('No options available',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12))
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
