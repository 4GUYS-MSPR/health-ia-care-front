import 'dart:convert';

import '../../domain/entities/auth_token.dart';

class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.accessToken,
    required super.refreshToken,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'access': accessToken,
      'refresh': refreshToken,
    };
  }

  factory AuthTokenModel.fromMap(Map<String, dynamic> map) {
    return AuthTokenModel(
      accessToken: map['access'] as String,
      refreshToken: map['refresh'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthTokenModel.fromJson(String source) => AuthTokenModel.fromMap(
    json.decode(source) as Map<String, dynamic>,
  );

  factory AuthTokenModel.fromEntity(AuthToken authToken) {
    return AuthTokenModel(
      accessToken: authToken.accessToken,
      refreshToken: authToken.refreshToken,
    );
  }
}
