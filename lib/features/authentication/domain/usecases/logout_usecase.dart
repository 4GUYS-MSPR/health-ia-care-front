import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Logout the current user via [AuthRepository].
class LogoutUsecase with LoggerMixin implements Usecase<Unit, NoParams> {
  /// Repository used to perform authentication operations.
  final AuthRepository repository;

  LogoutUsecase({
    required this.repository,
  });

  @override
  String get loggerName => 'Authentication.Domain.LogoutUsecase';

  /// Executes the logout flow.
  @override
  TaskEither<Failure, Unit> call([NoParams? params]) {
    logger.finest('LogoutUsecase called');

    logger.fine('Delegating logout to repository');
    return repository.logout();
  }
}
