import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/objective.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/errors/members_failures.dart';
import '../models/member_model.dart';
import '../models/objective_model.dart';

/// Remote datasource for members API operations.
abstract interface class MembersRemoteDatasources {
  /// Creates a new member.
  Future<MemberModel> createMember({
    int? age,
    required double bmi,
    required double fatPercentage,
    required double height,
    required double weight,
    required int workoutFrequency,
    List<Objective> objectives = const [],
    required Gender gender,
    required Level level,
    required Subscription subscription,
  });

  /// Deletes a member by [id].
  Future<void> deleteMember(int id);

  /// Gets all members.
  Future<List<MemberModel>> getAllMembers();

  /// Gets a single member by [id].
  Future<MemberModel> getMember(int id);

  /// Updates a member by [id] with partial data.
  Future<MemberModel> updateMember(
    int id, {
    int? age,
    double? bmi,
    double? fatPercentage,
    double? height,
    double? weight,
    int? workoutFrequency,
    List<Objective>? objectives,
    Gender? gender,
    Level? level,
    Subscription? subscription,
  });
}

class MembersRemoteDatasourcesImpl with LoggerMixin implements MembersRemoteDatasources {
  static const _membersEndpoint = '/api/members/';

  final Dio membersClient;

  MembersRemoteDatasourcesImpl({
    required this.membersClient,
  });

  @override
  String get loggerName => 'Members.Data.MembersRemoteDatasources';

  @override
  Future<MemberModel> createMember({
    int? age,
    required double bmi,
    required double fatPercentage,
    required double height,
    required double weight,
    required int workoutFrequency,
    List<Objective> objectives = const [],
    required Gender gender,
    required Level level,
    required Subscription subscription,
  }) async {
    logger.finest('createMember called');
    logger.finer('Sending POST to $_membersEndpoint');

    try {
      final data = <String, dynamic>{
        'bmi': bmi,
        'fat_percentage': fatPercentage,
        'height': height,
        'weight': weight,
        'workout_frequency': workoutFrequency,
        'gender': gender.index,
        'level': level.index,
        'subscription': subscription.index,
      };

      if (age != null) data['age'] = age;
      if (objectives.isNotEmpty) {
        data['objectives'] = objectives.map((o) => ObjectiveModel.fromEntity(o).toMap()).toList();
      }

      final res = await membersClient.post(
        _membersEndpoint,
        data: data,
      );

      logger.fine('Member created successfully');
      return MemberModel.fromMap(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      logger.severe('Failed to create member', e, st);
      if (e.response?.statusCode == 400) {
        throw const MemberCreationFailure(
          debugMessage: 'Invalid member data',
        );
      }
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage: e.message,
      );
    }
  }

  @override
  Future<void> deleteMember(int id) async {
    logger.finest('deleteMember called for id=$id');
    logger.finer('Sending DELETE to $_membersEndpoint$id/');

    try {
      await membersClient.delete('$_membersEndpoint$id/');
      logger.fine('Member $id deleted successfully');
    } on DioException catch (e, st) {
      logger.severe('Failed to delete member $id', e, st);
      if (e.response?.statusCode == 404) {
        throw MemberNotFoundFailure(
          memberId: id,
          debugMessage: 'Member not found',
        );
      }
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage: e.message,
      );
    }
  }

  @override
  Future<List<MemberModel>> getAllMembers() async {
    logger.finest('getAllMembers called');
    logger.finer('Sending GET to $_membersEndpoint');

    try {
      final res = await membersClient.get(_membersEndpoint);
      final data = res.data as List<dynamic>;

      logger.fine('Retrieved ${data.length} members');
      return data.map((item) => MemberModel.fromMap(item)).toList();
    } on DioException catch (e, st) {
      logger.severe('Failed to fetch members', e, st);
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage: e.message,
      );
    }
  }

  @override
  Future<MemberModel> getMember(int id) async {
    logger.finest('getMember called for id=$id');
    logger.finer('Sending GET to $_membersEndpoint$id/');

    try {
      final res = await membersClient.get('$_membersEndpoint$id/');
      logger.fine('Retrieved member $id');
      return MemberModel.fromMap(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      logger.severe('Failed to fetch member $id', e, st);
      if (e.response?.statusCode == 404) {
        throw MemberNotFoundFailure(
          memberId: id,
          debugMessage: 'Member not found',
        );
      }
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage: e.message,
      );
    }
  }

  @override
  Future<MemberModel> updateMember(
    int id, {
    int? age,
    double? bmi,
    double? fatPercentage,
    double? height,
    double? weight,
    int? workoutFrequency,
    List<Objective>? objectives,
    Gender? gender,
    Level? level,
    Subscription? subscription,
  }) async {
    logger.finest('updateMember called for id=$id');
    logger.finer('Sending PATCH to $_membersEndpoint$id/');

    try {
      final data = <String, dynamic>{};

      if (age != null) data['age'] = age;
      if (bmi != null) data['bmi'] = bmi;
      if (fatPercentage != null) data['fat_percentage'] = fatPercentage;
      if (height != null) data['height'] = height;
      if (weight != null) data['weight'] = weight;
      if (workoutFrequency != null) data['workout_frequency'] = workoutFrequency;
      if (objectives != null) {
        data['objectives'] = objectives.map((o) => ObjectiveModel.fromEntity(o).toMap()).toList();
      }
      if (gender != null) data['gender'] = gender.index;
      if (level != null) data['level'] = level.index;
      if (subscription != null) data['subscription'] = subscription.index;

      final res = await membersClient.patch(
        '$_membersEndpoint$id/',
        data: data,
      );

      logger.fine('Member $id updated successfully');
      return MemberModel.fromMap(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      logger.severe('Failed to update member $id', e, st);
      if (e.response?.statusCode == 404) {
        throw MemberNotFoundFailure(
          memberId: id,
          debugMessage: 'Member not found',
        );
      }
      if (e.response?.statusCode == 400) {
        throw MemberUpdateFailure(
          memberId: id,
          debugMessage: 'Invalid update data',
        );
      }
      throw ServerErrorFailure(
        statusCode: e.response?.statusCode,
        debugMessage: e.message,
      );
    }
  }
}
