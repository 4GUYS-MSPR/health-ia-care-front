import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Retrieves the stored authentication token via [AuthRepository].
class RetrieveTokenUsecase with LoggerMixin implements Usecase<String, NoParams> {
  /// Repository used to perform authentication operations.
  final AuthRepository repository;

  RetrieveTokenUsecase({
    required this.repository,
  });

  @override
  String get loggerName => 'Authentication.Domain.RetrieveTokenUsecase';

  /// Retrieves the current auth token if present.
  @override
  TaskEither<Failure, String> call([NoParams? params]) {
    logger.finest('RetrieveTokenUsecase called');
    logger.fine('Retrieving token from repository');
    return repository.retrieveToken();
  }
}
