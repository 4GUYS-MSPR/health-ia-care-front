import 'package:dio/dio.dart';
import 'dart:convert';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../../domain/entities/import_action_classnames.dart';
import '../models/enum_item_model.dart';
import '../models/nutrition_food_model.dart';

/// Remote datasource for nutrition foods API operations.
abstract class NutritionRemoteDataSource {
  Future<List<EnumItemModel>> getFoodCategories();
  Future<List<EnumItemModel>> getMealTypes();
  Future<NutritionFoodModel> createFood({
    required String label,
    required int calories,
    required double protein,
    required double carbohydrates,
    required double fat,
    required double fiber,
    required double sugars,
    required int sodium,
    required int cholesterol,
    required int waterIntake,
    required int categoryId,
    required int mealTypeId,
  });
  Future<void> deleteFood(int id);
  Future<List<NutritionFoodModel>> getFoods();
  Future<(List<NutritionFoodModel>, PaginationInfo)> getFoodsPage({
    required int offset,
    required int limit,
  });
  Future<NutritionFoodModel> getFood(int id);
  Future<NutritionFoodModel> updateFood(
    int id, {
    String? label,
    int? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugars,
    int? sodium,
    int? cholesterol,
    int? waterIntake,
    int? categoryId,
    int? mealTypeId,
  });

  /// Bulk import foods via the /api/import/ endpoint.
  /// [data] is the JSON-encoded string of items to import.
  Future<void> importFoods(String data);

  /// Generic bulk import via /api/import/ with explicit backend classname.
  ///
  /// [classname] examples: DietRecommendationAction, ExerciceAction,
  /// FoodAction, MemberAction, SessionAction.
  Future<void> importByClassname({
    required String classname,
    required String data,
    bool normalizeFoodPayload,
  });

  /// Fetches export payload from API based on backend classname.
  Future<List<Map<String, dynamic>>> fetchExportObjectsByClassname({
    required String classname,
  });
}

class NutritionRemoteDataSourceImpl with LoggerMixin implements NutritionRemoteDataSource {
  static const _foodsEndpoint = '/api/food/';
  static const _dietEndpoint = '/api/diet_recommendation/';
  static const _exerciseEndpoint = '/api/exercice/';
  static const _sessionEndpoint = '/api/session/';
  static const _memberEndpoint = '/api/member/';
  static const _enumEndpoint = '/api/enum/';
  static const _importEndpoint = '/api/import/';
  static const _foodImportClassname = ImportActionClassnames.food;
  static const _foodCategoryModel = 'FoodCategory';
  static const _mealTypeModel = 'MealType';
  final Dio client;
  NutritionRemoteDataSourceImpl({required this.client});

  @override
  String get loggerName => 'Health.Data.NutritionRemoteDataSource';

  @override
  Future<List<EnumItemModel>> getFoodCategories() => _fetchEnumItems(_foodCategoryModel);
  @override
  Future<List<EnumItemModel>> getMealTypes() => _fetchEnumItems(_mealTypeModel);
  @override
  Future<NutritionFoodModel> createFood({
    required String label,
    required int calories,
    required double protein,
    required double carbohydrates,
    required double fat,
    required double fiber,
    required double sugars,
    required int sodium,
    required int cholesterol,
    required int waterIntake,
    required int categoryId,
    required int mealTypeId,
  }) async {
    logger.fine('createFood(label: $label)');
    final data = {
      'label': label,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'fiber': fiber,
      'sugars': sugars,
      'sodium': sodium,
      'cholesterol': cholesterol,
      'water_intake': waterIntake,
      'category': categoryId,
      'meal_type': mealTypeId,
    };
    try {
      final labelsByModel = await _getFoodLabelsByEnumId();
      final res = await client.post(_foodsEndpoint, data: data);
      return NutritionFoodModel.fromJson(
        res.data as Map<String, dynamic>,
        categoryLabelsById: labelsByModel.categoryLabelsById,
        mealTypeLabelsById: labelsByModel.mealTypeLabelsById,
      );
    } on DioException catch (e) {
      logger.warning('createFood() failed: ${e.message}');
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<void> deleteFood(int id) async {
    logger.fine('deleteFood(id: $id)');
    try {
      await client.delete('$_foodsEndpoint$id/');
      logger.fine('deleteFood($id) → success');
    } on DioException catch (e) {
      logger.warning('deleteFood($id) failed: ${e.message}');
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<List<NutritionFoodModel>> getFoods() async {
    logger.fine('getFoods()');
    try {
      final labelsByModel = await _getFoodLabelsByEnumId();
      final res = await client.get(_foodsEndpoint);
      final data = _extractResults(res.data);
      return data
          .map(
            (item) => NutritionFoodModel.fromJson(
              item,
              categoryLabelsById: labelsByModel.categoryLabelsById,
              mealTypeLabelsById: labelsByModel.mealTypeLabelsById,
            ),
          )
          .toList();
    } on DioException catch (e) {
      logger.warning('getFoods() failed: ${e.message}');
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<(List<NutritionFoodModel>, PaginationInfo)> getFoodsPage({
    required int offset,
    required int limit,
  }) async {
    logger.fine('getFoodsPage(offset: $offset, limit: $limit)');
    try {
      final labelsByModel = await _getFoodLabelsByEnumId();
      final res = await client.get(
        _foodsEndpoint,
        queryParameters: {'offset': offset, 'limit': limit},
      );
      final data = _extractResults(res.data);
      final foods = data
          .map(
            (item) => NutritionFoodModel.fromJson(
              item,
              categoryLabelsById: labelsByModel.categoryLabelsById,
              mealTypeLabelsById: labelsByModel.mealTypeLabelsById,
            ),
          )
          .toList();
      final pagination = PaginationInfo.fromResponse(
        res.data is Map<String, dynamic> ? res.data : {'results': data},
        offset,
        limit,
      );
      logger.fine('getFoodsPage() → ${foods.length} item(s), total=${pagination.count}');
      return (foods, pagination);
    } on DioException catch (e) {
      logger.warning('getFoodsPage() failed: ${e.message}');
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<NutritionFoodModel> getFood(int id) async {
    logger.fine('getFood(id: $id)');
    try {
      final labelsByModel = await _getFoodLabelsByEnumId();
      final res = await client.get('$_foodsEndpoint$id/');
      return NutritionFoodModel.fromJson(
        res.data as Map<String, dynamic>,
        categoryLabelsById: labelsByModel.categoryLabelsById,
        mealTypeLabelsById: labelsByModel.mealTypeLabelsById,
      );
    } on DioException catch (e) {
      logger.warning('getFood($id) failed: ${e.message}');
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<NutritionFoodModel> updateFood(
    int id, {
    String? label,
    int? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugars,
    int? sodium,
    int? cholesterol,
    int? waterIntake,
    int? categoryId,
    int? mealTypeId,
  }) async {
    final data = <String, dynamic>{};
    if (label != null) data['label'] = label;
    if (calories != null) data['calories'] = calories;
    if (protein != null) data['protein'] = protein;
    if (carbohydrates != null) data['carbohydrates'] = carbohydrates;
    if (fat != null) data['fat'] = fat;
    if (fiber != null) data['fiber'] = fiber;
    if (sugars != null) data['sugars'] = sugars;
    if (sodium != null) data['sodium'] = sodium;
    if (cholesterol != null) data['cholesterol'] = cholesterol;
    if (waterIntake != null) data['water_intake'] = waterIntake;
    if (categoryId != null) data['category'] = categoryId;
    if (mealTypeId != null) data['meal_type'] = mealTypeId;
    try {
      final labelsByModel = await _getFoodLabelsByEnumId();
      final res = await client.patch('$_foodsEndpoint$id/', data: data);
      return NutritionFoodModel.fromJson(
        res.data as Map<String, dynamic>,
        categoryLabelsById: labelsByModel.categoryLabelsById,
        mealTypeLabelsById: labelsByModel.mealTypeLabelsById,
      );
    } on DioException catch (e) {
      logger.warning('updateFood($id) failed: ${e.message}');
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  Future<List<EnumItemModel>> _fetchEnumItems(String model) async {
    final res = await client.get('$_enumEndpoint$model/');
    final payload = res.data;
    final List<dynamic> results = payload is Map<String, dynamic>
        ? ((payload['results'] as List<dynamic>?) ?? const <dynamic>[])
        : (payload as List<dynamic>? ?? const <dynamic>[]);
    return results
        .whereType<Map<String, dynamic>>()
        .map(EnumItemModel.fromJson)
        .toList();
  }

  Future<_FoodEnumLabels> _getFoodLabelsByEnumId() async {
    final categories = await _fetchEnumItems(_foodCategoryModel);
    final mealTypes = await _fetchEnumItems(_mealTypeModel);

    return _FoodEnumLabels(
      categoryLabelsById: {
        for (final item in categories) item.id: item.value,
      },
      mealTypeLabelsById: {
        for (final item in mealTypes) item.id: item.value,
      },
    );
  }

  @override
  Future<void> importFoods(String data) async {
    await importByClassname(
      classname: _foodImportClassname,
      data: data,
      normalizeFoodPayload: true,
    );
  }

  @override
  Future<void> importByClassname({
    required String classname,
    required String data,
    bool normalizeFoodPayload = false,
  }) async {
    logger.fine('importByClassname(classname: $classname) raw: $data');
    final payloadData = normalizeFoodPayload && classname == _foodImportClassname
        ? await _normalizeFoodImportPayload(data)
        : data;
    logger.fine('importByClassname(classname: $classname) normalized: $payloadData');

    try {
      final decodedData = jsonDecode(payloadData);
      if (decodedData is! List) {
        throw ServerErrorFailure(debugMessage: 'Normalized import payload must be a JSON array');
      }

      final res = await client.post(
        _importEndpoint,
        data: {
          'classname': classname,
          'data': decodedData,
        },
      );
      logger.info(
        'importByClassname(classname: $classname) response: status=${res.statusCode}, body=${_safeLogValue(res.data)}',
      );
    } on DioException catch (e) {
      logger.warning(
        'importByClassname(classname: $classname) failed: status=${e.response?.statusCode}, message=${e.message}, body=${_safeLogValue(e.response?.data)}',
      );
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage:
            'Import API error: status=${e.response?.statusCode}, body=${_safeLogValue(e.response?.data)}',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchExportObjectsByClassname({
    required String classname,
  }) async {
    final endpoint = switch (classname) {
      ImportActionClassnames.food => _foodsEndpoint,
      ImportActionClassnames.dietRecommendation => _dietEndpoint,
      ImportActionClassnames.exercise => _exerciseEndpoint,
      ImportActionClassnames.session => _sessionEndpoint,
      ImportActionClassnames.member => _memberEndpoint,
      _ => throw ServerErrorFailure(debugMessage: 'Unsupported classname for export: $classname'),
    };

    final res = await client.get(endpoint);
    final rawItems = _extractResults(res.data);
    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<Map<int, String>> _fetchEnumIdToValueMap(String model) async {
    final res = await client.get('$_enumEndpoint$model/');
    final results = _extractEnumItems(res.data, model);

    final map = <int, String>{};
    for (final item in results) {
      final id = item['id'];
      final value = item['value'];
      if (id is int && value != null) {
        map[id] = value.toString().trim();
      } else if (id is num && value != null) {
        map[id.toInt()] = value.toString().trim();
      }
    }
    return map;
  }

  List<Map<String, dynamic>> _extractEnumItems(dynamic payload, String model) {
    if (payload is List) {
      return [
        for (final item in payload)
          if (item is Map<String, dynamic>) item,
      ];
    }

    if (payload is Map<String, dynamic>) {
      final results = payload['results'];
      if (results is List) {
        return [
          for (final item in results)
            if (item is Map<String, dynamic>) item,
        ];
      }
      final data = payload['data'];
      if (data is List) {
        return [
          for (final item in data)
            if (item is Map<String, dynamic>) item,
        ];
      }
    }

    throw ServerErrorFailure(debugMessage: 'Invalid enum payload for $model');
  }

  Future<String> _normalizeFoodImportPayload(String rawJsonData) async {
    dynamic decoded;
    try {
      decoded = jsonDecode(rawJsonData);
    } catch (_) {
      throw ServerErrorFailure(debugMessage: 'Import payload must be valid JSON');
    }

    if (decoded is! List) {
      throw ServerErrorFailure(debugMessage: 'Import payload must be a JSON array');
    }

    final categoryIdToValue = await _fetchEnumIdToValueMap(_foodCategoryModel);
    final mealTypeIdToValue = await _fetchEnumIdToValueMap(_mealTypeModel);

    final normalized = <Map<String, dynamic>>[];
    for (var i = 0; i < decoded.length; i++) {
      final item = decoded[i];
      if (item is! Map<String, dynamic>) {
        throw ServerErrorFailure(
          debugMessage: 'Each imported item must be a JSON object (row ${i + 1})',
        );
      }

      final current = <String, dynamic>{
        'label': _toRequiredLabel(item['label'], rowNumber: i + 1),
        'calories': _toRequiredInt(item['calories'], field: 'calories', rowNumber: i + 1),
        'protein': _toRequiredDouble(item['protein'], field: 'protein', rowNumber: i + 1),
        'carbohydrates': _toRequiredDouble(
          item['carbohydrates'],
          field: 'carbohydrates',
          rowNumber: i + 1,
        ),
        'fat': _toRequiredDouble(item['fat'], field: 'fat', rowNumber: i + 1),
        'fiber': _toRequiredDouble(item['fiber'], field: 'fiber', rowNumber: i + 1),
        'sugars': _toRequiredDouble(item['sugars'], field: 'sugars', rowNumber: i + 1),
        'sodium': _toRequiredInt(item['sodium'], field: 'sodium', rowNumber: i + 1),
        'cholesterol': _toRequiredInt(item['cholesterol'], field: 'cholesterol', rowNumber: i + 1),
        'water_intake': _toRequiredInt(
          item['water_intake'],
          field: 'water_intake',
          rowNumber: i + 1,
        ),
        'category': _toNullableEnumValue(
          item['category'],
          categoryIdToValue,
          modelName: _foodCategoryModel,
        ),
        'meal_type': _toNullableEnumValue(
          item['meal_type'],
          mealTypeIdToValue,
          modelName: _mealTypeModel,
        ),
      };
      normalized.add(current);
    }

    return jsonEncode(normalized);
  }

  String _toRequiredLabel(dynamic rawValue, {required int rowNumber}) {
    final value = rawValue?.toString().trim() ?? '';
    if (value.isEmpty) {
      throw ServerErrorFailure(debugMessage: 'Missing required field label at row $rowNumber');
    }
    if (value.length > 50) {
      throw ServerErrorFailure(debugMessage: 'Field label exceeds maxLength 50 at row $rowNumber');
    }
    return value;
  }

  int _toRequiredInt(dynamic rawValue, {required String field, required int rowNumber}) {
    if (rawValue == null) {
      throw ServerErrorFailure(debugMessage: 'Missing required field $field at row $rowNumber');
    }
    if (rawValue is int) return rawValue;
    if (rawValue is num) return rawValue.toInt();
    final parsed = int.tryParse(rawValue.toString().trim());
    if (parsed != null) return parsed;
    final parsedDouble = double.tryParse(rawValue.toString().trim());
    if (parsedDouble != null) return parsedDouble.toInt();
    throw ServerErrorFailure(debugMessage: 'Invalid integer for $field at row $rowNumber');
  }

  double _toRequiredDouble(dynamic rawValue, {required String field, required int rowNumber}) {
    if (rawValue == null) {
      throw ServerErrorFailure(debugMessage: 'Missing required field $field at row $rowNumber');
    }
    if (rawValue is double) return rawValue;
    if (rawValue is int) return rawValue.toDouble();
    if (rawValue is num) return rawValue.toDouble();
    final parsed = double.tryParse(rawValue.toString().trim().replaceAll(',', '.'));
    if (parsed != null) return parsed;
    throw ServerErrorFailure(debugMessage: 'Invalid number for $field at row $rowNumber');
  }

  String? _toNullableEnumValue(
    dynamic rawValue,
    Map<int, String> idToValue, {
    required String modelName,
  }) {
    if (rawValue == null) return null;
    if (rawValue is int) {
      final found = idToValue[rawValue];
      if (found != null) return found;
      throw ServerErrorFailure(debugMessage: 'Unknown id $rawValue for $modelName');
    }
    if (rawValue is num) {
      final id = rawValue.toInt();
      final found = idToValue[id];
      if (found != null) return found;
      throw ServerErrorFailure(debugMessage: 'Unknown id $id for $modelName');
    }

    final value = rawValue.toString().trim();
    if (value.isEmpty) return null;

    final parsedId = int.tryParse(value);
    if (parsedId != null) {
      final found = idToValue[parsedId];
      if (found != null) return found;
      throw ServerErrorFailure(debugMessage: 'Unknown id $parsedId for $modelName');
    }

    return value;
  }

  String _safeLogValue(dynamic value) {
    if (value == null) return 'null';
    final str = value is String ? value : jsonEncode(value);
    const maxLen = 2000;
    return str.length <= maxLen ? str : '${str.substring(0, maxLen)}...[truncated]';
  }

  List<dynamic> _extractResults(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map && payload['results'] is List) return payload['results'];
    if (payload is Map && payload['data'] is List) return payload['data'];
    if (payload is Map && payload['data'] is Map && payload['data']['results'] is List) {
      return payload['data']['results'];
    }
    throw ServerErrorFailure(
      debugMessage: 'Unexpected foods payload format: ${payload.runtimeType}',
    );
  }
}

class _FoodEnumLabels {
  final Map<int, String> categoryLabelsById;
  final Map<int, String> mealTypeLabelsById;

  const _FoodEnumLabels({
    required this.categoryLabelsById,
    required this.mealTypeLabelsById,
  });
}
