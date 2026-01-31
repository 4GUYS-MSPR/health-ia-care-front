import 'package:equatable/equatable.dart';

import 'gender.dart';
import 'level.dart';
import 'subscription.dart';

class Member extends Equatable {
  final int id;
  final int? age;
  final double bmi;
  final double fatPercentage;
  final double height;
  final double weight;
  final int workoutFrequency;
  final Gender gender;
  final Level level;
  final Subscription subscription;

  const Member({
    required this.id,
    required this.age,
    required this.bmi,
    required this.fatPercentage,
    required this.height,
    required this.weight,
    required this.workoutFrequency,
    required this.gender,
    required this.level,
    required this.subscription,
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
    gender,
    level,
    subscription,
  ];
}
