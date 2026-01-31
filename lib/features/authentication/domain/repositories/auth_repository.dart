import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Repository interface that exposes authentication-related operations.
///
/// All methods return a [TaskEither] where the left side contains a
/// [Failure] describing what went wrong and the right side the successful
/// result. Implementations should avoid logging sensitive data (passwords,
/// full tokens) and must persist tokens and user data securely according to
/// the platform's best practices.
abstract interface class AuthRepository {
  /// Attempts to authenticate a user with [email] and [password].
  ///
  /// On success returns the authenticated [User]. On failure returns an
  /// appropriate [Failure] (network error, invalid credentials, etc.).
  TaskEither<Failure, User> login({
    required String email,
    required String password,
  });

  /// Signs the current user out and clears local session state.
  ///
  /// Returns [Unit] on success or a [Failure] on error.
  TaskEither<Failure, Unit> logout();

  /// Attempts to refresh and return a new authentication token.
  ///
  /// Implementations should securely update any stored token state on
  /// success and return the refreshed token string.
  TaskEither<Failure, String> refreshToken();

  /// Retrieves the current stored authentication token, if any.
  ///
  /// Returns the token on success or a [Failure] if retrieval fails.
  TaskEither<Failure, String> retrieveToken();

  /// Retrieves the current authenticated [User], or `null` if none is
  /// available (not authenticated).
  TaskEither<Failure, User?> retrieveUser();
}
