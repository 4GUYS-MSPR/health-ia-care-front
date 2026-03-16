import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../features/members/domain/entities/member.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_session.dart';

class SessionFormData {
  final double caloriesBurned;
  final String duration;
  final int avgBpm;
  final int maxBpm;
  final int restingBpm;
  final double waterIntake;
  final int member;
  final List<int>? exercices;

  const SessionFormData({
    required this.caloriesBurned,
    required this.duration,
    required this.avgBpm,
    required this.maxBpm,
    required this.restingBpm,
    required this.waterIntake,
    required this.member,
    this.exercices,
  });
}

class _SessionOptions {
  final List<Member> members;
  final List<Exercise> exercises;

  const _SessionOptions({required this.members, required this.exercises});
}

class SessionFormDialog extends StatefulWidget {
  final WorkoutSession? item;
  final Future<List<Member>> Function() loadMembers;
  final Future<List<Exercise>> Function() loadExercises;

  const SessionFormDialog({
    super.key,
    this.item,
    required this.loadMembers,
    required this.loadExercises,
  });

  static Future<SessionFormData?> show(BuildContext context,
      {WorkoutSession? item,
      required Future<List<Member>> Function() loadMembers,
      required Future<List<Exercise>> Function() loadExercises}) {
    return showDialog<SessionFormData>(
      context: context,
      builder: (context) => SessionFormDialog(
        item: item,
        loadMembers: loadMembers,
        loadExercises: loadExercises,
      ),
    );
  }

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _caloriesController;
  late final TextEditingController _durationController;
  late final TextEditingController _avgBpmController;
  late final TextEditingController _maxBpmController;
  late final TextEditingController _restingBpmController;
  late final TextEditingController _waterIntakeController;
  late final Future<_SessionOptions> _optionsFuture;

  int? _selectedMember;
  late List<int> _selectedExercices;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _caloriesController =
        TextEditingController(text: item?.caloriesBurned.toString() ?? '');
    _durationController =
        TextEditingController(text: item?.duration ?? '');
    _avgBpmController =
        TextEditingController(text: item?.avgBpm.toString() ?? '');
    _maxBpmController =
        TextEditingController(text: item?.maxBpm.toString() ?? '');
    _restingBpmController =
        TextEditingController(text: item?.restingBpm.toString() ?? '');
    _waterIntakeController =
        TextEditingController(text: item?.waterIntake.toString() ?? '');
    _selectedMember = item?.member;
    _selectedExercices = List.from(item?.exercices ?? []);

    _optionsFuture = Future.wait([
      widget.loadMembers(),
      widget.loadExercises(),
    ]).then(
      (results) => _SessionOptions(
        members: (results[0] as List).cast<Member>(),
        exercises: (results[1] as List).cast<Exercise>(),
      ),
    );
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _durationController.dispose();
    _avgBpmController.dispose();
    _maxBpmController.dispose();
    _restingBpmController.dispose();
    _waterIntakeController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(SessionFormData(
        caloriesBurned: double.parse(_caloriesController.text),
        duration: _durationController.text,
        avgBpm: int.parse(_avgBpmController.text),
        maxBpm: int.parse(_maxBpmController.text),
        restingBpm: int.parse(_restingBpmController.text),
        waterIntake: double.parse(_waterIntakeController.text),
        member: _selectedMember!,
        exercices: _selectedExercices.isEmpty ? null : _selectedExercices,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Session' : 'Add Session'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: _buildDoubleField(
                          _caloriesController, 'Calories Burned')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          _durationController, 'Duration (HH:MM:SS)')),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: _buildIntField(_avgBpmController, 'Avg BPM')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildIntField(_maxBpmController, 'Max BPM')),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child:
                          _buildIntField(_restingBpmController, 'Resting BPM')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildDoubleField(
                          _waterIntakeController, 'Water Intake (L)')),
                ]),
                const SizedBox(height: 16),
                FutureBuilder<_SessionOptions>(
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
                        DropdownButtonFormField<int>(
                          initialValue: _selectedMember,
                          decoration: const InputDecoration(
                            labelText: 'Member',
                            border: OutlineInputBorder(),
                          ),
                          items: opts.members
                              .map((m) => DropdownMenuItem<int>(
                                    value: m.id,
                                    child: Text(
                                        'Member #${m.id}${m.age != null ? ' (${m.age} ans)' : ''}'),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedMember = v),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildExerciseMultiSelect(opts.exercises),
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

  Widget _buildExerciseMultiSelect(List<Exercise> exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercises',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        exercises.isEmpty
            ? const Text('No exercises available',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12))
            : Wrap(
                spacing: 6,
                runSpacing: 4,
                children: exercises.map((e) {
                  final isSelected = _selectedExercices.contains(e.id);
                  return FilterChip(
                    label: Text('Exercise #${e.id}'),
                    selected: isSelected,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _selectedExercices.add(e.id);
                      } else {
                        _selectedExercices.remove(e.id);
                      }
                    }),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildDoubleField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder()),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid number';
        return null;
      },
    );
  }

  Widget _buildIntField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder()),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (int.tryParse(value) == null) return 'Invalid number';
        return null;
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        return null;
      },
    );
  }
}
