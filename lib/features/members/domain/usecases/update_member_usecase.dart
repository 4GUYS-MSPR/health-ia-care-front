import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/gender.dart';
import '../entities/level.dart';
import '../entities/member.dart';
import '../entities/objective.dart';
import '../entities/subscription.dart';
import '../errors/members_failures.dart';
import '../repositories/members_repository.dart';

/// Updates an existing member with validation.
class UpdateMemberUsecase with LoggerMixin implements Usecase<Member, UpdateMemberUsecaseParams> {
  final MembersRepository repository;

  UpdateMemberUsecase({required this.repository});

  @override
  String get loggerName => 'Members.Domain.UpdateMemberUsecase';

  @override
  TaskEither<Failure, Member> call(UpdateMemberUsecaseParams params) {
    logger.finest('UpdateMemberUsecase called for id=${params.id}');

    // Validation
    if (params.height != null && params.height! <= 0) {
      logger.warning('Validation failed: invalid height');
      return TaskEither.left(
        const MemberValidationFailure(
          field: 'height',
          debugMessage: 'Height must be greater than 0',
        ),
      );
    }

    if (params.weight != null && params.weight! <= 0) {
      logger.warning('Validation failed: invalid weight');
      return TaskEither.left(
        const MemberValidationFailure(
          field: 'weight',
          debugMessage: 'Weight must be greater than 0',
        ),
      );
    }

    if (params.workoutFrequency != null && params.workoutFrequency! < 0) {
      logger.warning('Validation failed: invalid workout frequency');
      return TaskEither.left(
        const MemberValidationFailure(
          field: 'workoutFrequency',
          debugMessage: 'Workout frequency cannot be negative',
        ),
      );
    }

    logger.fine('Validation passed, delegating to repository');
    return repository.updateMember(
      params.id,
      age: params.age,
      bmi: params.bmi,
      fatPercentage: params.fatPercentage,
      height: params.height,
      weight: params.weight,
      workoutFrequency: params.workoutFrequency,
      objectives: params.objectives,
      gender: params.gender,
      level: params.level,
      subscription: params.subscription,
    );
  }
}

/// Parameters for [UpdateMemberUsecase].
class UpdateMemberUsecaseParams extends Equatable {
  final int id;
  final int? age;
  final double? bmi;
  final double? fatPercentage;
  final double? height;
  final double? weight;
  final int? workoutFrequency;
  final List<Objective>? objectives;
  final Gender? gender;
  final Level? level;
  final Subscription? subscription;

  const UpdateMemberUsecaseParams({
    required this.id,
    this.age,
    this.bmi,
    this.fatPercentage,
    this.height,
    this.weight,
    this.workoutFrequency,
    this.objectives,
    this.gender,
    this.level,
    this.subscription,
  });

  @override
  List<Object?> get props => [
    id,
    age,
    bmi,
    fatPercentage,
    height,
    weight,
    workoutFrequency,
    objectives,
    gender,
    level,
    subscription,
  ];
}
