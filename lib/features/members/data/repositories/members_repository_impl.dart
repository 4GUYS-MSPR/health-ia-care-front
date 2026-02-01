import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/errors/members_failures.dart';
import '../../domain/repositories/members_repository.dart';
import '../datasources/members_remote_datasources.dart';

/// Repository implementation for member operations.
///
/// Coordinates network checks and remote datasource calls.
class MembersRepositoryImpl with LoggerMixin implements MembersRepository {
  final MembersRemoteDatasources remoteDatasources;
  final NetworkInfo networkInfo;

  MembersRepositoryImpl({
    required this.remoteDatasources,
    required this.networkInfo,
  });

  @override
  String get loggerName => 'Members.Data.MembersRepository';

  /// Checks for internet connectivity.
  TaskEither<Failure, Unit> _checkInternetConnection() {
    return TaskEither.tryCatch(
      () async {
        final isConnected = await networkInfo.isConnected;
        if (!isConnected) {
          logger.warning('No internet connection');
          throw const NoInternetConnectionFailure();
        }
        return unit;
      },
      (error, _) {
        if (error is Failure) return error;
        return const NoInternetConnectionFailure();
      },
    );
  }

  @override
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
  }) {
    logger.finest('createMember called');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final member = await remoteDatasources.createMember(
            age: age,
            bmi: bmi,
            fatPercentage: fatPercentage,
            height: height,
            weight: weight,
            workoutFrequency: workoutFrequency,
            objectives: objectives,
            gender: gender,
            level: level,
            subscription: subscription,
          );
          logger.fine('Member created with id=${member.id}');
          return member;
        },
        (error, stackTrace) {
          logger.severe('Failed to create member', error, stackTrace);
          if (error is Failure) return error;
          return const MemberCreationFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteMember(int id) {
    logger.finest('deleteMember called for id=$id');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          await remoteDatasources.deleteMember(id);
          logger.fine('Member $id deleted');
          return unit;
        },
        (error, stackTrace) {
          logger.severe('Failed to delete member $id', error, stackTrace);
          if (error is Failure) return error;
          return MemberDeleteFailure(
            memberId: id,
            debugMessage: 'Unexpected error',
          );
        },
      ),
    );
  }

  @override
  TaskEither<Failure, List<Member>> getAllMembers() {
    logger.finest('getAllMembers called');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final members = await remoteDatasources.getAllMembers();
          logger.fine('Retrieved ${members.length} members');
          return members;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch members', error, stackTrace);
          if (error is Failure) return error;
          return const MembersFetchFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Member> getMember(int id) {
    logger.finest('getMember called for id=$id');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final member = await remoteDatasources.getMember(id);
          logger.fine('Retrieved member $id');
          return member;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch member $id', error, stackTrace);
          if (error is Failure) return error;
          return MemberNotFoundFailure(
            memberId: id,
            debugMessage: 'Unexpected error',
          );
        },
      ),
    );
  }

  @override
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
  }) {
    logger.finest('updateMember called for id=$id');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final member = await remoteDatasources.updateMember(
            id,
            age: age,
            bmi: bmi,
            fatPercentage: fatPercentage,
            height: height,
            weight: weight,
            workoutFrequency: workoutFrequency,
            objectives: objectives,
            gender: gender,
            level: level,
            subscription: subscription,
          );
          logger.fine('Member $id updated');
          return member;
        },
        (error, stackTrace) {
          logger.severe('Failed to update member $id', error, stackTrace);
          if (error is Failure) return error;
          return MemberUpdateFailure(
            memberId: id,
            debugMessage: 'Unexpected error',
          );
        },
      ),
    );
  }
}
