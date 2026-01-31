import 'dart:convert';

import '../../domain/entities/user.dart';

/// Data model for [User] with (de)serialization helpers.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.isStaff,
  });

  /// Serializes the model to a `Map` using the application's expected keys.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'is_staff': isStaff,
    };
  }

  /// Deserializes a `Map` into a [UserModel].
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      username: map['username'] as String,
      email: map['email'] ?? '',
      isStaff: map['is_staff'] ?? false,
    );
  }

  /// Encodes the model as a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates a [UserModel] from a JSON string.
  factory UserModel.fromJson(String source) => UserModel.fromMap(
    json.decode(source) as Map<String, dynamic>,
  );

  /// Convenience factory to convert a domain [User] into a data model.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      isStaff: user.isStaff,
    );
  }
}
