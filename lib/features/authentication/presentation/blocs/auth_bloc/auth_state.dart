part of 'auth_bloc.dart';

/// Base class for authentication states emitted by [AuthBloc].
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Initial state before any authentication check has completed.
final class AuthInitialState extends AuthState {}

/// State representing an authenticated user.
///
/// Contains the authenticated [user] entity which the UI can consume.
final class AuthAuthenticatedState extends AuthState {
  /// The authenticated user.
  final User user;

  const AuthAuthenticatedState({
    required this.user,
  });

  @override
  List<Object> get props => [
    user,
  ];
}

/// State representing no authenticated user (signed out).
final class AuthUnauthenticatedState extends AuthState {}
