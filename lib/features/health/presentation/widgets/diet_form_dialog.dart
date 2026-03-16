import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../features/members/domain/entities/member.dart';
import '../../domain/entities/enum_item.dart';
import '../../domain/entities/diet_recommendation.dart';

class DietFormData {
  final double adherenceToDietPlan;
  final int bloodPressure;
  final double cholesterol;
  final int dailyCaloricIntake;
  final double dietaryNutrientImbalanceScore;
  final double glucose;
  final double weeklyExerciseHours;
  final int? activity;
  final List<int> allergies;
  final List<int> dietaryRestrictions;
  final int? diseaseType;
  final int? member;
  final int? preferredCuisine;
  final int? severity;

  const DietFormData({
    required this.adherenceToDietPlan,
    required this.bloodPressure,
    required this.cholesterol,
    required this.dailyCaloricIntake,
    required this.dietaryNutrientImbalanceScore,
    required this.glucose,
    required this.weeklyExerciseHours,
    this.activity,
    this.allergies = const [],
    this.dietaryRestrictions = const [],
    this.diseaseType,
    this.member,
    this.preferredCuisine,
    this.severity,
  });
}

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

class DietFormDialog extends StatefulWidget {
  final DietRecommendation? item;
  final Future<List<Member>> Function() loadMembers;
  final Future<List<EnumItem>> Function(String name) loadEnumByName;

  const DietFormDialog({
    super.key,
    this.item,
    required this.loadMembers,
    required this.loadEnumByName,
  });

  static Future<DietFormData?> show(BuildContext context,
      {DietRecommendation? item,
      required Future<List<Member>> Function() loadMembers,
      required Future<List<EnumItem>> Function(String name) loadEnumByName}) {
    return showDialog<DietFormData>(
      context: context,
      builder: (context) => DietFormDialog(
        item: item,
        loadMembers: loadMembers,
        loadEnumByName: loadEnumByName,
      ),
    );
  }

  @override
  State<DietFormDialog> createState() => _DietFormDialogState();
}

class _DietFormDialogState extends State<DietFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _adherenceController;
  late final TextEditingController _bloodPressureController;
  late final TextEditingController _cholesterolController;
  late final TextEditingController _dailyCaloricIntakeController;
  late final TextEditingController _nutrientImbalanceController;
  late final TextEditingController _glucoseController;
  late final TextEditingController _weeklyExerciseHoursController;
  late final Future<_DietOptions> _optionsFuture;

  int? _selectedMember;
  int? _selectedActivity;
  int? _selectedDiseaseType;
  int? _selectedSeverity;
  int? _selectedPreferredCuisine;
  late List<int> _selectedAllergies;
  late List<int> _selectedDietaryRestrictions;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _adherenceController = TextEditingController(
        text: item?.adherenceToDietPlan.toString() ?? '');
    _bloodPressureController =
        TextEditingController(text: item?.bloodPressure.toString() ?? '');
    _cholesterolController =
        TextEditingController(text: item?.cholesterol.toString() ?? '');
    _dailyCaloricIntakeController =
        TextEditingController(text: item?.dailyCaloricIntake.toString() ?? '');
    _nutrientImbalanceController = TextEditingController(
        text: item?.dietaryNutrientImbalanceScore.toString() ?? '');
    _glucoseController =
        TextEditingController(text: item?.glucose.toString() ?? '');
    _weeklyExerciseHoursController =
        TextEditingController(text: item?.weeklyExerciseHours.toString() ?? '');

    _selectedMember = item?.member;
    _selectedActivity = item?.activity;
    _selectedDiseaseType = item?.diseaseType;
    _selectedSeverity = item?.severity;
    _selectedPreferredCuisine = item?.preferredCuisine;
    _selectedAllergies = List.from(item?.allergies ?? []);
    _selectedDietaryRestrictions =
        List.from(item?.dietaryRestrictions ?? []);

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
      Navigator.of(context).pop(DietFormData(
        adherenceToDietPlan: double.parse(_adherenceController.text),
        bloodPressure: int.parse(_bloodPressureController.text),
        cholesterol: double.parse(_cholesterolController.text),
        dailyCaloricIntake: int.parse(_dailyCaloricIntakeController.text),
        dietaryNutrientImbalanceScore:
            double.parse(_nutrientImbalanceController.text),
        glucose: double.parse(_glucoseController.text),
        weeklyExerciseHours: double.parse(_weeklyExerciseHoursController.text),
        activity: _selectedActivity,
        allergies: _selectedAllergies,
        dietaryRestrictions: _selectedDietaryRestrictions,
        diseaseType: _selectedDiseaseType,
        member: _selectedMember,
        preferredCuisine: _selectedPreferredCuisine,
        severity: _selectedSeverity,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Diet Recommendation' : 'Add Diet Recommendation'),
      content: SizedBox(
        width: 560,
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
                          _adherenceController, 'Adherence (0-1)')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildIntField(
                          _bloodPressureController, 'Blood Pressure')),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: _buildDoubleField(
                          _cholesterolController, 'Cholesterol')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildIntField(
                          _dailyCaloricIntakeController,
                          'Daily Caloric Intake')),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: _buildDoubleField(
                          _nutrientImbalanceController, 'Nutrient Imbalance')),
                  const SizedBox(width: 16),
                  Expanded(
                      child:
                          _buildDoubleField(_glucoseController, 'Glucose')),
                ]),
                const SizedBox(height: 16),
                _buildDoubleField(
                    _weeklyExerciseHoursController, 'Weekly Exercise Hours'),
                const SizedBox(height: 16),
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
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final opts = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Member dropdown
                        _buildOptionalEnumDropdownFromMembers(
                            opts.members),
                        const SizedBox(height: 16),
                        // Activity & DiseaseType row
                        Row(children: [
                          Expanded(
                              child: _buildOptionalEnumDropdown(
                                  'Activity',
                                  opts.activities,
                                  _selectedActivity,
                                  (v) => setState(
                                      () => _selectedActivity = v))),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildOptionalEnumDropdown(
                                  'Disease Type',
                                  opts.diseaseTypes,
                                  _selectedDiseaseType,
                                  (v) => setState(
                                      () => _selectedDiseaseType = v))),
                        ]),
                        const SizedBox(height: 16),
                        // Severity & Preferred Cuisine row
                        Row(children: [
                          Expanded(
                              child: _buildOptionalEnumDropdown(
                                  'Severity',
                                  opts.severities,
                                  _selectedSeverity,
                                  (v) => setState(
                                      () => _selectedSeverity = v))),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildOptionalEnumDropdown(
                                  'Preferred Cuisine',
                                  opts.cuisines,
                                  _selectedPreferredCuisine,
                                  (v) => setState(
                                      () =>
                                          _selectedPreferredCuisine = v))),
                        ]),
                        const SizedBox(height: 16),
                        // Allergies multi-select
                        _buildMultiSelect('Allergies', opts.allergies,
                            _selectedAllergies),
                        const SizedBox(height: 16),
                        // Dietary Restrictions multi-select
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

  Widget _buildOptionalEnumDropdownFromMembers(List<Member> members) {
    return DropdownButtonFormField<int?>(
      initialValue: _selectedMember,
      decoration: const InputDecoration(
        labelText: 'Member',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('None')),
        ...members.map((m) => DropdownMenuItem<int?>(
              value: m.id,
              child: Text(
                  'Member #${m.id}${m.age != null ? ' (${m.age} ans)' : ''}'),
            )),
      ],
      onChanged: (v) => setState(() => _selectedMember = v),
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
        labelText: label,
        border: const OutlineInputBorder(),
      ),
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
}
