import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../features/members/domain/entities/member.dart';
import '../../domain/entities/enum_item.dart';
import '../blocs/diet_recommendations_bloc.dart';

class _DietOptions {
  final List<Member> members;
  final List<EnumItem> activities;
  final List<EnumItem> diseaseTypes;
  final List<EnumItem> severities;
  final List<EnumItem> cuisines;
  final List<EnumItem> allergies;
  final List<EnumItem> dietaryRestrictions;

  const _DietOptions({
    required this.members,
    required this.activities,
    required this.diseaseTypes,
    required this.severities,
    required this.cuisines,
    required this.allergies,
    required this.dietaryRestrictions,
  });
}

class DietFormPanel extends StatefulWidget {
  const DietFormPanel(
      {super.key,
      required this.onCancel,
      required this.onSaved,
      required this.loadMembers,
      required this.loadEnumByName});
  final VoidCallback onCancel;
  final VoidCallback onSaved;
  final Future<List<Member>> Function() loadMembers;
  final Future<List<EnumItem>> Function(String name) loadEnumByName;

  @override
  State<DietFormPanel> createState() => _DietFormPanelState();
}

class _DietFormPanelState extends State<DietFormPanel> {
  final _formKey = GlobalKey<FormState>();
  final _adherenceController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _cholesterolController = TextEditingController();
  final _dailyCaloricIntakeController = TextEditingController();
  final _nutrientImbalanceController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _weeklyExerciseHoursController = TextEditingController();

  late final Future<_DietOptions> _optionsFuture;

  int? _selectedMember;
  int? _selectedActivity;
  int? _selectedDiseaseType;
  int? _selectedSeverity;
  int? _selectedPreferredCuisine;
  final List<int> _selectedAllergies = [];
  final List<int> _selectedDietaryRestrictions = [];

  @override
  void initState() {
    super.initState();
    _optionsFuture = Future.wait([
      widget.loadMembers(),
      widget.loadEnumByName('Activity'),
      widget.loadEnumByName('DiseaseType'),
      widget.loadEnumByName('Severity'),
      widget.loadEnumByName('Cuisine'),
      widget.loadEnumByName('Allergy'),
      widget.loadEnumByName('DietaryRestriction'),
    ]).then(
      (results) => _DietOptions(
        members: (results[0] as List).cast<Member>(),
        activities: results[1] as List<EnumItem>,
        diseaseTypes: results[2] as List<EnumItem>,
        severities: results[3] as List<EnumItem>,
        cuisines: results[4] as List<EnumItem>,
        allergies: results[5] as List<EnumItem>,
        dietaryRestrictions: results[6] as List<EnumItem>,
      ),
    );
  }

  @override
  void dispose() {
    _adherenceController.dispose();
    _bloodPressureController.dispose();
    _cholesterolController.dispose();
    _dailyCaloricIntakeController.dispose();
    _nutrientImbalanceController.dispose();
    _glucoseController.dispose();
    _weeklyExerciseHoursController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<DietRecommendationsBloc>().add(
        CreateDietRecommendationRequested(
          adherenceToDietPlan:
              double.tryParse(_adherenceController.text) ?? 0,
          bloodPressure:
              int.tryParse(_bloodPressureController.text) ?? 0,
          cholesterol:
              double.tryParse(_cholesterolController.text) ?? 0,
          dailyCaloricIntake:
              int.tryParse(_dailyCaloricIntakeController.text) ?? 0,
          dietaryNutrientImbalanceScore:
              double.tryParse(_nutrientImbalanceController.text) ?? 0,
          glucose: double.tryParse(_glucoseController.text) ?? 0,
          weeklyExerciseHours:
              double.tryParse(_weeklyExerciseHoursController.text) ?? 0,
          activity: _selectedActivity,
          allergies:
              _selectedAllergies.isEmpty ? null : _selectedAllergies,
          dietaryRestrictions: _selectedDietaryRestrictions.isEmpty
              ? null
              : _selectedDietaryRestrictions,
          diseaseType: _selectedDiseaseType,
          member: _selectedMember,
          preferredCuisine: _selectedPreferredCuisine,
          severity: _selectedSeverity,
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
                const Icon(Icons.restaurant_menu_outlined, color: Colors.blue),
                const SizedBox(width: 12),
                Text(l10n.dietFormCreateTitle,
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
                    _buildDoubleField(
                        _adherenceController, l10n.dietAdherence),
                    const SizedBox(height: 12),
                    _buildIntField(
                        _bloodPressureController, l10n.dietBloodPressure),
                    const SizedBox(height: 12),
                    _buildDoubleField(
                        _cholesterolController, l10n.dietCholesterol),
                    const SizedBox(height: 12),
                    _buildIntField(_dailyCaloricIntakeController,
                        l10n.dietDailyCaloricIntake),
                    const SizedBox(height: 12),
                    _buildDoubleField(_nutrientImbalanceController,
                        l10n.dietNutrientImbalance),
                    const SizedBox(height: 12),
                    _buildDoubleField(_glucoseController, l10n.dietGlucose),
                    const SizedBox(height: 12),
                    _buildDoubleField(_weeklyExerciseHoursController,
                        l10n.dietWeeklyExerciseHours),
                    const SizedBox(height: 12),
                    FutureBuilder<_DietOptions>(
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
                            DropdownButtonFormField<int?>(
                              initialValue: _selectedMember,
                              decoration: InputDecoration(
                                  labelText: l10n.dietMember,
                                  border: const OutlineInputBorder()),
                              items: [
                                const DropdownMenuItem<int?>(
                                    value: null, child: Text('None')),
                                ...opts.members.map((m) =>
                                    DropdownMenuItem<int?>(
                                      value: m.id,
                                      child: Text(
                                          'Member #${m.id}${m.age != null ? ' (${m.age} ans)' : ''}'),
                                    )),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedMember = v),
                            ),
                            const SizedBox(height: 12),
                            _buildOptionalEnumDropdown(
                                l10n.dietActivity,
                                opts.activities,
                                _selectedActivity,
                                (v) =>
                                    setState(() => _selectedActivity = v)),
                            const SizedBox(height: 12),
                            _buildOptionalEnumDropdown(
                                'Disease Type',
                                opts.diseaseTypes,
                                _selectedDiseaseType,
                                (v) => setState(
                                    () => _selectedDiseaseType = v)),
                            const SizedBox(height: 12),
                            _buildOptionalEnumDropdown(
                                l10n.dietSeverity,
                                opts.severities,
                                _selectedSeverity,
                                (v) =>
                                    setState(() => _selectedSeverity = v)),
                            const SizedBox(height: 12),
                            _buildOptionalEnumDropdown(
                                'Preferred Cuisine',
                                opts.cuisines,
                                _selectedPreferredCuisine,
                                (v) => setState(
                                    () => _selectedPreferredCuisine = v)),
                            const SizedBox(height: 12),
                            _buildMultiSelect('Allergies', opts.allergies,
                                _selectedAllergies),
                            const SizedBox(height: 12),
                            _buildMultiSelect(
                                'Dietary Restrictions',
                                opts.dietaryRestrictions,
                                _selectedDietaryRestrictions),
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
                        child: Text(l10n.dietFormCancelButton))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: _onSave,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(l10n.dietFormCreateButton))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalEnumDropdown(
    String label,
    List<EnumItem> items,
    int? currentValue,
    void Function(int?) onChanged,
  ) {
    return DropdownButtonFormField<int?>(
      initialValue: currentValue,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder()),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('None')),
        ...items.map((e) =>
            DropdownMenuItem<int?>(value: e.id, child: Text(e.value))),
      ],
      onChanged: onChanged,
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
}
