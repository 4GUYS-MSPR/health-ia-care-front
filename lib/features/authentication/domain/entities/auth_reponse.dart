import 'package:equatable/equatable.dart';

class AuthResponse extends Equatable {
  final String token;

  const AuthResponse({
    required this.token,
  });

  @override
  List<Object?> get props => [
    token,
  ];
}
