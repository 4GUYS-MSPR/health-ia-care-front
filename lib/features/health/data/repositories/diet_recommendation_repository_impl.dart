import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/diet_recommendation.dart';
import '../../domain/errors/diet_recommendation_failure.dart';
import '../../domain/repositories/diet_recommendation_repository.dart';
import '../datasources/diet_recommendation_remote_data_source.dart';
import '../models/diet_recommendation_model.dart';

class DietRecommendationRepositoryImpl with LoggerMixin implements DietRecommendationRepository {
  final DietRecommendationRemoteDataSource remoteDatasource;
  final NetworkInfo networkInfo;

  DietRecommendationRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  String get loggerName => 'Health.Data.DietRecommendationRepository';

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
  TaskEither<Failure, List<DietRecommendation>> getAllDietRecommendations() {
    logger.finest('getAllDietRecommendations called');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final items = await remoteDatasource.getDietRecommendations();
          logger.fine('Retrieved ${items.length} diet recommendations');
          return items;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch diet recommendations', error, stackTrace);
          if (error is Failure) return error;
          return const DietRecommendationsFetchFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, DietRecommendation> getDietRecommendation(int id) {
    logger.finest('getDietRecommendation called for id=$id');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final item = await remoteDatasource.getDietRecommendation(id);
          logger.fine('Retrieved diet recommendation $id');
          return item;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch diet recommendation $id', error, stackTrace);
          if (error is Failure) return error;
          return DietRecommendationNotFoundException(id: id, debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, DietRecommendation> createDietRecommendation(
    DietRecommendation recommendation,
  ) {
    logger.finest('createDietRecommendation called');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final data = DietRecommendationModel.fromEntity(recommendation).toMap();
          final item = await remoteDatasource.createDietRecommendation(data);
          logger.fine('Diet recommendation created with id=${item.id}');
          return item;
        },
        (error, stackTrace) {
          logger.severe('Failed to create diet recommendation', error, stackTrace);
          if (error is Failure) return error;
          return const DietRecommendationCreationFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, DietRecommendation> updateDietRecommendation(
    int id,
    DietRecommendation recommendation,
  ) {
    logger.finest('updateDietRecommendation called for id=$id');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final data = DietRecommendationModel.fromEntity(recommendation).toMap();
          final item = await remoteDatasource.updateDietRecommendation(id, data);
          logger.fine('Diet recommendation $id updated');
          return item;
        },
        (error, stackTrace) {
          logger.severe('Failed to update diet recommendation $id', error, stackTrace);
          if (error is Failure) return error;
          return DietRecommendationUpdateFailure(id: id, debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteDietRecommendation(int id) {
    logger.finest('deleteDietRecommendation called for id=$id');
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          await remoteDatasource.deleteDietRecommendation(id);
          logger.fine('Diet recommendation $id deleted');
          return unit;
        },
        (error, stackTrace) {
          logger.severe('Failed to delete diet recommendation $id', error, stackTrace);
          if (error is Failure) return error;
          return DietRecommendationDeleteFailure(id: id, debugMessage: 'Unexpected error');
        },
      ),
    );
  }
}
