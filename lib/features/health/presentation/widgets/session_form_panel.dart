import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../features/members/domain/entities/member.dart';
import '../../domain/entities/exercise.dart';
import '../blocs/sessions_bloc.dart';

class _SessionOptions {
  final List<Member> members;
  final List<Exercise> exercises;

  const _SessionOptions({required this.members, required this.exercises});
}

class SessionFormPanel extends StatefulWidget {
  const SessionFormPanel(
      {super.key,
      required this.onCancel,
      required this.onSaved,
      required this.loadMembers,
      required this.loadExercises});
  final VoidCallback onCancel;
  final VoidCallback onSaved;
  final Future<List<Member>> Function() loadMembers;
  final Future<List<Exercise>> Function() loadExercises;

  @override
  State<SessionFormPanel> createState() => _SessionFormPanelState();
}

class _SessionFormPanelState extends State<SessionFormPanel> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  final _durationController = TextEditingController();
  final _avgBpmController = TextEditingController();
  final _maxBpmController = TextEditingController();
  final _restingBpmController = TextEditingController();
  final _waterIntakeController = TextEditingController();

  late final Future<_SessionOptions> _optionsFuture;

  int? _selectedMember;
  final List<int> _selectedExercices = [];

  @override
  void initState() {
    super.initState();
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
      context.read<SessionsBloc>().add(
        CreateSessionRequested(
          caloriesBurned: double.tryParse(_caloriesController.text) ?? 0,
          duration: _durationController.text,
          avgBpm: int.tryParse(_avgBpmController.text) ?? 0,
          maxBpm: int.tryParse(_maxBpmController.text) ?? 0,
          restingBpm: int.tryParse(_restingBpmController.text) ?? 0,
          waterIntake: double.tryParse(_waterIntakeController.text) ?? 0,
          member: _selectedMember!,
          exercices: _selectedExercices.isEmpty ? null : _selectedExercices,
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
                const Icon(Icons.timer_outlined, color: Colors.blue),
                const SizedBox(width: 12),
                Text(l10n.sessionFormCreateTitle,
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
                    _buildDoubleField(_caloriesController, l10n.sessionCaloriesBurned),
                    const SizedBox(height: 12),
                    _buildTextField(_durationController, l10n.sessionDuration),
                    const SizedBox(height: 12),
                    _buildIntField(_avgBpmController, l10n.sessionAvgBpm),
                    const SizedBox(height: 12),
                    _buildIntField(_maxBpmController, l10n.sessionMaxBpm),
                    const SizedBox(height: 12),
                    _buildIntField(_restingBpmController, l10n.sessionRestingBpm),
                    const SizedBox(height: 12),
                    _buildDoubleField(_waterIntakeController, l10n.sessionWaterIntake),
                    const SizedBox(height: 12),
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
                              padding: EdgeInsets.symmetric(vertical: 16),
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
                              decoration: InputDecoration(
                                  labelText: l10n.sessionMember,
                                  border: const OutlineInputBorder()),
                              items: opts.members
                                  .map((m) => DropdownMenuItem<int>(
                                        value: m.id,
                                        child: Text(
                                            'Member #${m.id}${m.age != null ? ' (${m.age} ans)' : ''}'),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedMember = v),
                              validator: (v) => v == null ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: widget.onCancel,
                        child: Text(l10n.sessionFormCancelButton))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: _onSave,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(l10n.sessionFormCreateButton))),
              ],
            ),
          ),
        ],
      ),
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
        if (double.tryParse(value) == null) return 'Invalid';
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
        if (int.tryParse(value) == null) return 'Invalid';
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
