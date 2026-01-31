import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_failures.dart';
import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/errors/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Repository implementation coordinating local cache, remote datasource,
/// encryption, and network checks for authentication flows.
///
/// Responsibilities:
/// - Validate network availability before remote calls
/// - Delegate authentication to [AuthRemoteDatasource]
/// - Persist session state via [AuthLocalDatasource]
/// - Use [AuthEncryptionService] to encrypt passwords when required
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
        .flatMap((token) => _fetchUserProfile(token))
        .flatMap((result) => _cacheSession(token: result.$1, user: result.$2));
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
        final token = await localDatasource.getLastToken();
        if (token == null) {
          logger.warning('No cached token available to refresh');
          throw AuthSessionExpiredFailure(debugMessage: 'No cached token');
        }

        logger.fine('Returning cached token');
        logger.finer('Token length=${token.length}');
        return token;
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
        final token = await localDatasource.getLastToken();
        if (token != null && token.isNotEmpty) {
          logger.fine('Token retrieved');
          logger.finer('Token length=${token.length}');
          return token;
        }
        logger.fine('No token found');
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

  TaskEither<Failure, User> _cacheSession({
    required String token,
    required UserModel user,
  }) {
    logger.finest('cacheSession called for ${user.email}');
    logger.finer('Token length=${token.length}');

    return TaskEither.tryCatch(
      () async {
        logger.fine('Caching user session');
        await localDatasource.cacheToken(token);
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

  TaskEither<Failure, String> _remoteLogin({
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
        return authToken.token;
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

  TaskEither<Failure, (String, UserModel)> _fetchUserProfile(String token) {
    logger.finest('fetchUserProfile called');

    return TaskEither.tryCatch(
      () async {
        logger.fine('Fetching user profile with token');
        final user = await remoteDatasource.getUserProfile(token);
        logger.fine('User profile retrieved: ${user.email}');
        return (token, user);
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
