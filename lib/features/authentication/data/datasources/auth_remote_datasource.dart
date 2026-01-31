import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../domain/errors/auth_failures.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Remote datasource responsible for authentication network calls.
///
/// Uses an HTTP client to call the server login endpoint and returns a
/// [UserModel] on success.
abstract interface class AuthRemoteDatasource {
  Future<AuthTokenModel> login({
    required String username,
    required String password,
  });
  Future<UserModel> getUserProfile(String token);
}

class AuthRemoteDatasourceImpl with LoggerMixin implements AuthRemoteDatasource {
  static const _loginEndpoint = '/api/token/';
  static const _userEndpoint = '/api/users/me/';

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

      final token = res.data['token'] as String?;
      if (token == null || token.isEmpty) {
        logger.severe('No token returned from login response for $username');
        throw ServerErrorFailure(debugMessage: 'No token returned in login response');
      }

      logger.fine('Login successful for $username');
      logger.finer('Received token length=${token.length}');

      return AuthTokenModel.fromMap(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 400) {
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
  Future<UserModel> getUserProfile(String token) async {
    logger.finest('getUserProfile called');
    logger.finer('Sending GET to $_userEndpoint');

    try {
      final res = await authClient.get(
        _userEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        ),
      );

      return UserModel.fromMap(res.data);
    } on DioException catch (e) {
      throw ServerErrorFailure(debugMessage: e.message);
    }
  }
}
