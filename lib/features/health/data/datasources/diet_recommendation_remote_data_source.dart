import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/shared/models/pagination_info.dart';
import '../models/diet_recommendation_model.dart';

abstract class DietRecommendationRemoteDataSource {
  Future<List<DietRecommendationModel>> getDietRecommendations();
  Future<(List<DietRecommendationModel>, PaginationInfo)> getDietRecommendationsPage({required int offset, required int limit});
  Future<DietRecommendationModel> getDietRecommendation(int id);
  Future<DietRecommendationModel> createDietRecommendation(Map<String, dynamic> data);
  Future<DietRecommendationModel> updateDietRecommendation(int id, Map<String, dynamic> data);
  Future<void> deleteDietRecommendation(int id);
}

class DietRecommendationRemoteDataSourceImpl implements DietRecommendationRemoteDataSource {
  static const _endpoint = '/api/diet_recommendation/';
  final Dio client;

  DietRecommendationRemoteDataSourceImpl({required this.client});

  @override
  Future<List<DietRecommendationModel>> getDietRecommendations() async {
    try {
      final res = await client.get(_endpoint);
      final data = _extractResults(res.data);
      return data.map((item) => DietRecommendationModel.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<(List<DietRecommendationModel>, PaginationInfo)> getDietRecommendationsPage({required int offset, required int limit}) async {
    try {
      final res = await client.get(_endpoint, queryParameters: {'offset': offset, 'limit': limit});
      final data = _extractResults(res.data);
      final items = data.map((item) => DietRecommendationModel.fromJson(item as Map<String, dynamic>)).toList();
      final pagination = PaginationInfo.fromResponse(res.data is Map<String, dynamic> ? res.data : {'results': data}, offset, limit);
      return (items, pagination);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<DietRecommendationModel> getDietRecommendation(int id) async {
    try {
      final res = await client.get('$_endpoint$id/');
      return DietRecommendationModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<DietRecommendationModel> createDietRecommendation(Map<String, dynamic> data) async {
    try {
      final res = await client.post(_endpoint, data: data);
      return DietRecommendationModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<DietRecommendationModel> updateDietRecommendation(int id, Map<String, dynamic> data) async {
    try {
      final res = await client.patch('$_endpoint$id/', data: data);
      return DietRecommendationModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<void> deleteDietRecommendation(int id) async {
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
    throw ServerErrorFailure(debugMessage: 'Unexpected diet recommendation payload format: ${payload.runtimeType}');
  }
}
