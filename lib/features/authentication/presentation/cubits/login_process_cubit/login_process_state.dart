part of 'login_process_cubit.dart';

/// Base state for the login process.
sealed class LoginProcessState extends Equatable {
  const LoginProcessState();

  @override
  List<Object> get props => [];
}

/// Initial state - no login attempt yet.
final class LoginProcessInitialState extends LoginProcessState {
  const LoginProcessInitialState();
}

/// Loading state - login in progress.
final class LoginProcessLoadingState extends LoginProcessState {
  const LoginProcessLoadingState();
}

/// Success state - login succeeded.
final class LoginProcessSuccessState extends LoginProcessState {
  final User user;

  const LoginProcessSuccessState({required this.user});

  @override
  List<Object> get props => [user];
}

/// Failure state - login failed.
final class LoginProcessFailureState extends LoginProcessState {
  final Failure failure;

  const LoginProcessFailureState({required this.failure});

  @override
  List<Object> get props => [failure];
}
