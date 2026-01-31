import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/network_failures.dart';
import '../../../../../core/errors/server_failures.dart';
import '../../../../../core/logging/logger_mixin.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/errors/auth_failures.dart';
import '../../../domain/usecases/login_usecase.dart';

part 'login_process_state.dart';

/// Cubit for managing the login process (API call, loading, success, failure).
class LoginProcessCubit extends Cubit<LoginProcessState> with LoggerMixin {
  final LoginUsecase loginUsecase;

  LoginProcessCubit({
    required this.loginUsecase,
  }) : super(const LoginProcessInitialState()) {
    logger.finest('LoginProcessCubit initialized');
  }

  @override
  String get loggerName => 'Authentication.Presentation.LoginProcessCubit';

  /// Attempts to log in with the given credentials.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    logger.finest('login called for $email');
    emit(const LoginProcessLoadingState());
    logger.fine('Starting login for $email');

    final result = await loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    ).run();

    result.fold(
      (failure) {
        if (failure is AuthEmptyCredentialsFailure) {
          logger.warning('Login failed: empty credentials');
        } else if (failure is AuthInvalidCredentialsFailure) {
          logger.warning('Login failed: invalid credentials');
        } else if (failure is NoInternetConnectionFailure) {
          logger.warning('Login failed: no internet connection');
        } else if (failure is ServerFailure) {
          logger.severe('Login failed: server failure ${failure.debugMessage}');
        } else if (failure is NetworkFailure) {
          logger.severe('Login failed: network failure ${failure.debugMessage}');
        } else {
          logger.severe('Login failed: ${failure.runtimeType} ${failure.debugMessage ?? ''}');
        }

        emit(LoginProcessFailureState(failure: failure));
      },
      (user) {
        logger.fine('Login succeeded for ${user.email}');
        emit(LoginProcessSuccessState(user: user));
      },
    );
  }
}
