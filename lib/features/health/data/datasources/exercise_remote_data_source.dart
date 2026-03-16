import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../models/exercise_model.dart';

abstract class ExerciseRemoteDataSource {
  Future<List<ExerciseModel>> getExercises();
  Future<(List<ExerciseModel>, PaginationInfo)> getExercisesPage({required int offset, required int limit});
  Future<ExerciseModel> getExercise(int id);
  Future<ExerciseModel> createExercise(Map<String, dynamic> data);
  Future<ExerciseModel> updateExercise(int id, Map<String, dynamic> data);
  Future<void> deleteExercise(int id);
}

class ExerciseRemoteDataSourceImpl with LoggerMixin implements ExerciseRemoteDataSource {
  static const _endpoint = '/api/exercice/';
  final Dio client;

  ExerciseRemoteDataSourceImpl({required this.client});

  @override
  String get loggerName => 'Health.Data.ExerciseRemoteDataSource';

  @override
  Future<List<ExerciseModel>> getExercises() async {
    try {
      final res = await client.get(_endpoint);
      final data = _extractResults(res.data);
      return data.map((item) => ExerciseModel.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<(List<ExerciseModel>, PaginationInfo)> getExercisesPage({required int offset, required int limit}) async {
    try {
      final res = await client.get(_endpoint, queryParameters: {'offset': offset, 'limit': limit});
      final data = _extractResults(res.data);
      final items = data.map((item) => ExerciseModel.fromJson(item as Map<String, dynamic>)).toList();
      final pagination = PaginationInfo.fromResponse(res.data is Map<String, dynamic> ? res.data : {'results': data}, offset, limit);
      return (items, pagination);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<ExerciseModel> getExercise(int id) async {
    try {
      final res = await client.get('$_endpoint$id/');
      return ExerciseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<ExerciseModel> createExercise(Map<String, dynamic> data) async {
    DioException? lastError;
    final variants = _buildNamedExercisePayloadVariants(data);

    logger.fine('createExercise input payload=${_preview(data)}');

    for (final variant in variants) {
      logger.fine('createExercise attempt=${variant.name} payload=${_preview(variant.payload)}');
      try {
        final res = await client.post(_endpoint, data: variant.payload);
        logger.fine('createExercise success attempt=${variant.name} status=${res.statusCode}');
        return ExerciseModel.fromJson(res.data as Map<String, dynamic>);
      } on DioException catch (e) {
        lastError = e;
        final status = e.response?.statusCode;
        logger.warning(
          'createExercise failed attempt=${variant.name} status=$status response=${_preview(e.response?.data)}',
        );
        // Retry only for validation/schema mismatch.
        if (status != 400) {
          throw ServerErrorFailure(
            statusCode: status,
            debugMessage: _composeDioErrorMessage(e),
          );
        }
      }
    }

    throw ServerErrorFailure(
      statusCode: lastError?.response?.statusCode,
      debugMessage: _composeDioErrorMessage(lastError),
    );
  }

  @override
  Future<ExerciseModel> updateExercise(int id, Map<String, dynamic> data) async {
    DioException? lastError;
    final variants = _buildNamedExercisePayloadVariants(data);

    logger.fine('updateExercise id=$id input payload=${_preview(data)}');

    for (final variant in variants) {
      logger.fine('updateExercise id=$id attempt=${variant.name} payload=${_preview(variant.payload)}');
      try {
        final res = await client.patch('$_endpoint$id/', data: variant.payload);
        logger.fine('updateExercise id=$id success attempt=${variant.name} status=${res.statusCode}');
        return ExerciseModel.fromJson(res.data as Map<String, dynamic>);
      } on DioException catch (e) {
        lastError = e;
        final status = e.response?.statusCode;
        logger.warning(
          'updateExercise id=$id failed attempt=${variant.name} status=$status response=${_preview(e.response?.data)}',
        );
        if (status != 400) {
          throw ServerErrorFailure(
            statusCode: status,
            debugMessage: _composeDioErrorMessage(e),
          );
        }
      }
    }

    throw ServerErrorFailure(
      statusCode: lastError?.response?.statusCode,
      debugMessage: _composeDioErrorMessage(lastError),
    );
  }

  @override
  Future<void> deleteExercise(int id) async {
    try {
      await client.delete('$_endpoint$id/');
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  List<dynamic> _extractResults(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map && payload['results'] is List) return payload['results'];
    if (payload is Map && payload['data'] is List) return payload['data'];
    if (payload is Map && payload['data'] is Map && payload['data']['results'] is List) return payload['data']['results'];
    throw ServerErrorFailure(debugMessage: 'Unexpected exercise payload format: ${payload.runtimeType}');
  }

  List<({String name, Map<String, dynamic> payload})> _buildNamedExercisePayloadVariants(
    Map<String, dynamic> input,
  ) {
    final canonical = <String, dynamic>{};
    canonical.addAll(input);

    final objectified = <String, dynamic>{};
    objectified.addAll(input);

    if (objectified['category'] is int) {
      objectified['category'] = {'id': objectified['category']};
    }
    if (objectified['client'] is int) {
      objectified['client'] = {'id': objectified['client']};
    }

    objectified['body_parts'] = _objectifyIdList(objectified['body_parts']);
    objectified['equipments'] = _objectifyIdList(objectified['equipments']);
    objectified['secondary_muscles'] = _objectifyIdList(objectified['secondary_muscles']);
    objectified['target_muscles'] = _objectifyIdList(objectified['target_muscles']);

    final singular = <String, dynamic>{};
    singular.addAll(canonical);
    _moveKeyIfPresent(singular, from: 'body_parts', to: 'body_part');
    _moveKeyIfPresent(singular, from: 'equipments', to: 'equipment');
    _moveKeyIfPresent(singular, from: 'secondary_muscles', to: 'secondary_muscle');
    _moveKeyIfPresent(singular, from: 'target_muscles', to: 'target_muscle');

    final singularObjectified = <String, dynamic>{};
    singularObjectified.addAll(singular);
    if (singularObjectified['category'] is int) {
      singularObjectified['category'] = {'id': singularObjectified['category']};
    }
    if (singularObjectified['client'] is int) {
      singularObjectified['client'] = {'id': singularObjectified['client']};
    }
    singularObjectified['body_part'] = _objectifyIdList(singularObjectified['body_part']);
    singularObjectified['equipment'] = _objectifyIdList(singularObjectified['equipment']);
    singularObjectified['secondary_muscle'] = _objectifyIdList(singularObjectified['secondary_muscle']);
    singularObjectified['target_muscle'] = _objectifyIdList(singularObjectified['target_muscle']);

    return [
      (name: 'canonical', payload: canonical),
      (name: 'objectified', payload: objectified),
      (name: 'singular', payload: singular),
      (name: 'singular_objectified', payload: singularObjectified),
    ];
  }

  List<Map<String, int>> _objectifyIdList(dynamic raw) {
    if (raw is! List) return const <Map<String, int>>[];
    return raw
        .whereType<num>()
        .map((v) => <String, int>{'id': v.toInt()})
        .toList();
  }

  void _moveKeyIfPresent(Map<String, dynamic> map, {required String from, required String to}) {
    if (!map.containsKey(from)) return;
    map[to] = map[from];
    map.remove(from);
  }

  String _composeDioErrorMessage(DioException? e) {
    if (e == null) return 'Unknown exercise request error';
    final status = e.response?.statusCode;
    final body = e.response?.data;
    return '[status=$status] ${e.message}; response=$body';
  }

  String _preview(dynamic value) {
    final text = value?.toString() ?? 'null';
    if (text.length <= 600) return text;
    return '${text.substring(0, 600)}...';
  }
}
