import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../data/models/enum_item_model.dart';
import '../../domain/entities/objective.dart';
import '../bloc/members_bloc.dart';

/// A panel widget for creating a new member inline (for large layouts).
class MemberFormPanel extends StatefulWidget {
  const MemberFormPanel({
    super.key,
    required this.onCancel,
    required this.onSaved,
    required this.objectiveOptionsFuture,
    required this.genderOptionsFuture,
    required this.levelOptionsFuture,
    required this.subscriptionOptionsFuture,
  });

  final VoidCallback onCancel;
  final VoidCallback onSaved;
  final Future<List<Objective>> objectiveOptionsFuture;
  final Future<List<EnumItemModel>> genderOptionsFuture;
  final Future<List<EnumItemModel>> levelOptionsFuture;
  final Future<List<EnumItemModel>> subscriptionOptionsFuture;

  @override
  State<MemberFormPanel> createState() => _MemberFormPanelState();
}

class _MemberFormPanelState extends State<MemberFormPanel> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _bmiController;
  late final TextEditingController _fatPercentageController;
  late final TextEditingController _workoutFrequencyController;
  late final TextEditingController _newObjectiveController;
  late final Future<List<Objective>> _objectiveOptionsFuture;
  late final Future<List<EnumItemModel>> _genderOptionsFuture;
  late final Future<List<EnumItemModel>> _levelOptionsFuture;
  late final Future<List<EnumItemModel>> _subscriptionOptionsFuture;

  int? _genderId;
  int? _levelId;
  int? _subscriptionId;
  final List<Objective> _objectives = [];
  final List<Objective> _createdObjectiveOptions = [];
  bool _isCreatingObjective = false;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _bmiController = TextEditingController();
    _fatPercentageController = TextEditingController();
    _workoutFrequencyController = TextEditingController(text: '0');
    _newObjectiveController = TextEditingController();
    _objectiveOptionsFuture = widget.objectiveOptionsFuture;
    _genderOptionsFuture = widget.genderOptionsFuture;
    _levelOptionsFuture = widget.levelOptionsFuture;
    _subscriptionOptionsFuture = widget.subscriptionOptionsFuture;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _fatPercentageController.dispose();
    _workoutFrequencyController.dispose();
    _newObjectiveController.dispose();
    super.dispose();
  }

  bool _sameObjective(Objective a, Objective b) {
    if (a.id != null && b.id != null) return a.id == b.id;
    return a.description.trim().toLowerCase() == b.description.trim().toLowerCase();
  }

  Future<void> _addObjective() async {
    final description = _newObjectiveController.text.trim();
    if (description.isEmpty || _isCreatingObjective) return;

    final alreadyExists = [
      ..._objectives,
      ..._createdObjectiveOptions,
    ].any((o) => o.description.trim().toLowerCase() == description.toLowerCase());
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objective already selected')),
      );
      return;
    }

    setState(() => _isCreatingObjective = true);
    final created = Objective(
      id: null,
      description: description,
      createdAt: DateTime.now(),
    );

    setState(() {
      if (!_createdObjectiveOptions.any((o) => _sameObjective(o, created))) {
        _createdObjectiveOptions.add(created);
      }
      if (!_objectives.any((o) => _sameObjective(o, created))) {
        _objectives.add(created);
      }
      _newObjectiveController.clear();
      _isCreatingObjective = false;
    });
  }

  void _calculateBmi() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);
      _bmiController.text = bmi.toStringAsFixed(1);
    }
  }

  void _removeObjective(int index) {
    setState(() {
      _objectives.removeAt(index);
    });
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MembersBloc>().add(
        CreateMemberRequested(
          age: int.tryParse(_ageController.text),
          bmi: double.parse(_bmiController.text),
          fatPercentage: double.parse(_fatPercentageController.text),
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          workoutFrequency: int.parse(_workoutFrequencyController.text),
          objectives: _objectives,
          genderId: _genderId,
          levelId: _levelId,
          subscriptionId: _subscriptionId,
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
          _buildHeader(context, l10n),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(context, l10n),
                    const SizedBox(height: 24),
                    _buildMetricsSection(context, l10n),
                    const SizedBox(height: 24),
                    _buildObjectivesSection(context, l10n),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          _buildActions(context, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            Icons.person_add_outlined,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            l10n.memberFormCreateTitle,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onCancel,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memberDetailsProfile,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: l10n.memberFormAgeLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FutureBuilder<List<EnumItemModel>>(
                future: _genderOptionsFuture,
                builder: (context, snapshot) {
                  final options = snapshot.data ?? const [];
                  return DropdownButtonFormField<int>(
                    initialValue: _genderId,
                    decoration: InputDecoration(
                      labelText: l10n.memberFormGenderLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: options
                        .map((e) => DropdownMenuItem(value: e.id, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) => setState(() => _genderId = value),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FutureBuilder<List<EnumItemModel>>(
                future: _levelOptionsFuture,
                builder: (context, snapshot) {
                  final options = snapshot.data ?? const [];
                  return DropdownButtonFormField<int>(
                    initialValue: _levelId,
                    decoration: InputDecoration(
                      labelText: l10n.memberFormLevelLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: options
                        .map((e) => DropdownMenuItem(value: e.id, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) => setState(() => _levelId = value),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FutureBuilder<List<EnumItemModel>>(
                future: _subscriptionOptionsFuture,
                builder: (context, snapshot) {
                  final options = snapshot.data ?? const [];
                  return DropdownButtonFormField<int>(
                    initialValue: _subscriptionId,
                    decoration: InputDecoration(
                      labelText: l10n.memberFormSubscriptionLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: options
                        .map((e) => DropdownMenuItem(value: e.id, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) => setState(() => _subscriptionId = value),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memberDetailsMetrics,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: l10n.memberFormHeightLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.memberFormHeightError;
                  }
                  return null;
                },
                onChanged: (_) => _calculateBmi(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: l10n.memberFormWeightLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.memberFormWeightError;
                  }
                  return null;
                },
                onChanged: (_) => _calculateBmi(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bmiController,
                decoration: InputDecoration(
                  labelText: l10n.memberFormBmiLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'BMI is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _fatPercentageController,
                decoration: InputDecoration(
                  labelText: l10n.memberFormFatPercentageLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Fat percentage is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _workoutFrequencyController,
          decoration: InputDecoration(
            labelText: l10n.memberFormWorkoutFrequencyLabel,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Workout frequency is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildObjectivesSection(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memberCardObjectives,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Objective>>(
          future: _objectiveOptionsFuture,
          builder: (context, snapshot) {
            final options = snapshot.data ?? const <Objective>[];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [...options, ..._createdObjectiveOptions].map((option) {
                final selected = _objectives.any((o) => _sameObjective(o, option));
                return FilterChip(
                  selected: selected,
                  label: Text(option.description),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        if (!_objectives.any((o) => _sameObjective(o, option))) {
                          _objectives.add(option);
                        }
                      } else {
                        _objectives.removeWhere((o) => _sameObjective(o, option));
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newObjectiveController,
                decoration: const InputDecoration(
                  labelText: 'New objective',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addObjective(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _isCreatingObjective ? null : _addObjective,
              icon: _isCreatingObjective
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        if (_objectives.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _objectives.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value.description),
                onDeleted: () => _removeObjective(entry.key),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onCancel,
              child: Text(l10n.memberFormCancelButton),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: _onSave,
              icon: const Icon(Icons.save_outlined),
              label: Text(l10n.memberFormCreateButton),
            ),
          ),
        ],
      ),
    );
  }
}
