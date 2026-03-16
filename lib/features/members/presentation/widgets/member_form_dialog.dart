import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../data/models/enum_item_model.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/objective.dart';

/// Form data for creating/editing a member.
class MemberFormData {
  final int? age;
  final double bmi;
  final double fatPercentage;
  final double height;
  final double weight;
  final int workoutFrequency;
  final List<Objective> objectives;
  final int? genderId;
  final int? levelId;
  final int? subscriptionId;

  const MemberFormData({
    this.age,
    required this.bmi,
    required this.fatPercentage,
    required this.height,
    required this.weight,
    required this.workoutFrequency,
    this.objectives = const [],
    this.genderId,
    this.levelId,
    this.subscriptionId,
  });
}

/// Dialog for creating or editing a member.
class MemberFormDialog extends StatefulWidget {
  /// The member to edit, or null for creating a new member.
  final Member? member;
  final Future<List<Objective>> objectiveOptionsFuture;
  final Future<List<EnumItemModel>> genderOptionsFuture;
  final Future<List<EnumItemModel>> levelOptionsFuture;
  final Future<List<EnumItemModel>> subscriptionOptionsFuture;

  const MemberFormDialog({
    super.key,
    this.member,
    required this.objectiveOptionsFuture,
    required this.genderOptionsFuture,
    required this.levelOptionsFuture,
    required this.subscriptionOptionsFuture,
  });

  /// Shows the dialog and returns the form data if saved, or null if cancelled.
  static Future<MemberFormData?> show(
    BuildContext context, {
    Member? member,
    required Future<List<Objective>> objectiveOptionsFuture,
    required Future<List<EnumItemModel>> genderOptionsFuture,
    required Future<List<EnumItemModel>> levelOptionsFuture,
    required Future<List<EnumItemModel>> subscriptionOptionsFuture,
  }) {
    return showDialog<MemberFormData>(
      context: context,
      builder: (context) => MemberFormDialog(
        member: member,
        objectiveOptionsFuture: objectiveOptionsFuture,
        genderOptionsFuture: genderOptionsFuture,
        levelOptionsFuture: levelOptionsFuture,
        subscriptionOptionsFuture: subscriptionOptionsFuture,
      ),
    );
  }

  @override
  State<MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _bmiController;
  late final TextEditingController _fatPercentageController;
  late final TextEditingController _workoutFrequencyController;
  late final Future<List<Objective>> _objectiveOptionsFuture;
  late final Future<List<EnumItemModel>> _genderOptionsFuture;
  late final Future<List<EnumItemModel>> _levelOptionsFuture;
  late final Future<List<EnumItemModel>> _subscriptionOptionsFuture;

  late int? _genderId;
  late int? _levelId;
  late int? _subscriptionId;
  late List<Objective> _objectives;

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;

    _ageController = TextEditingController(
      text: member?.age?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: member?.height.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: member?.weight.toString() ?? '',
    );
    _bmiController = TextEditingController(
      text: member?.bmi.toString() ?? '',
    );
    _fatPercentageController = TextEditingController(
      text: member?.fatPercentage.toString() ?? '',
    );
    _workoutFrequencyController = TextEditingController(
      text: member?.workoutFrequency.toString() ?? '0',
    );

    _genderId = member?.genderId;
    _levelId = member?.levelId;
    _subscriptionId = member?.subscriptionId;
    _objectives = List.from(member?.objectives ?? []);
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
    super.dispose();
  }

  void _removeObjective(int index) {
    setState(() {
      _objectives.removeAt(index);
    });
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = MemberFormData(
        age: int.tryParse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        bmi: double.parse(_bmiController.text),
        fatPercentage: double.parse(_fatPercentageController.text),
        workoutFrequency: int.parse(_workoutFrequencyController.text),
        objectives: _objectives,
        genderId: _genderId,
        levelId: _levelId,
        subscriptionId: _subscriptionId,
      );
      Navigator.of(context).pop(data);
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(
        _isEditing ? l10n.memberFormEditTitle : l10n.memberFormCreateTitle,
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildAgeField(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGenderDropdown(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildHeightField(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildWeightField(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildBmiField(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFatPercentageField(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildWorkoutFrequencyField(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildLevelDropdown(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSubscriptionDropdown(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildObjectivesField(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.memberFormCancelButton),
        ),
        FilledButton(
          onPressed: _onSave,
          child: Text(
            _isEditing ? l10n.memberFormSaveButton : l10n.memberFormCreateButton,
          ),
        ),
      ],
    );
  }

  Widget _buildAgeField() {
    final l10n = context.l10n;

    return TextFormField(
      controller: _ageController,
      decoration: InputDecoration(
        labelText: l10n.memberFormAgeLabel,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildHeightField() {
    final l10n = context.l10n;

    return TextFormField(
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
        final height = double.tryParse(value);
        if (height == null || height <= 0) {
          return l10n.memberFormHeightError;
        }
        return null;
      },
      onChanged: (_) => _calculateBmi(),
    );
  }

  Widget _buildWeightField() {
    final l10n = context.l10n;

    return TextFormField(
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
        final weight = double.tryParse(value);
        if (weight == null || weight <= 0) {
          return l10n.memberFormWeightError;
        }
        return null;
      },
      onChanged: (_) => _calculateBmi(),
    );
  }

  Widget _buildBmiField() {
    final l10n = context.l10n;

    return TextFormField(
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
    );
  }

  Widget _buildFatPercentageField() {
    final l10n = context.l10n;

    return TextFormField(
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
    );
  }

  Widget _buildWorkoutFrequencyField() {
    final l10n = context.l10n;

    return TextFormField(
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
    );
  }

  Widget _buildObjectivesField() {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memberFormObjectivesLabel,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
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
              children: options.map((option) {
                final selected = _objectives.any((o) => o.id == option.id);
                return FilterChip(
                  selected: selected,
                  label: Text(option.description),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _objectives.add(option);
                      } else {
                        _objectives.removeWhere((o) => o.id == option.id);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        if (_objectives.isNotEmpty) ...[
          const SizedBox(height: 8),
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

  Widget _buildGenderDropdown() {
    final l10n = context.l10n;

    return FutureBuilder<List<EnumItemModel>>(
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
    );
  }

  Widget _buildLevelDropdown() {
    final l10n = context.l10n;

    return FutureBuilder<List<EnumItemModel>>(
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
    );
  }

  Widget _buildSubscriptionDropdown() {
    final l10n = context.l10n;

    return FutureBuilder<List<EnumItemModel>>(
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
    );
  }
}
