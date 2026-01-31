import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../errors/auth_failures.dart';
import '../repositories/auth_repository.dart';

/// Handles user login by validating credentials and delegating to
/// [AuthRepository].
class LoginUsecase with LoggerMixin implements Usecase<User, LoginUsecaseParams> {
  /// Repository used to perform authentication operations.
  final AuthRepository repository;

  LoginUsecase({
    required this.repository,
  });

  @override
  String get loggerName => 'Authentication.Domain.LoginUsecase';

  /// Executes the login flow, returning a [Failure] on validation errors or
  /// the authenticated [User] on success.
  @override
  TaskEither<Failure, User> call(LoginUsecaseParams params) {
    logger.finest('LoginUsecase called');

    logger.finer('Validating login credentials');
    final formattedEmail = params.email.trim();
    final formattedPassword = params.password.trim();

    // Check for empty credentials
    if (formattedEmail.isEmpty || formattedPassword.isEmpty) {
      logger.warning('Login rejected: empty credentials');
      return TaskEither.left(AuthEmptyCredentialsFailure());
    }

    logger.fine('Login validation passed. Delegating to repository');
    return repository.login(
      email: formattedEmail,
      password: formattedPassword,
    );
  }
}

/// Parameters required by [LoginUsecase].
class LoginUsecaseParams extends Equatable {
  /// User email to authenticate with.
  final String email;

  /// User password to authenticate with.
  final String password;

  /// Creates a new instance of [LoginUsecaseParams].
  const LoginUsecaseParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [
    email,
    password,
  ];
}
