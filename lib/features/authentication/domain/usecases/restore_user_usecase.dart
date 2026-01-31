import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Restores the authenticated user from persisted state.
class RestoreUserUsecase with LoggerMixin implements Usecase<User?, NoParams> {
  /// Repository used to perform authentication operations.
  final AuthRepository repository;

  RestoreUserUsecase({
    required this.repository,
  });

  @override
  String get loggerName => 'Authentication.Domain.RestoreUserUsecase';

  /// Attempts to refresh the token and retrieve the current user.
  @override
  TaskEither<Failure, User?> call([NoParams? params]) {
    logger.finest('RestoreUserUsecase called');
    logger.finer('Requesting token refresh');
    repository.refreshToken();
    logger.fine('Retrieving user from repository');
    return repository.retrieveUser();
  }
}
