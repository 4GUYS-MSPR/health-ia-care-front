import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../models/workout_session_model.dart';

abstract class SessionRemoteDataSource {
  Future<List<WorkoutSessionModel>> getSessions();
  Future<(List<WorkoutSessionModel>, PaginationInfo)> getSessionsPage({required int offset, required int limit});
  Future<WorkoutSessionModel> getSession(int id);
  Future<WorkoutSessionModel> createSession(Map<String, dynamic> data);
  Future<WorkoutSessionModel> updateSession(int id, Map<String, dynamic> data);
  Future<void> deleteSession(int id);
}

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  static const _endpoint = '/api/session/';
  final Dio client;

  SessionRemoteDataSourceImpl({required this.client});

  @override
  Future<List<WorkoutSessionModel>> getSessions() async {
    try {
      final res = await client.get(_endpoint);
      final data = _extractResults(res.data);
      return data.map((item) => WorkoutSessionModel.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<(List<WorkoutSessionModel>, PaginationInfo)> getSessionsPage({required int offset, required int limit}) async {
    try {
      final res = await client.get(_endpoint, queryParameters: {'offset': offset, 'limit': limit});
      final data = _extractResults(res.data);
      final items = data.map((item) => WorkoutSessionModel.fromJson(item as Map<String, dynamic>)).toList();
      final pagination = PaginationInfo.fromResponse(res.data is Map<String, dynamic> ? res.data : {'results': data}, offset, limit);
      return (items, pagination);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<WorkoutSessionModel> getSession(int id) async {
    try {
      final res = await client.get('$_endpoint$id/');
      return WorkoutSessionModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<WorkoutSessionModel> createSession(Map<String, dynamic> data) async {
    try {
      final res = await client.post(_endpoint, data: data);
      return WorkoutSessionModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<WorkoutSessionModel> updateSession(int id, Map<String, dynamic> data) async {
    try {
      final res = await client.patch('$_endpoint$id/', data: data);
      return WorkoutSessionModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<void> deleteSession(int id) async {
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
    throw ServerErrorFailure(debugMessage: 'Unexpected session payload format: ${payload.runtimeType}');
  }
}
