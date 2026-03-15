import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/subscription.dart';
import '../bloc/members_bloc.dart';

/// A panel widget for creating a new member inline (for large layouts).
class MemberFormPanel extends StatefulWidget {
  const MemberFormPanel({
    super.key,
    required this.onCancel,
    required this.onSaved,
  });

  final VoidCallback onCancel;
  final VoidCallback onSaved;

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

  Gender _gender = Gender.unknow;
  Level _level = Level.beginner;
  Subscription _subscription = Subscription.free;
  List<Objective> _objectives = [];

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

  void _calculateBmi() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);
      _bmiController.text = bmi.toStringAsFixed(1);
    }
  }

  void _addObjective() {
    final text = _newObjectiveController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _objectives.add(
          Objective(description: text, createdAt: DateTime.now()),
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
      context.read<MembersBloc>().add(
        CreateMemberRequested(
          age: int.tryParse(_ageController.text),
          bmi: double.parse(_bmiController.text),
          fatPercentage: double.parse(_fatPercentageController.text),
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          workoutFrequency: int.parse(_workoutFrequencyController.text),
          objectives: _objectives,
          gender: _gender,
          level: _level,
          subscription: _subscription,
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
              child: DropdownButtonFormField<Gender>(
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
                  if (value != null) setState(() => _gender = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Level>(
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
                  if (value != null) setState(() => _level = value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<Subscription>(
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
                  if (value != null) setState(() => _subscription = value);
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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newObjectiveController,
                decoration: InputDecoration(
                  labelText: l10n.memberFormObjectivesLabel,
                  border: const OutlineInputBorder(),
                  hintText: l10n.memberFormObjectivesHint,
                ),
                onSubmitted: (_) => _addObjective(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addObjective,
              icon: const Icon(Icons.add),
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
