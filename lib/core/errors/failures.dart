import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
///
/// Failures represent expected error conditions that can occur during
/// business logic execution. They should be:
/// - Immutable and const-constructible
/// - Compared by type (not by message) for business logic
/// - Mapped to localized messages only in the presentation layer
///
/// Example usage:
/// ```dart
/// // In domain layer - define specific failures
/// class UserNotFoundFailure extends Failure {
///   final String userId;
///   const UserNotFoundFailure({required this.userId});
/// }
///
/// // In presentation layer - map to localized message
/// String getLocalizedMessage(Failure failure, AppLocalizations l10n) {
///   return switch (failure) {
///     UserNotFoundFailure(:final userId) => l10n.userNotFound(userId),
///     _ => l10n.unknownError,
///   };
/// }
/// ```
abstract class Failure extends Equatable {
  /// Optional details for debugging (not for display to users).
  /// Use this for technical information like error codes, stack traces, etc.
  final String? debugMessage;

  const Failure({
    this.debugMessage,
  });

  @override
  List<Object?> get props => [
    debugMessage,
  ];
}

/// A generic failure representing an unknown or unexpected error.
/// Use this when no specific `Failure` subclass applies.
class UnknownFailure extends Failure {
  const UnknownFailure({super.debugMessage});
}
