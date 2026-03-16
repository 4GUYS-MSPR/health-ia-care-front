import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/errors/session_failure.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_data_source.dart';
import '../models/workout_session_model.dart';

class SessionRepositoryImpl with LoggerMixin implements SessionRepository {
  final SessionRemoteDataSource remoteDatasource;
  final NetworkInfo networkInfo;

  SessionRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  String get loggerName => 'Health.Data.SessionRepository';

  TaskEither<Failure, Unit> _checkInternetConnection() {
    return TaskEither.tryCatch(
      () async {
        final isConnected = await networkInfo.isConnected;
        if (!isConnected) throw const NoInternetConnectionFailure();
        return unit;
      },
      (error, _) {
        if (error is Failure) return error;
        return const NoInternetConnectionFailure();
      },
    );
  }

  @override
  TaskEither<Failure, List<WorkoutSession>> getAllSessions() {
    logger.finest('getAllSessions called');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final items = await remoteDatasource.getSessions();
          logger.fine('Retrieved ${items.length} sessions');
          return items;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch sessions', error, stackTrace);
          if (error is Failure) return error;
          return const SessionsFetchFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, WorkoutSession> getSession(int id) {
    logger.finest('getSession called for id=$id');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final item = await remoteDatasource.getSession(id);
          logger.fine('Retrieved session $id');
          return item;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch session $id', error, stackTrace);
          if (error is Failure) return error;
          return SessionNotFoundException(id: id, debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, WorkoutSession> createSession(WorkoutSession session) {
    logger.finest('createSession called');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final data = WorkoutSessionModel.fromEntity(session).toMap();

          final item = await remoteDatasource.createSession(data);
          logger.fine('Session created with id=${item.id}');
          return item;
        },
        (error, stackTrace) {
          logger.severe('Failed to create session', error, stackTrace);
          if (error is Failure) return error;
          return const SessionCreationFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, WorkoutSession> updateSession(int id, WorkoutSession session) {
    logger.finest('updateSession called for id=$id');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final data = WorkoutSessionModel.fromEntity(session).toMap();

          final item = await remoteDatasource.updateSession(id, data);
          logger.fine('Session $id updated');
          return item;
        },
        (error, stackTrace) {
          logger.severe('Failed to update session $id', error, stackTrace);
          if (error is Failure) return error;
          return SessionUpdateFailure(id: id, debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteSession(int id) {
    logger.finest('deleteSession called for id=$id');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          await remoteDatasource.deleteSession(id);
          logger.fine('Session $id deleted');
          return unit;
        },
        (error, stackTrace) {
          logger.severe('Failed to delete session $id', error, stackTrace);
          if (error is Failure) return error;
          return SessionDeleteFailure(id: id, debugMessage: 'Unexpected error');
        },
      ),
    );
  }
}
