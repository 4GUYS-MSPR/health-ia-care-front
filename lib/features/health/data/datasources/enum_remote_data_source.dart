import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../models/enum_item_model.dart';

abstract class HealthEnumRemoteDataSource {
  /// Fetches the list of enum items for the given Django model [name].
  Future<List<EnumItemModel>> getEnumValues(String name);

  /// Tries several model names and returns the first successful non-empty list.
  Future<List<EnumItemModel>> getFirstAvailableEnumValues(List<String> modelNames);
}

class HealthEnumRemoteDataSourceImpl implements HealthEnumRemoteDataSource {
  static const _enumEndpoint = '/api/enum/';

  final Dio client;

  HealthEnumRemoteDataSourceImpl({required this.client});

  @override
  Future<List<EnumItemModel>> getEnumValues(String name) async {
    try {
      final res = await client.get('$_enumEndpoint$name/');
      final payload = res.data;
      final List<dynamic> results = payload is Map
          ? ((payload['results'] as List?) ?? [])
          : (payload as List? ?? []);
      return results.whereType<Map<String, dynamic>>().map(EnumItemModel.fromJson).toList();
    } on DioException catch (e) {
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<List<EnumItemModel>> getFirstAvailableEnumValues(List<String> modelNames) async {
    ServerErrorFailure? lastFailure;

    for (final rawName in modelNames) {
      final name = rawName.trim();
      if (name.isEmpty) continue;

      try {
        final values = await getEnumValues(name);
        if (values.isNotEmpty) {
          return values;
        }
      } on ServerErrorFailure catch (e) {
        lastFailure = e;
      }
    }

    if (lastFailure != null) {
      throw lastFailure;
    }

    return const <EnumItemModel>[];
  }
}
