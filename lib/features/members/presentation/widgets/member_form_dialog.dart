import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/subscription.dart';

/// Form data for creating/editing a member.
class MemberFormData {
  final int? age;
  final double bmi;
  final double fatPercentage;
  final double height;
  final double weight;
  final int workoutFrequency;
  final List<Objective> objectives;
  final Gender gender;
  final Level level;
  final Subscription subscription;

  const MemberFormData({
    this.age,
    required this.bmi,
    required this.fatPercentage,
    required this.height,
    required this.weight,
    required this.workoutFrequency,
    this.objectives = const [],
    required this.gender,
    required this.level,
    required this.subscription,
  });
}

/// Dialog for creating or editing a member.
class MemberFormDialog extends StatefulWidget {
  /// The member to edit, or null for creating a new member.
  final Member? member;

  const MemberFormDialog({super.key, this.member});

  /// Shows the dialog and returns the form data if saved, or null if cancelled.
  static Future<MemberFormData?> show(
    BuildContext context, {
    Member? member,
  }) {
    return showDialog<MemberFormData>(
      context: context,
      builder: (context) => MemberFormDialog(member: member),
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
  late final TextEditingController _newObjectiveController;

  late Gender _gender;
  late Level _level;
  late Subscription _subscription;
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
    _newObjectiveController = TextEditingController();

    _gender = member?.gender ?? Gender.unknow;
    _level = member?.level ?? Level.beginner;
    _subscription = member?.subscription ?? Subscription.free;
    _objectives = List.from(member?.objectives ?? []);
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

  void _addObjective() {
    final text = _newObjectiveController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _objectives.add(
          Objective(
            description: text,
            createdAt: DateTime.now(),
          ),
        );
        _newObjectiveController.clear();
      });
    }
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
        gender: _gender,
        level: _level,
        subscription: _subscription,
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
        if (_objectives.isNotEmpty) ...[
          ...List.generate(_objectives.length, (index) {
            final objective = _objectives[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                title: Text(objective.description),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeObjective(index),
                ),
              ),
            );
          }),
        ],
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _newObjectiveController,
                decoration: InputDecoration(
                  hintText: l10n.memberFormObjectivesLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addObjective,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    final l10n = context.l10n;

    return DropdownButtonFormField<Gender>(
      value: _gender,
      decoration: InputDecoration(
        labelText: l10n.memberFormGenderLabel,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: Gender.male,
          child: Text(l10n.memberGenderMale),
        ),
        DropdownMenuItem(
          value: Gender.female,
          child: Text(l10n.memberGenderFemale),
        ),
        DropdownMenuItem(
          value: Gender.unknow,
          child: Text(l10n.memberGenderUnknown),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _gender = value);
        }
      },
    );
  }

  Widget _buildLevelDropdown() {
    final l10n = context.l10n;

    return DropdownButtonFormField<Level>(
      value: _level,
      decoration: InputDecoration(
        labelText: l10n.memberFormLevelLabel,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: Level.beginner,
          child: Text(l10n.memberLevelBeginner),
        ),
        DropdownMenuItem(
          value: Level.intermediate,
          child: Text(l10n.memberLevelIntermediate),
        ),
        DropdownMenuItem(
          value: Level.expert,
          child: Text(l10n.memberLevelExpert),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _level = value);
        }
      },
    );
  }

  Widget _buildSubscriptionDropdown() {
    final l10n = context.l10n;

    return DropdownButtonFormField<Subscription>(
      value: _subscription,
      decoration: InputDecoration(
        labelText: l10n.memberFormSubscriptionLabel,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: Subscription.free,
          child: Text(l10n.memberSubscriptionFree),
        ),
        DropdownMenuItem(
          value: Subscription.premium,
          child: Text(l10n.memberSubscriptionPremium),
        ),
        DropdownMenuItem(
          value: Subscription.premiumPlus,
          child: Text(l10n.memberSubscriptionPremiumPlus),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _subscription = value);
        }
      },
    );
  }
}
