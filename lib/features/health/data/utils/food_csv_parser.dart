import 'dart:convert';

import 'package:csv/csv.dart';

import '../../domain/entities/food_import_row.dart';
import '../../domain/entities/import_action_classnames.dart';
import '../models/nutrition_food_model.dart';

/// Expected CSV column headers (case-insensitive matching).
const _kExpectedHeaders = [
  'label',
  'calories',
  'protein',
  'carbohydrates',
  'fat',
  'fiber',
  'sugars',
  'sodium',
  'cholesterol',
  'water_intake',
  'category',
  'meal_type',
];

/// Alias map for flexible header matching.
const _kHeaderAliases = <String, String>{
  'name': 'label',
  'food_name': 'label',
  'food': 'label',
  'cal': 'calories',
  'kcal': 'calories',
  'prot': 'protein',
  'carbs': 'carbohydrates',
  'carb': 'carbohydrates',
  'fats': 'fat',
  'lipids': 'fat',
  'fibre': 'fiber',
  'fibres': 'fiber',
  'sugar': 'sugars',
  'na': 'sodium',
  'chol': 'cholesterol',
  'water': 'water_intake',
  'waterintake': 'water_intake',
  'cat': 'category',
  'type': 'meal_type',
  'mealtype': 'meal_type',
  'meal': 'meal_type',
};

/// Result of parsing a CSV file.
class CsvParseResult {
  final List<FoodImportRow> rows;
  final List<String> warnings;
  final List<String> missingHeaders;

  const CsvParseResult({
    required this.rows,
    this.warnings = const [],
    this.missingHeaders = const [],
  });

  bool get hasErrors => rows.any((r) => r.hasErrors);
  int get errorCount => rows.where((r) => r.hasErrors).length;
  int get validCount => rows.where((r) => r.isValid).length;
}

/// Result of generic parsing for non-food imports.
class GenericImportParseResult {
  final List<Map<String, dynamic>> items;
  final List<String> warnings;
  final List<String> missingHeaders;

  const GenericImportParseResult({
    required this.items,
    this.warnings = const [],
    this.missingHeaders = const [],
  });

  int get count => items.length;
}

class _GenericImportSchema {
  final List<String> requiredFields;
  final List<String> labelCandidates;
  final Map<String, String> aliases;

  const _GenericImportSchema({
    required this.requiredFields,
    required this.labelCandidates,
    this.aliases = const <String, String>{},
  });
}

const _dietSchema = _GenericImportSchema(
  requiredFields: [
    'adherence_to_diet_plan',
    'blood_pressure',
    'cholesterol',
    'daily_caloric_intake',
    'dietary_nutrient_imbalance_score',
    'glucose',
    'weekly_exercise_hours',
  ],
  labelCandidates: ['recommendation', 'disease_type', 'member', 'blood_pressure'],
  aliases: {
    'adherence': 'adherence_to_diet_plan',
    'daily_calories': 'daily_caloric_intake',
    'imbalance_score': 'dietary_nutrient_imbalance_score',
    'exercise_hours': 'weekly_exercise_hours',
  },
);

const _exerciseSchema = _GenericImportSchema(
  requiredFields: ['image_url'],
  labelCandidates: ['image_url', 'category', 'client'],
  aliases: {
    'image': 'image_url',
    'bodyparts': 'body_parts',
    'targetmuscles': 'target_muscles',
    'secondarymuscles': 'secondary_muscles',
  },
);

const _sessionSchema = _GenericImportSchema(
  requiredFields: [
    'calories_burned',
    'duration',
    'avg_bpm',
    'max_bpm',
    'resting_bpm',
    'water_intake',
    'member',
  ],
  labelCandidates: ['duration', 'member', 'calories_burned'],
  aliases: {
    'calories': 'calories_burned',
    'avgbpm': 'avg_bpm',
    'maxbpm': 'max_bpm',
    'restingbpm': 'resting_bpm',
    'water': 'water_intake',
    'exercises': 'exercices',
  },
);

const _memberSchema = _GenericImportSchema(
  requiredFields: [
    'bmi',
    'fat_percentage',
    'height',
    'weight',
    'workout_frequency',
    'gender',
    'level',
    'subscription',
    'objectives',
  ],
  labelCandidates: ['client', 'age', 'objectives'],
  aliases: {
    'fat': 'fat_percentage',
    'workouts': 'workout_frequency',
  },
);

const _defaultSchema = _GenericImportSchema(
  requiredFields: [],
  labelCandidates: ['label', 'name', 'title', 'id'],
);

_GenericImportSchema _schemaForClassname(String classname) {
  return switch (classname) {
    ImportActionClassnames.dietRecommendation => _dietSchema,
    ImportActionClassnames.exercise => _exerciseSchema,
    ImportActionClassnames.session => _sessionSchema,
    ImportActionClassnames.member => _memberSchema,
    _ => _defaultSchema,
  };
}

String _normalizeKey(String key) => key.replaceAll(RegExp(r'[\s\-]+'), '_').toLowerCase();

String _canonicalField(String rawKey, _GenericImportSchema schema) {
  final normalized = _normalizeKey(rawKey);
  if (schema.aliases.containsKey(normalized)) return schema.aliases[normalized]!;
  return normalized;
}

bool _isMissingValue(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  if (value is List) return value.isEmpty;
  return false;
}

/// Parses a CSV string into a list of [FoodImportRow].
///
/// Performs header detection, value parsing, and per-row validation.
CsvParseResult parseFoodCsv(String csvContent) {
  if (csvContent.trim().isEmpty) {
    return const CsvParseResult(
      rows: [],
      warnings: ['CSV file is empty'],
    );
  }

  final converter = const CsvToListConverter(eol: '\n', shouldParseNumbers: false);
  // Normalize line endings
  final normalized = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final allRows = converter.convert(normalized);

  if (allRows.isEmpty) {
    return const CsvParseResult(
      rows: [],
      warnings: ['CSV file has no data'],
    );
  }

  // First row = headers
  final rawHeaders = allRows.first.map((e) => e.toString().trim().toLowerCase()).toList();
  final headerMap = _buildHeaderMapping(rawHeaders);

  final missingHeaders = <String>[];
  for (final expected in _kExpectedHeaders) {
    if (!headerMap.containsKey(expected)) {
      missingHeaders.add(expected);
    }
  }

  // Only label is truly required to proceed
  if (!headerMap.containsKey('label')) {
    return CsvParseResult(
      rows: const [],
      missingHeaders: missingHeaders,
      warnings: ['Missing required "label" column. Found columns: ${rawHeaders.join(", ")}'],
    );
  }

  final rows = <FoodImportRow>[];
  final warnings = <String>[];

  for (var i = 1; i < allRows.length; i++) {
    final row = allRows[i];

    // Skip completely empty rows
    if (row.every((cell) => cell.toString().trim().isEmpty)) continue;

    final parsed = _parseRow(i, row, headerMap, rawHeaders.length);
    rows.add(parsed);

    if (parsed.hasErrors) {
      warnings.add('Row $i has ${parsed.errors.length} error(s)');
    }
  }

  return CsvParseResult(
    rows: rows,
    warnings: warnings,
    missingHeaders: missingHeaders,
  );
}

/// Validates a single [FoodImportRow] and returns it with errors populated.
FoodImportRow validateFoodImportRow(FoodImportRow row) {
  final errors = <String, String>{};

  if (row.label.trim().isEmpty) {
    errors['label'] = 'Label must not be empty';
  }
  if (row.calories < 0) {
    errors['calories'] = 'Must be ≥ 0';
  }
  if (row.protein < 0) {
    errors['protein'] = 'Must be ≥ 0';
  }
  if (row.carbohydrates < 0) {
    errors['carbohydrates'] = 'Must be ≥ 0';
  }
  if (row.fat < 0) {
    errors['fat'] = 'Must be ≥ 0';
  }
  if (row.fiber < 0) {
    errors['fiber'] = 'Must be ≥ 0';
  }
  if (row.sugars < 0) {
    errors['sugars'] = 'Must be ≥ 0';
  }
  if (row.sodium < 0) {
    errors['sodium'] = 'Must be ≥ 0';
  }
  if (row.cholesterol < 0) {
    errors['cholesterol'] = 'Must be ≥ 0';
  }
  if (row.waterIntake < 0) {
    errors['water_intake'] = 'Must be ≥ 0';
  }

  return row.copyWith(errors: errors);
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

Map<String, int> _buildHeaderMapping(List<String> rawHeaders) {
  final map = <String, int>{};

  for (var i = 0; i < rawHeaders.length; i++) {
    final h = rawHeaders[i].replaceAll(RegExp(r'[\s_-]+'), '').toLowerCase();

    // Direct match
    for (final expected in _kExpectedHeaders) {
      if (h == expected.replaceAll('_', '')) {
        map[expected] = i;
        break;
      }
    }

    // Alias match
    if (!map.values.contains(i)) {
      final alias = _kHeaderAliases[h];
      if (alias != null && !map.containsKey(alias)) {
        map[alias] = i;
      }
    }
  }

  return map;
}

FoodImportRow _parseRow(
  int rowIndex,
  List<dynamic> row,
  Map<String, int> headerMap,
  int expectedColumns,
) {
  String getString(String field) {
    final idx = headerMap[field];
    if (idx == null || idx >= row.length) return '';
    return row[idx].toString().trim();
  }

  int parseInt_(String field) {
    final raw = getString(field);
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? double.tryParse(raw)?.toInt() ?? -1;
  }

  double parseDouble_(String field) {
    final raw = getString(field);
    if (raw.isEmpty) return 0.0;
    // Handle comma decimal separator
    final cleaned = raw.replaceAll(',', '.');
    return double.tryParse(cleaned) ?? -1.0;
  }

  final parsed = FoodImportRow(
    index: rowIndex,
    label: getString('label'),
    calories: parseInt_('calories'),
    protein: parseDouble_('protein'),
    carbohydrates: parseDouble_('carbohydrates'),
    fat: parseDouble_('fat'),
    fiber: parseDouble_('fiber'),
    sugars: parseDouble_('sugars'),
    sodium: parseInt_('sodium'),
    cholesterol: parseInt_('cholesterol'),
    waterIntake: parseInt_('water_intake'),
    category: getString('category'),
    mealType: getString('meal_type'),
  );

  return validateFoodImportRow(parsed);
}

// ---------------------------------------------------------------------------
// JSON import
// ---------------------------------------------------------------------------

/// Parses a JSON string (array of objects) into a list of [FoodImportRow].
///
/// Accepts flexible key names using the same alias map as CSV.
CsvParseResult parseFoodJson(String jsonContent) {
  if (jsonContent.trim().isEmpty) {
    return const CsvParseResult(
      rows: [],
      warnings: ['JSON file is empty'],
    );
  }

  dynamic decoded;
  try {
    decoded = jsonDecode(jsonContent);
  } catch (e) {
    return CsvParseResult(
      rows: const [],
      warnings: ['Invalid JSON: $e'],
    );
  }

  List<dynamic> items;
  if (decoded is List) {
    items = decoded;
  } else if (decoded is Map<String, dynamic>) {
    // Support { "results": [...] } or { "data": [...] } wrappers
    if (decoded['results'] is List) {
      items = decoded['results'] as List;
    } else if (decoded['data'] is List) {
      items = decoded['data'] as List;
    } else {
      items = [decoded]; // single object
    }
  } else {
    return const CsvParseResult(
      rows: [],
      warnings: ['JSON root must be an array or an object'],
    );
  }

  if (items.isEmpty) {
    return const CsvParseResult(
      rows: [],
      warnings: ['JSON array is empty'],
    );
  }

  final rows = <FoodImportRow>[];
  final warnings = <String>[];

  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    if (item is! Map<String, dynamic>) {
      warnings.add('Item $i is not a JSON object – skipped');
      continue;
    }

    final parsed = _parseJsonObject(i + 1, item);
    rows.add(parsed);

    if (parsed.hasErrors) {
      warnings.add('Row ${i + 1} has ${parsed.errors.length} error(s)');
    }
  }

  return CsvParseResult(rows: rows, warnings: warnings);
}

FoodImportRow _parseJsonObject(int index, Map<String, dynamic> obj) {
  // Normalize keys: remove spaces/underscores, lowercase
  final normalized = <String, dynamic>{};
  for (final entry in obj.entries) {
    final key = entry.key.replaceAll(RegExp(r'[\s_-]+'), '').toLowerCase();
    normalized[key] = entry.value;
  }

  String getString(String field) {
    final canonical = field.replaceAll('_', '').toLowerCase();
    // Direct match
    if (normalized.containsKey(canonical)) {
      return normalized[canonical]?.toString().trim() ?? '';
    }
    // Alias match
    for (final entry in _kHeaderAliases.entries) {
      if (_kHeaderAliases[entry.key]?.replaceAll('_', '').toLowerCase() == canonical) {
        final aliasKey = entry.key.replaceAll(RegExp(r'[\s_-]+'), '').toLowerCase();
        if (normalized.containsKey(aliasKey)) {
          return normalized[aliasKey]?.toString().trim() ?? '';
        }
      }
    }
    return '';
  }

  int parseInt_(String field) {
    final raw = getString(field);
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? double.tryParse(raw)?.toInt() ?? -1;
  }

  double parseDouble_(String field) {
    final raw = getString(field);
    if (raw.isEmpty) return 0.0;
    final cleaned = raw.replaceAll(',', '.');
    return double.tryParse(cleaned) ?? -1.0;
  }

  // Also try direct numeric values from JSON
  dynamic rawValue(String field) {
    final canonical = field.replaceAll('_', '').toLowerCase();
    return normalized[canonical];
  }

  int parseIntDirect(String field) {
    final v = rawValue(field);
    if (v is int) return v;
    if (v is double) return v.toInt();
    return parseInt_(field);
  }

  double parseDoubleDirect(String field) {
    final v = rawValue(field);
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return parseDouble_(field);
  }

  final parsed = FoodImportRow(
    index: index,
    label: getString('label'),
    calories: parseIntDirect('calories'),
    protein: parseDoubleDirect('protein'),
    carbohydrates: parseDoubleDirect('carbohydrates'),
    fat: parseDoubleDirect('fat'),
    fiber: parseDoubleDirect('fiber'),
    sugars: parseDoubleDirect('sugars'),
    sodium: parseIntDirect('sodium'),
    cholesterol: parseIntDirect('cholesterol'),
    waterIntake: parseIntDirect('water_intake'),
    category: getString('category'),
    mealType: getString('meal_type'),
  );

  return validateFoodImportRow(parsed);
}

// ---------------------------------------------------------------------------
// Export helpers
// ---------------------------------------------------------------------------

/// Converts a [FoodImportRow] to an API-compatible JSON map (for bulk import).
Map<String, dynamic> foodRowToApiJson(FoodImportRow row) {
  return {
    'label': row.label,
    'calories': row.calories,
    'protein': row.protein,
    'carbohydrates': row.carbohydrates,
    'fat': row.fat,
    'fiber': row.fiber,
    'sugars': row.sugars,
    'sodium': row.sodium,
    'cholesterol': row.cholesterol,
    'water_intake': row.waterIntake,
    'category': row.category.isNotEmpty ? row.category : null,
    'meal_type': row.mealType.isNotEmpty ? row.mealType : null,
  };
}

/// Converts a list of [NutritionFoodModel] to a CSV string.
String foodsToCsv(List<NutritionFoodModel> foods) {
  final rows = <List<dynamic>>[
    [
      'label',
      'calories',
      'protein',
      'carbohydrates',
      'fat',
      'fiber',
      'sugars',
      'sodium',
      'cholesterol',
      'water_intake',
      'category',
      'meal_type',
    ],
    ...foods.map(
      (f) => [
        f.label,
        f.calories,
        f.protein,
        f.carbohydrates,
        f.fat,
        f.fiber,
        f.sugars,
        f.sodium,
        f.cholesterol,
        f.waterIntake,
        f.category,
        f.mealType,
      ],
    ),
  ];
  return const ListToCsvConverter().convert(rows);
}

/// Converts a list of [NutritionFoodModel] to a JSON string.
String foodsToJson(List<NutritionFoodModel> foods) {
  final list = foods.map((f) {
    final json = f.toMap();
    json.remove('id'); // Remove id for export compatibility
    return json;
  }).toList();
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(list);
}

/// Parses generic CSV content into a list of JSON objects using header row keys.
GenericImportParseResult parseGenericCsvToJsonObjects(
  String csvContent, {
  required String classname,
}) {
  final schema = _schemaForClassname(classname);
  if (csvContent.trim().isEmpty) {
    return const GenericImportParseResult(
      items: [],
      warnings: ['CSV file is empty'],
    );
  }

  final converter = const CsvToListConverter(eol: '\n', shouldParseNumbers: false);
  final normalized = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final allRows = converter.convert(normalized);

  if (allRows.isEmpty) {
    return const GenericImportParseResult(
      items: [],
      warnings: ['CSV file has no data'],
    );
  }

  final headers = allRows.first.map((e) => e.toString().trim()).toList();
  if (headers.isEmpty || headers.every((h) => h.isEmpty)) {
    return const GenericImportParseResult(
      items: [],
      warnings: ['CSV header row is empty'],
    );
  }

  final canonicalHeaders = headers.map((h) => _canonicalField(h, schema)).toList();
  final missingHeaders = <String>[
    for (final field in schema.requiredFields)
      if (!canonicalHeaders.contains(field)) field,
  ];

  final items = <Map<String, dynamic>>[];
  final warnings = <String>[
    if (missingHeaders.isNotEmpty)
      'Missing required columns: ${missingHeaders.join(', ')}',
  ];

  for (var i = 1; i < allRows.length; i++) {
    final row = allRows[i];
    if (row.every((cell) => cell.toString().trim().isEmpty)) continue;

    final mapped = <String, dynamic>{};
    for (var col = 0; col < headers.length; col++) {
      final header = headers[col].trim();
      if (header.isEmpty) continue;
      final value = col < row.length ? row[col] : null;
      mapped[_canonicalField(header, schema)] = value;
    }

    if (mapped.isEmpty) {
      warnings.add('Row $i has no mapped fields and was skipped');
      continue;
    }

    final missingRequired = [
      for (final field in schema.requiredFields)
        if (!mapped.containsKey(field) || _isMissingValue(mapped[field])) field,
    ];
    if (missingRequired.isNotEmpty) {
      warnings.add('Row $i skipped (missing: ${missingRequired.join(', ')})');
      continue;
    }

    items.add(mapped);
  }

  return GenericImportParseResult(
    items: items,
    warnings: warnings,
    missingHeaders: missingHeaders,
  );
}

/// Parses generic JSON content into a list of JSON objects.
GenericImportParseResult parseGenericJsonToJsonObjects(
  String jsonContent, {
  required String classname,
}) {
  final schema = _schemaForClassname(classname);
  if (jsonContent.trim().isEmpty) {
    return const GenericImportParseResult(
      items: [],
      warnings: ['JSON file is empty'],
    );
  }

  dynamic decoded;
  try {
    decoded = jsonDecode(jsonContent);
  } catch (e) {
    return GenericImportParseResult(
      items: const [],
      warnings: ['Invalid JSON: $e'],
    );
  }

  List<dynamic> rawItems;
  if (decoded is List) {
    rawItems = decoded;
  } else if (decoded is Map<String, dynamic>) {
    if (decoded['results'] is List) {
      rawItems = decoded['results'] as List<dynamic>;
    } else if (decoded['data'] is List) {
      rawItems = decoded['data'] as List<dynamic>;
    } else {
      rawItems = [decoded];
    }
  } else {
    return const GenericImportParseResult(
      items: [],
      warnings: ['JSON root must be an array or object'],
    );
  }

  final items = <Map<String, dynamic>>[];
  final warnings = <String>[];
  for (var i = 0; i < rawItems.length; i++) {
    final item = rawItems[i];
    if (item is Map<String, dynamic>) {
      final normalized = <String, dynamic>{
        for (final entry in item.entries) _canonicalField(entry.key, schema): entry.value,
      };
      final missingRequired = [
        for (final field in schema.requiredFields)
          if (!normalized.containsKey(field) || _isMissingValue(normalized[field])) field,
      ];
      if (missingRequired.isNotEmpty) {
        warnings.add('Item $i skipped (missing: ${missingRequired.join(', ')})');
      } else {
        items.add(normalized);
      }
    } else if (item is Map) {
      final casted = Map<String, dynamic>.from(item);
      final normalized = <String, dynamic>{
        for (final entry in casted.entries) _canonicalField(entry.key, schema): entry.value,
      };
      final missingRequired = [
        for (final field in schema.requiredFields)
          if (!normalized.containsKey(field) || _isMissingValue(normalized[field])) field,
      ];
      if (missingRequired.isNotEmpty) {
        warnings.add('Item $i skipped (missing: ${missingRequired.join(', ')})');
      } else {
        items.add(normalized);
      }
    } else {
      warnings.add('Item $i is not an object and was skipped');
    }
  }

  return GenericImportParseResult(items: items, warnings: warnings);
}

/// Builds lightweight preview rows for non-food imports.
List<FoodImportRow> buildGenericPreviewRows(
  List<Map<String, dynamic>> items, {
  required String classname,
}) {
  final schema = _schemaForClassname(classname);

  String pickLabel(Map<String, dynamic> item, int index) {
    final keys = schema.labelCandidates;
    for (final key in keys) {
      if (item.containsKey(key) && item[key] != null) {
        final value = item[key].toString().trim();
        if (value.isNotEmpty) return value;
      }
    }
    return 'row_$index';
  }

  return [
    for (var i = 0; i < items.length; i++)
      FoodImportRow(
        index: i + 1,
        label: pickLabel(items[i], i + 1),
        calories: 0,
        protein: 0,
        carbohydrates: 0,
        fat: 0,
        fiber: 0,
        sugars: 0,
        sodium: 0,
        cholesterol: 0,
        waterIntake: 0,
        category: '',
        mealType: '',
      ),
  ];
}
