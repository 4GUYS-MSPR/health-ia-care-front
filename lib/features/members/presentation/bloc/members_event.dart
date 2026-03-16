part of 'members_bloc.dart';

/// Base class for all member events.
sealed class MembersEvent extends Equatable {
  const MembersEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all members.
final class LoadMembersRequested extends MembersEvent {
  const LoadMembersRequested();
}

/// Event to refresh members list.
final class RefreshMembersRequested extends MembersEvent {
  const RefreshMembersRequested();
}

/// Event to create a new member.
final class CreateMemberRequested extends MembersEvent {
  final int? age;
  final double bmi;
  final double fatPercentage;
  final double height;
  final double weight;
  final int workoutFrequency;
  final List<Objective> objectives;
  /// Real DB primary key for the gender FK (from /api/enum/Gender/).
  final int? genderId;
  /// Real DB primary key for the level FK (from /api/enum/Level/).
  final int? levelId;
  /// Real DB primary key for the subscription FK (from /api/enum/Subscription/).
  final int? subscriptionId;

  const CreateMemberRequested({
    this.age,
    required this.bmi,
    required this.fatPercentage,
    required this.height,
    required this.weight,
    required this.workoutFrequency,
    this.objectives = const [],
    this.genderId,
    this.levelId,
    this.subscriptionId,
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
    genderId,
    levelId,
    subscriptionId,
  ];
}

/// Event to update an existing member.
final class UpdateMemberRequested extends MembersEvent {
  final int id;
  final int? age;
  final double? bmi;
  final double? fatPercentage;
  final double? height;
  final double? weight;
  final int? workoutFrequency;
  final List<Objective>? objectives;
  /// Real DB primary key for the gender FK (from /api/enum/Gender/).
  final int? genderId;
  /// Real DB primary key for the level FK (from /api/enum/Level/).
  final int? levelId;
  /// Real DB primary key for the subscription FK (from /api/enum/Subscription/).
  final int? subscriptionId;

  const UpdateMemberRequested({
    required this.id,
    this.age,
    this.bmi,
    this.fatPercentage,
    this.height,
    this.weight,
    this.workoutFrequency,
    this.objectives,
    this.genderId,
    this.levelId,
    this.subscriptionId,
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
    genderId,
    levelId,
    subscriptionId,
  ];
}

/// Event to delete a member.
final class DeleteMemberRequested extends MembersEvent {
  final int id;

  const DeleteMemberRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

