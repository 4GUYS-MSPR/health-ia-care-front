import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/errors/exercise_failure.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/exercise_remote_data_source.dart';
import '../models/exercise_model.dart';

class ExerciseRepositoryImpl with LoggerMixin implements ExerciseRepository {
  final ExerciseRemoteDataSource remoteDatasource;
  final NetworkInfo networkInfo;

  ExerciseRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  String get loggerName => 'Health.Data.ExerciseRepository';

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
  TaskEither<Failure, List<Exercise>> getAllExercises() {
    logger.finest('getAllExercises called');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final items = await remoteDatasource.getExercises();
          logger.fine('Retrieved ${items.length} exercises');
          return items;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch exercises', error, stackTrace);
          if (error is Failure) return error;
          return const ExercisesFetchFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Exercise> getExercise(int id) {
    logger.finest('getExercise called for id=$id');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final item = await remoteDatasource.getExercise(id);
          logger.fine('Retrieved exercise $id');
          return item;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch exercise $id', error, stackTrace);
          if (error is Failure) return error;
          return ExerciseNotFoundException(id: id, debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Exercise> createExercise(Exercise exercise) {
    logger.finest('createExercise called');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final data = ExerciseModel.fromEntity(exercise).toMap();

          final item = await remoteDatasource.createExercise(data);
          logger.fine('Exercise created with id=${item.id}');
          return item;
        },
        (error, stackTrace) {
          logger.severe('Failed to create exercise', error, stackTrace);
          if (error is Failure) return error;
          return const ExerciseCreationFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Exercise> updateExercise(int id, Exercise exercise) {
    logger.finest('updateExercise called for id=$id');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final data = ExerciseModel.fromEntity(exercise).toMap();

          final item = await remoteDatasource.updateExercise(id, data);
          logger.fine('Exercise $id updated');
          return item;
        },
        (error, stackTrace) {
          logger.severe('Failed to update exercise $id', error, stackTrace);
          if (error is Failure) return error;
          return ExerciseUpdateFailure(id: id, debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteExercise(int id) {
    logger.finest('deleteExercise called for id=$id');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          await remoteDatasource.deleteExercise(id);
          logger.fine('Exercise $id deleted');
          return unit;
        },
        (error, stackTrace) {
          logger.severe('Failed to delete exercise $id', error, stackTrace);
          if (error is Failure) return error;
          return ExerciseDeleteFailure(id: id, debugMessage: 'Unexpected error');
        },
      ),
    );
  }
}
