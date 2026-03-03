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
  /// Persists the JWT [accessToken] in secure storage for later retrieval.
  Future<void> cacheAccessToken(String accessToken);

  /// Persists the JWT [refreshToken] in secure storage for later retrieval.
  Future<void> cacheRefreshToken(String refreshToken);

  /// Persists [user] in secure storage.
  Future<void> cacheUser(UserModel user);

  /// Clears any stored authentication-related data (tokens, user).
  Future<void> clearSession();

  /// Retrieves the last cached access token, or `null` if none is present.
  Future<String?> getLastAccessToken();

  /// Retrieves the last cached refresh token, or `null` if none is present.
  Future<String?> getLastRefreshToken();

  /// Retrieves the last cached [UserModel], or `null` if none is present.
  Future<UserModel?> getLastUser();
}

class AuthLocalDatasourceImpl with LoggerMixin implements AuthLocalDatasource {
  static const _cachedAccessToken = 'CACHED_ACCESS_TOKEN';
  static const _cachedRefreshToken = 'CACHED_REFRESH_TOKEN';
  static const _cachedUser = 'CACHED_USER';

  final FlutterSecureStorage secureStorage;

  AuthLocalDatasourceImpl({
    required this.secureStorage,
  });

  @override
  String get loggerName => 'Authentication.Data.AuthLocalDatasource';

  @override
  Future<void> cacheAccessToken(String accessToken) async {
    logger.finest('cacheAccessToken called');

    logger.fine('Caching access token to secure storage');
    try {
      await secureStorage.write(key: _cachedAccessToken, value: accessToken);
      logger.fine('Access token cached successfully');
    } catch (e, st) {
      logger.severe('Failed to cache access token', e, st);
      rethrow;
    }
  }

  @override
  Future<void> cacheRefreshToken(String refreshToken) async {
    logger.finest('cacheRefreshToken called');

    logger.fine('Caching refresh token to secure storage');
    try {
      await secureStorage.write(key: _cachedRefreshToken, value: refreshToken);
      logger.fine('Refresh token cached successfully');
    } catch (e, st) {
      logger.severe('Failed to cache refresh token', e, st);
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

      logger.finer('Deleting cached access token under $_cachedAccessToken');
      await secureStorage.delete(key: _cachedAccessToken);

      logger.finer('Deleting cached refresh token under $_cachedRefreshToken');
      await secureStorage.delete(key: _cachedRefreshToken);

      logger.fine('Session cleared successfully');
    } catch (e, st) {
      logger.severe('Failed to clear session', e, st);
      rethrow;
    }
  }

  @override
  Future<String?> getLastAccessToken() async {
    logger.finest('getLastAccessToken called');
    
    logger.fine('Retrieving last access token from secure storage');
    try {
      final token = await secureStorage.read(key: _cachedAccessToken);
      if (token != null) {
        logger.fine('Access token retrieved');
        logger.finer('Token length=${token.length}');
      } else {
        logger.fine('No access token found');
      }
      return token;
    } catch (e, st) {
      logger.severe('Failed to retrieve access token', e, st);
      rethrow;
    }
  }

  @override
  Future<String?> getLastRefreshToken() async {
    logger.finest('getLastRefreshToken called');
    
    logger.fine('Retrieving last refresh token from secure storage');
    try {
      final token = await secureStorage.read(key: _cachedRefreshToken);
      if (token != null) {
        logger.fine('Refresh token retrieved');
        logger.finer('Token length=${token.length}');
      } else {
        logger.fine('No refresh token found');
      }
      return token;
    } catch (e, st) {
      logger.severe('Failed to retrieve refresh token', e, st);
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
