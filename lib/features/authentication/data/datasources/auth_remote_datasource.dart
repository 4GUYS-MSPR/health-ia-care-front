import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../domain/errors/auth_failures.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Remote datasource responsible for authentication network calls.
///
/// Uses an HTTP client to call the server JWT endpoints and returns
/// token pairs or user data on success.
abstract interface class AuthRemoteDatasource {
  Future<AuthTokenModel> login({
    required String username,
    required String password,
  });
  Future<AuthTokenModel> refreshToken(String refreshToken);
  Future<UserModel> getUserProfile(String accessToken);
}

class AuthRemoteDatasourceImpl with LoggerMixin implements AuthRemoteDatasource {
  static const _loginEndpoint = '/api/token/';
  static const _refreshEndpoint = '/api/token/refresh/';
  static const _userEndpoint = '/api/user/me/';

  final Dio authClient;

  AuthRemoteDatasourceImpl({
    required this.authClient,
  });

  @override
  String get loggerName => 'Authentication.Data.AuthRemoteDatasource';

  @override
  Future<AuthTokenModel> login({
    required String username,
    required String password,
  }) async {
    logger.finest('login called for $username');
    logger.finer('Sending POST to $_loginEndpoint for user $username');

    try {
      final res = await authClient.post(
        _loginEndpoint,
        data: {
          "username": username,
          "password": password,
        },
      );

      final access = res.data['access'] as String?;
      final refresh = res.data['refresh'] as String?;
      if (access == null || access.isEmpty || refresh == null || refresh.isEmpty) {
        logger.severe('Missing tokens in login response for $username');
        throw ServerErrorFailure(debugMessage: 'Missing tokens in login response');
      }

      logger.fine('Login successful for $username');
      logger.finer('Received access token length=${access.length}');

      return AuthTokenModel.fromMap(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        logger.warning('Invalid credentials for $username');
        throw AuthInvalidCredentialsFailure(debugMessage: e.message);
      }
      logger.severe('Server error during login for $username', e, st);
      throw ServerErrorFailure(debugMessage: e.message);
    } catch (e, st) {
      logger.severe('Unexpected error during login for $username', e, st);
      rethrow;
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    logger.finest('refreshToken called');
    logger.finer('Sending POST to $_refreshEndpoint');

    try {
      final res = await authClient.post(
        _refreshEndpoint,
        data: {
          "refresh": refreshToken,
        },
      );

      final access = res.data['access'] as String?;
      if (access == null || access.isEmpty) {
        logger.severe('No access token returned from refresh');
        throw ServerErrorFailure(debugMessage: 'No access token in refresh response');
      }

      logger.fine('Token refresh successful');
      logger.finer('Received new access token length=${access.length}');

      return AuthTokenModel(
        accessToken: access,
        refreshToken: refreshToken,
      );
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 401) {
        logger.warning('Refresh token expired or invalid');
        throw AuthSessionExpiredFailure(debugMessage: e.message);
      }
      logger.severe('Server error during token refresh', e, st);
      throw ServerErrorFailure(debugMessage: e.message);
    } catch (e, st) {
      logger.severe('Unexpected error during token refresh', e, st);
      rethrow;
    }
  }

  @override
  Future<UserModel> getUserProfile(String accessToken) async {
    logger.finest('getUserProfile called');
    logger.finer('Sending GET to $_userEndpoint');

    try {
      final res = await authClient.get(
        _userEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return UserModel.fromMap(res.data);
    } on DioException catch (e) {
      throw ServerErrorFailure(debugMessage: e.message);
    }
  }
}
