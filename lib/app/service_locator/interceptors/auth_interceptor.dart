import 'package:dio/dio.dart';

import '../../../core/logging/logger_mixin.dart';
import '../../../features/authentication/data/datasources/auth_local_datasource.dart';

/// Interceptor that adds the JWT access token to API requests and
/// automatically refreshes it on 401 responses.
///
/// On a 401, the interceptor attempts to use the stored refresh token
/// to obtain a new access token, updates local storage, and retries
/// the original request once.
class AuthInterceptor extends Interceptor with LoggerMixin {
  final AuthLocalDatasource authLocalDatasource;
  final Dio dio;

  /// Prevents concurrent refresh attempts.
  bool _isRefreshing = false;

  AuthInterceptor({
    required this.authLocalDatasource,
    required this.dio,
  });

  @override
  String get loggerName => 'Network.AuthInterceptor';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for JWT token endpoints
    if (_isTokenEndpoint(options.path)) {
      logger.finer('Skipping auth header for JWT endpoint');
      return handler.next(options);
    }

    try {
      final token = await authLocalDatasource.getLastAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        logger.finer('Added Bearer token to request: ${options.path}');
      } else {
        logger.warning('No access token available for request: ${options.path}');
      }
    } catch (e, st) {
      logger.severe('Error retrieving access token', e, st);
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 ||
        _isTokenEndpoint(err.requestOptions.path) ||
        _isRefreshing) {
      return handler.next(err);
    }

    logger.warning('Received 401 for ${err.requestOptions.path}, attempting token refresh');
    _isRefreshing = true;

    try {
      final refreshToken = await authLocalDatasource.getLastRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        logger.warning('No refresh token available, cannot retry');
        return handler.next(err);
      }

      // Call the refresh endpoint directly (bypasses this interceptor)
      final refreshResponse = await dio.post(
        '/api/token/refresh/',
        data: {'refresh': refreshToken},
      );

      final newAccessToken = refreshResponse.data['access'] as String?;
      if (newAccessToken == null || newAccessToken.isEmpty) {
        logger.warning('Refresh response did not contain an access token');
        return handler.next(err);
      }

      await authLocalDatasource.cacheAccessToken(newAccessToken);
      logger.fine('Access token refreshed successfully');

      // Retry the original request with the new token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';

      final response = await dio.fetch(opts);
      return handler.resolve(response);
    } catch (e, st) {
      logger.severe('Token refresh failed during retry', e, st);
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  bool _isTokenEndpoint(String path) {
    return path.contains('/api/token/');
  }
}
