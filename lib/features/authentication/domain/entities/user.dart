import 'package:equatable/equatable.dart';

/// Domain entity representing an user.
///
/// Contains basic identity information and authentication data used by the
/// application.
class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final bool isStaff;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.isStaff,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    isStaff,
  ];
}
