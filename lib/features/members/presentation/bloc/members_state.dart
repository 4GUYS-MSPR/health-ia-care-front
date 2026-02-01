part of 'members_bloc.dart';

/// Base class for all member states.
sealed class MembersState extends Equatable {
  const MembersState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
final class MembersInitial extends MembersState {
  const MembersInitial();
}

/// Loading state while fetching members.
final class MembersLoading extends MembersState {
  const MembersLoading();
}

/// Loaded state with members list.
final class MembersLoaded extends MembersState {
  final List<Member> members;

  const MembersLoaded({required this.members});

  @override
  List<Object?> get props => [members];
}

/// Error state with failure information.
final class MembersError extends MembersState {
  final Failure failure;

  const MembersError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

/// State while creating a member.
final class MemberCreating extends MembersState {
  final List<Member> existingMembers;

  const MemberCreating({required this.existingMembers});

  @override
  List<Object?> get props => [existingMembers];
}

/// State after member is created successfully.
final class MemberCreated extends MembersState {
  final Member member;
  final List<Member> allMembers;

  const MemberCreated({
    required this.member,
    required this.allMembers,
  });

  @override
  List<Object?> get props => [member, allMembers];
}

/// State while updating a member.
final class MemberUpdating extends MembersState {
  final List<Member> existingMembers;
  final int updatingId;

  const MemberUpdating({
    required this.existingMembers,
    required this.updatingId,
  });

  @override
  List<Object?> get props => [existingMembers, updatingId];
}

/// State after member is updated successfully.
final class MemberUpdated extends MembersState {
  final Member member;
  final List<Member> allMembers;

  const MemberUpdated({
    required this.member,
    required this.allMembers,
  });

  @override
  List<Object?> get props => [member, allMembers];
}

/// State while deleting a member.
final class MemberDeleting extends MembersState {
  final List<Member> existingMembers;
  final int deletingId;

  const MemberDeleting({
    required this.existingMembers,
    required this.deletingId,
  });

  @override
  List<Object?> get props => [existingMembers, deletingId];
}

/// State after member is deleted successfully.
final class MemberDeleted extends MembersState {
  final int deletedId;
  final List<Member> remainingMembers;

  const MemberDeleted({
    required this.deletedId,
    required this.remainingMembers,
  });

  @override
  List<Object?> get props => [deletedId, remainingMembers];
}
