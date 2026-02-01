import '../../../../core/errors/failures.dart';

/// Base class for member-related failures.
sealed class MemberFailure extends Failure {
  const MemberFailure({super.debugMessage});
}

/// Member was not found.
class MemberNotFoundFailure extends MemberFailure {
  final int memberId;

  const MemberNotFoundFailure({
    required this.memberId,
    super.debugMessage,
  });

  @override
  List<Object?> get props => [
    memberId,
    debugMessage,
  ];
}

/// Failed to create a new member.
class MemberCreationFailure extends MemberFailure {
  const MemberCreationFailure({super.debugMessage});
}

/// Failed to update member.
class MemberUpdateFailure extends MemberFailure {
  final int memberId;

  const MemberUpdateFailure({
    required this.memberId,
    super.debugMessage,
  });

  @override
  List<Object?> get props => [
    memberId,
    debugMessage,
  ];
}

/// Failed to delete member.
class MemberDeleteFailure extends MemberFailure {
  final int memberId;

  const MemberDeleteFailure({
    required this.memberId,
    super.debugMessage,
  });

  @override
  List<Object?> get props => [
    memberId,
    debugMessage,
  ];
}

/// Failed to fetch members list.
class MembersFetchFailure extends MemberFailure {
  const MembersFetchFailure({super.debugMessage});
}

/// Validation error for member data.
class MemberValidationFailure extends MemberFailure {
  final String field;

  const MemberValidationFailure({
    required this.field,
    super.debugMessage,
  });

  @override
  List<Object?> get props => [
    field,
    debugMessage,
  ];
}
