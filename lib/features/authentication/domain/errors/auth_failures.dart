import '../../../../core/errors/failures.dart';

/// Base class for authentication-related failures.
sealed class AuthFailure extends Failure {
  const AuthFailure({super.debugMessage});
}

/// Email or password is empty.
class AuthEmptyCredentialsFailure extends AuthFailure {
  const AuthEmptyCredentialsFailure({super.debugMessage});
}

/// Invalid credentials (wrong email/password combination).
class AuthInvalidCredentialsFailure extends AuthFailure {
  const AuthInvalidCredentialsFailure({super.debugMessage});
}

/// Session expired, user needs to re-authenticate.
class AuthSessionExpiredFailure extends AuthFailure {
  const AuthSessionExpiredFailure({super.debugMessage});
}

/// Token refresh failed.
class AuthTokenRefreshFailure extends AuthFailure {
  const AuthTokenRefreshFailure({super.debugMessage});
}
