import 'package:dio/dio.dart';

import '../../../core/logging/logger_mixin.dart';
import '../../../features/authentication/data/datasources/auth_local_datasource.dart';

/// Interceptor that adds the authentication token to API requests.
///
/// Retrieves the token from [AuthLocalDatasource] and adds it to
/// the Authorization header for each request.
class AuthInterceptor extends Interceptor with LoggerMixin {
  final AuthLocalDatasource authLocalDatasource;

  AuthInterceptor({required this.authLocalDatasource});

  @override
  String get loggerName => 'Network.AuthInterceptor';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login endpoint
    if (options.path.contains('/api/token/')) {
      logger.finer('Skipping auth header for login endpoint');
      return handler.next(options);
    }

    try {
      final token = await authLocalDatasource.getLastToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Token $token';
        logger.finer('Added auth token to request: ${options.path}');
      } else {
        logger.warning('No auth token available for request: ${options.path}');
      }
    } catch (e, st) {
      logger.severe('Error retrieving auth token', e, st);
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      logger.warning('Received 401 Unauthorized for: ${err.requestOptions.path}');
    }
    return handler.next(err);
  }
}
