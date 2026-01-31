import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/nutrition_food.dart';
import '../../domain/errors/nutrition_failure.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_remote_data_source.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NutritionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  TaskEither<Failure, List<NutritionFood>> getFoods() {
    return TaskEither(() async {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(const NutritionConnectionFailure());
      }

      try {
        final foods = await remoteDataSource.getFoods();
        return Right(foods);
      } catch (e) {
        return Left(const NutritionServerFailure());
      }
    });
  }
}
