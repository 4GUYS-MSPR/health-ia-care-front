import 'package:equatable/equatable.dart';

import 'gender.dart';
import 'level.dart';
import 'objective.dart';
import 'subscription.dart';

/// Domain entity representing a member/client profile.
///
/// Contains health metrics, fitness information, and subscription details.
class Member extends Equatable {
  final int id;
  final int? clientId;
  final DateTime? createdAt;
  final Subscription subscription;
  final Level level;
  final int? age;
  final Gender gender;
  final double bmi;
  final double fatPercentage;
  final double height;
  final double weight;
  final int workoutFrequency;
  final List<Objective> objectives;

  /// Real DB primary key for the gender FK, as returned by the API.
  final int? genderId;

  /// Real DB primary key for the level FK, as returned by the API.
  final int? levelId;

  /// Real DB primary key for the subscription FK, as returned by the API.
  final int? subscriptionId;

  const Member({
    required this.id,
    this.clientId,
    this.createdAt,
    required this.subscription,
    required this.level,
    this.age,
    required this.gender,
    required this.bmi,
    required this.fatPercentage,
    required this.height,
    required this.weight,
    required this.workoutFrequency,
    required this.objectives,
    this.genderId,
    this.levelId,
    this.subscriptionId,
  });

  @override
  List<Object?> get props => [
    id,
    clientId,
    createdAt,
    subscription,
    level,
    age,
    gender,
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

  /// Creates a copy of this member with the given fields replaced.
  Member copyWith({
    int? id,
    int? clientId,
    DateTime? createdAt,
    Subscription? subscription,
    Level? level,
    int? age,
    Gender? gender,
    double? bmi,
    double? fatPercentage,
    double? height,
    double? weight,
    int? workoutFrequency,
    List<Objective>? objectives,
    int? genderId,
    int? levelId,
    int? subscriptionId,
  }) {
    return Member(
      id: id ?? this.id,
      age: age ?? this.age,
      bmi: bmi ?? this.bmi,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      workoutFrequency: workoutFrequency ?? this.workoutFrequency,
      createdAt: createdAt ?? this.createdAt,
      clientId: clientId ?? this.clientId,
      gender: gender ?? this.gender,
      level: level ?? this.level,
      subscription: subscription ?? this.subscription,
      objectives: objectives ?? this.objectives,
      genderId: genderId ?? this.genderId,
      levelId: levelId ?? this.levelId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
    );
  }
}
