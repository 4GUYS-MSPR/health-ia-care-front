part of 'auth_bloc.dart';

/// Base class for authentication-related events handled by [AuthBloc].
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Event to attempt restoring a previously cached user (e.g., on startup).
final class AuthRestoreUserEvent extends AuthEvent {}

/// Event to request a logout and clear any cached session data.
final class AuthLogoutEvent extends AuthEvent {}

/// Event to set the authenticated state with the provided [user].
final class AuthSetAuthenticatedEvent extends AuthEvent {
  /// The authenticated user to set in state.
  final User user;

  const AuthSetAuthenticatedEvent({
    required this.user,
  });

  @override
  List<Object> get props => [
    user,
  ];
}
