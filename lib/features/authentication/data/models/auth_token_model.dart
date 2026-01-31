import 'dart:convert';

import '../../domain/entities/auth_token.dart';

class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.token,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
    };
  }

  factory AuthTokenModel.fromMap(Map<String, dynamic> map) {
    return AuthTokenModel(
      token: map['token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthTokenModel.fromJson(String source) => AuthTokenModel.fromMap(
    json.decode(source) as Map<String, dynamic>,
  );

  factory AuthTokenModel.fromEntity(AuthToken authToken) {
    return AuthTokenModel(
      token: authToken.token,
    );
  }
}
