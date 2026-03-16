import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_failures.dart';
import '../../../../core/errors/server_failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/enum_item.dart';
import '../../domain/repositories/enum_repository.dart';
import '../datasources/enum_remote_data_source.dart';

class EnumRepositoryImpl implements EnumRepository {
  final HealthEnumRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EnumRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

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
  TaskEither<Failure, List<EnumItem>> getEnumValues(String name) {
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final items = await remoteDataSource.getEnumValues(name);
          return items.cast<EnumItem>();
        },
        (error, _) {
          if (error is ServerErrorFailure) return error;
          return ServerErrorFailure(debugMessage: error.toString());
        },
      ),
    );
  }

  @override
  TaskEither<Failure, List<EnumItem>> getFirstAvailableEnumValues(List<String> modelNames) {
    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final items = await remoteDataSource.getFirstAvailableEnumValues(modelNames);
          return items.cast<EnumItem>();
        },
        (error, _) {
          if (error is ServerErrorFailure) return error;
          return ServerErrorFailure(debugMessage: error.toString());
        },
      ),
    );
  }
}
