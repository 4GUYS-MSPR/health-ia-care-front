import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/logging/logger_mixin.dart';
import '../models/user_model.dart';

/// Local datasource responsible for persisting authentication data.
///
/// Uses platform secure storage to store small secrets such as tokens and
/// short-lived encrypted passwords. Implementations must avoid logging
/// sensitive values (raw passwords or token contents); logs should indicate
/// only presence/absence or non-sensitive metadata.
abstract interface class AuthLocalDatasource {
  /// Persists [token] in secure storage for later retrieval.
  Future<void> cacheToken(String token);

  /// Persists [user] in secure storage.
  Future<void> cacheUser(UserModel user);

  /// Clears any stored authentication-related data (token, user).
  Future<void> clearSession();

  /// Retrieves the last cached token, or `null` if none is present.
  Future<String?> getLastToken();

  /// Retrieves the last cached [UserModel], or `null` if none is present.
  Future<UserModel?> getLastUser();
}

class AuthLocalDatasourceImpl with LoggerMixin implements AuthLocalDatasource {
  static const _cachedToken = 'CACHED_TOKEN';
  static const _cachedUser = 'CACHED_USER';

  final FlutterSecureStorage secureStorage;

  AuthLocalDatasourceImpl({
    required this.secureStorage,
  });

  @override
  String get loggerName => 'Authentication.Data.AuthLocalDatasource';

  @override
  Future<void> cacheToken(String token) async {
    logger.finest('cacheToken called');

    logger.fine('Caching user token to secure storage');
    try {
      await secureStorage.write(key: _cachedToken, value: token);
      logger.fine('Token cached successfully');
    } catch (e, st) {
      logger.severe('Failed to cache token', e, st);
      rethrow;
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    logger.finest('cacheUser called for ${user.email}');

    logger.fine('Caching user "${user.email}" to secure storage');
    try {
      await secureStorage.write(key: _cachedUser, value: user.toJson());
      logger.fine('User cached successfully');
    } catch (e, st) {
      logger.severe('Failed to cache user', e, st);
      rethrow;
    }
  }

  @override
  Future<void> clearSession() async {
    logger.finest('clearSession called');

    logger.fine('Deleting user session from secure storage');
    try {
      logger.finer('Deleting cached user under $_cachedUser');
      await secureStorage.delete(key: _cachedUser);

      logger.finer('Deleting cached token under $_cachedToken');
      await secureStorage.delete(key: _cachedToken);

      logger.fine('Session cleared successfully');
    } catch (e, st) {
      logger.severe('Failed to clear session', e, st);
      rethrow;
    }
  }

  @override
  Future<String?> getLastToken() async {
    logger.finest('getLastToken called');
    
    logger.fine('Retrieving last token from secure storage');
    try {
      final token = await secureStorage.read(key: _cachedToken);
      if (token != null) {
        logger.fine('Token retrieved');
        logger.finer('Token length=${token.length}');
      } else {
        logger.fine('No token found');
      }
      return token;
    } catch (e, st) {
      logger.severe('Failed to retrieve token', e, st);
      rethrow;
    }
  }

  @override
  Future<UserModel?> getLastUser() async {
    logger.finest('getLastUser called');
    logger.fine('Retrieving last user from secure storage');
    try {
      final userJson = await secureStorage.read(key: _cachedUser);
      if (userJson != null) {
        final user = UserModel.fromJson(userJson);
        logger.fine('User retrieved: ${user.email}');
        logger.finer('User payload size=${userJson.length}');
        return user;
      } else {
        logger.fine('No user found');
      }
      return null;
    } catch (e, st) {
      logger.severe('Failed to retrieve user', e, st);
      rethrow;
    }
  }
}
