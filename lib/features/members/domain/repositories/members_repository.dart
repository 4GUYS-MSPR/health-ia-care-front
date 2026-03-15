import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/gender.dart';
import '../entities/level.dart';
import '../entities/member.dart';
import '../entities/objective.dart';
import '../entities/subscription.dart';

/// Repository interface for member operations.
abstract interface class MembersRepository {
  /// Gets all members.
  TaskEither<Failure, List<Member>> getAllMembers();

  /// Creates a new member with the given data.
  TaskEither<Failure, Member> createMember({
    int? age,
    required double bmi,
    required double fatPercentage,
    required double height,
    required double weight,
    required int workoutFrequency,
    List<Objective> objectives = const [],
    required Gender gender,
    required Level level,
    required Subscription subscription,
  });

  /// Gets a single member by [id].
  TaskEither<Failure, Member> getMember(int id);

  /// Updates a member by [id] with partial data.
  TaskEither<Failure, Member> updateMember(
    int id, {
    int? age,
    double? bmi,
    double? fatPercentage,
    double? height,
    double? weight,
    int? workoutFrequency,
    List<Objective>? objectives,
    Gender? gender,
    Level? level,
    Subscription? subscription,
  });

  /// Deletes a member by [id].
  TaskEither<Failure, Unit> deleteMember(int id);
}
