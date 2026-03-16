import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/member.dart';

/// Repository interface for member operations.
abstract interface class MembersRepository {
  /// Gets all members.
  TaskEither<Failure, List<Member>> getAllMembers();

  /// Creates a new member with the given data.
  TaskEither<Failure, Member> createMember(Member member);

  /// Gets a single member by [id].
  TaskEither<Failure, Member> getMember(int id);

  /// Updates a member by [id] with partial data.
  TaskEither<Failure, Member> updateMember(int id, Member member);

  /// Deletes a member by [id].
  TaskEither<Failure, Unit> deleteMember(int id);
}
