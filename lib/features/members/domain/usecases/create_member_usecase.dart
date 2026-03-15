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

/// Handles creation of a new member with validation.
class CreateMemberUsecase with LoggerMixin implements Usecase<Member, CreateMemberUsecaseParams> {
  final MembersRepository repository;

  CreateMemberUsecase({required this.repository});

  @override
  String get loggerName => 'Members.Domain.CreateMemberUsecase';

  @override
  TaskEither<Failure, Member> call(CreateMemberUsecaseParams params) {
    logger.finest('CreateMemberUsecase called');

    // Validation
    if (params.height <= 0) {
      logger.warning('Validation failed: invalid height');
      return TaskEither.left(
        const MemberValidationFailure(
          field: 'height',
          debugMessage: 'Height must be greater than 0',
        ),
      );
    }

    if (params.weight <= 0) {
      logger.warning('Validation failed: invalid weight');
      return TaskEither.left(
        const MemberValidationFailure(
          field: 'weight',
          debugMessage: 'Weight must be greater than 0',
        ),
      );
    }

    if (params.workoutFrequency < 0) {
      logger.warning('Validation failed: invalid workout frequency');
      return TaskEither.left(
        const MemberValidationFailure(
          field: 'workoutFrequency',
          debugMessage: 'Workout frequency cannot be negative',
        ),
      );
    }

    logger.fine('Validation passed, delegating to repository');
    return repository.createMember(
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

/// Parameters for [CreateMemberUsecase].
class CreateMemberUsecaseParams extends Equatable {
  final int? age;
  final double bmi;
  final double fatPercentage;
  final double height;
  final double weight;
  final int workoutFrequency;
  final List<Objective> objectives;
  final Gender gender;
  final Level level;
  final Subscription subscription;

  const CreateMemberUsecaseParams({
    this.age,
    required this.bmi,
    required this.fatPercentage,
    required this.height,
    required this.weight,
    required this.workoutFrequency,
    this.objectives = const [],
    this.gender = Gender.unknow,
    required this.level,
    this.subscription = Subscription.free,
  });

  @override
  List<Object?> get props => [
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
