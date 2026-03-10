import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_failures.dart';
import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/errors/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Repository implementation coordinating local cache, remote datasource,
/// and network checks for JWT authentication flows.
///
/// Responsibilities:
/// - Validate network availability before remote calls
/// - Delegate authentication to [AuthRemoteDatasource]
/// - Persist session state via [AuthLocalDatasource]
/// - Handle JWT access/refresh token lifecycle
class AuthRepositoryImpl with LoggerMixin implements AuthRepository {
  final AuthLocalDatasource localDatasource;
  final AuthRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  String get loggerName => 'Authentication.Data.AuthRepository';

  @override
  TaskEither<Failure, User> login({
    required String email,
    required String password,
  }) {
    logger.finest('login called for $email');
    logger.finer('Preparing to authenticate');

    return _checkInternetConnection()
        .flatMap((_) => _remoteLogin(email: email, password: password))
        .flatMap((authToken) => _cacheTokens(authToken))
        .flatMap((authToken) => _fetchUserProfile(authToken))
        .flatMap((result) => _cacheSession(authToken: result.$1, user: result.$2));
  }

  @override
  TaskEither<Failure, Unit> logout() {
    logger.finest('logout called');
    return TaskEither.tryCatch(
      () async {
        logger.fine('Clearing local session');
        await localDatasource.clearSession();
        logger.fine('Logout successful');
        return unit;
      },
      (error, stackTrace) {
        logger.severe('Logout failed', error, stackTrace);
        return UnknownFailure(debugMessage: error.toString());
      },
    );
  }

  @override
  TaskEither<Failure, String> refreshToken() {
    logger.finest('refreshToken called');
    return TaskEither.tryCatch(
      () async {
        final refreshToken = await localDatasource.getLastRefreshToken();
        if (refreshToken == null) {
          logger.warning('No cached refresh token available');
          throw AuthSessionExpiredFailure(debugMessage: 'No cached refresh token');
        }

        logger.fine('Refreshing access token via remote');
        final newTokenPair = await remoteDatasource.refreshToken(refreshToken);

        logger.fine('Caching new access token');
        await localDatasource.cacheAccessToken(newTokenPair.accessToken);

        logger.finer('New access token length=${newTokenPair.accessToken.length}');
        return newTokenPair.accessToken;
      },
      (error, stackTrace) {
        if (error is AuthFailure) return error;
        logger.severe('Token refresh failed', error, stackTrace);
        return AuthTokenRefreshFailure(debugMessage: error.toString());
      },
    );
  }

  @override
  TaskEither<Failure, String> retrieveToken() {
    logger.finest('retrieveToken called');
    return TaskEither.tryCatch(
      () async {
        final token = await localDatasource.getLastAccessToken();
        if (token != null && token.isNotEmpty) {
          logger.fine('Access token retrieved');
          logger.finer('Token length=${token.length}');
          return token;
        }
        logger.fine('No access token found');
        throw AuthSessionExpiredFailure();
      },
      (error, stackTrace) {
        logger.severe('Failed to retrieve token', error, stackTrace);
        return UnknownFailure(debugMessage: error.toString());
      },
    );
  }

  @override
  TaskEither<Failure, User?> retrieveUser() {
    logger.finest('retrieveUser called');
    return TaskEither.tryCatch(
      () async {
        final user = await localDatasource.getLastUser();
        if (user != null) {
          logger.fine('User retrieved: ${user.email}');
        } else {
          logger.fine('No user found');
        }
        return user;
      },
      (error, stackTrace) {
        logger.severe('Failed to retrieve user', error, stackTrace);
        return UnknownFailure(debugMessage: error.toString());
      },
    );
  }

  /// Persists tokens to local storage so that they are available to the
  /// [AuthInterceptor] for subsequent HTTP requests (e.g. fetching the
  /// user profile right after login).
  TaskEither<Failure, AuthToken> _cacheTokens(AuthToken authToken) {
    logger.finest('cacheTokens called');
    return TaskEither.tryCatch(
      () async {
        logger.fine('Caching tokens to secure storage');
        await localDatasource.cacheAccessToken(authToken.accessToken);
        await localDatasource.cacheRefreshToken(authToken.refreshToken);
        logger.fine('Tokens cached successfully');
        return authToken;
      },
      (error, stackTrace) {
        logger.severe('Failed to cache tokens', error, stackTrace);
        return UnknownFailure(debugMessage: error.toString());
      },
    );
  }

  TaskEither<Failure, User> _cacheSession({
    required AuthToken authToken,
    required UserModel user,
  }) {
    logger.finest('cacheSession called for ${user.email}');
    logger.finer('Access token length=${authToken.accessToken.length}');

    return TaskEither.tryCatch(
      () async {
        logger.fine('Caching user session');
        await localDatasource.cacheAccessToken(authToken.accessToken);
        await localDatasource.cacheRefreshToken(authToken.refreshToken);
        await localDatasource.cacheUser(user);
        logger.fine('User session cached successfully');
        return user;
      },
      (error, stackTrace) {
        logger.severe('Failed to cache session', error, stackTrace);
        return UnknownFailure(debugMessage: error.toString());
      },
    ).orElse(
      (failure) {
        logger.warning('Cache failed, continuing without cached session');
        return TaskEither.right(user);
      },
    );
  }

  TaskEither<Failure, bool> _checkInternetConnection() {
    return TaskEither<Failure, bool>.tryCatch(
      () async {
        logger.finest('checkInternetConnection called');
        logger.fine('Checking internet connection');
        final connected = await networkInfo.isConnected;
        logger.finer('Network connected: $connected');
        return connected;
      },
      (error, stackTrace) {
        logger.warning('Failed to check network status', error);
        return UnknownFailure(debugMessage: error.toString());
      },
    ).filterOrElse(
      (isConnected) => isConnected == true,
      (_) => NoInternetConnectionFailure(),
    );
  }

  TaskEither<Failure, AuthToken> _remoteLogin({
    required String email,
    required String password,
  }) {
    logger.finest('remoteLogin called for $email');

    return TaskEither.tryCatch(
      () async {
        logger.fine('Calling remote datasource login for $email');
        final authToken = await remoteDatasource.login(
          username: email,
          password: password,
        );
        return authToken as AuthToken;
      },
      (error, stackTrace) {
        // Preserve known auth, network or server failures
        if (error is AuthFailure || error is NetworkFailure || error is ServerFailure) {
          return (error as Failure);
        }

        logger.severe('Remote login failed', error, stackTrace);
        return UnknownFailure(debugMessage: error.toString());
      },
    );
  }

  TaskEither<Failure, (AuthToken, UserModel)> _fetchUserProfile(AuthToken authToken) {
    logger.finest('fetchUserProfile called');

    return TaskEither.tryCatch(
      () async {
        logger.fine('Fetching user profile with access token');
        final user = await remoteDatasource.getUserProfile(authToken.accessToken);
        logger.fine('User profile retrieved: ${user.email}');
        return (authToken, user);
      },
      (error, stackTrace) {
        // Preserve known auth, network or server failures
        if (error is AuthFailure || error is NetworkFailure || error is ServerFailure) {
          return (error as Failure);
        }

        logger.severe('Failed to fetch user profile', error, stackTrace);
        return UnknownFailure(debugMessage: error.toString());
      },
    );
  }
}
