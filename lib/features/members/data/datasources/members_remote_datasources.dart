import 'package:dio/dio.dart';

import '../../../../core/errors/server_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../domain/errors/members_failures.dart';
import '../models/enum_item_model.dart';
import '../models/member_model.dart';


/// Remote datasource for members API operations.
abstract interface class MembersRemoteDatasources {
  /// Creates a new member.
  Future<MemberModel> createMember(MemberModel member);

  /// Deletes a member by [id].
  Future<void> deleteMember(int id);

  /// Gets all members.
  Future<List<MemberModel>> getAllMembers();

  /// Gets a single member by [id].
  Future<MemberModel> getMember(int id);

  /// Updates a member by [id] with partial data.
  Future<MemberModel> updateMember(int id, MemberModel member);

  /// Fetches gender options from the enum API.
  Future<List<EnumItemModel>> getGenderOptions();

  /// Fetches level options from the enum API.
  Future<List<EnumItemModel>> getLevelOptions();

  /// Fetches subscription options from the enum API.
  Future<List<EnumItemModel>> getSubscriptionOptions();
}

class MembersRemoteDatasourcesImpl with LoggerMixin implements MembersRemoteDatasources {
  static const _membersEndpoint = '/api/member/';
  static const _enumEndpoint = '/api/enum/';

  final Dio membersClient;

  MembersRemoteDatasourcesImpl({required this.membersClient});

  @override
  String get loggerName => 'Members.Data.MembersRemoteDatasources';

  @override
  Future<MemberModel> createMember(MemberModel member) async {
    logger.finest('createMember called');

    try {
      final res = await membersClient.post(_membersEndpoint, data: member.toMap());
      logger.fine('Member created successfully');
      return MemberModel.fromMap(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      logger.severe('Failed to create member', e, st);
      if (e.response?.statusCode == 400) {
        throw const MemberCreationFailure(debugMessage: 'Invalid member data');
      }
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<void> deleteMember(int id) async {
    logger.finest('deleteMember called for id=$id');

    try {
      await membersClient.delete('$_membersEndpoint$id/');
      logger.fine('Member $id deleted successfully');
    } on DioException catch (e, st) {
      logger.severe('Failed to delete member $id', e, st);
      if (e.response?.statusCode == 404) {
        throw MemberNotFoundFailure(memberId: id, debugMessage: 'Member not found');
      }
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<List<MemberModel>> getAllMembers() async {
    logger.finest('getAllMembers called');

    try {
      final res = await membersClient.get(_membersEndpoint);
      final payload = res.data;

      final data = switch (payload) {
        List<dynamic> list => list,
        Map<String, dynamic> map => (map['results'] as List<dynamic>? ?? const <dynamic>[]),
        _ => const <dynamic>[],
      };

      logger.fine('Retrieved ${data.length} members');
      return data
          .whereType<Map>()
          .map((item) => MemberModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e, st) {
      logger.severe('Failed to fetch members', e, st);
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<MemberModel> getMember(int id) async {
    logger.finest('getMember called for id=$id');

    try {
      final res = await membersClient.get('$_membersEndpoint$id/');
      logger.fine('Retrieved member $id');
      return MemberModel.fromMap(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      logger.severe('Failed to fetch member $id', e, st);
      if (e.response?.statusCode == 404) {
        throw MemberNotFoundFailure(memberId: id, debugMessage: 'Member not found');
      }
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<MemberModel> updateMember(int id, MemberModel member) async {
    logger.finest('updateMember called for id=$id');
    final payload = <String, dynamic>{
      'age': member.age,
      'bmi': member.bmi,
      'fat_percentage': member.fatPercentage,
      'height': member.height,
      'weight': member.weight,
      'workout_frequency': member.workoutFrequency,
      'gender': member.genderId,
      'level': member.levelId,
      'subscription': member.subscriptionId,
      'objectives': MemberModel.objectivesToApi(member.objectives),
    }..removeWhere((_, value) => value == null);

    try {
      final res = await membersClient.patch('$_membersEndpoint$id/', data: payload);
      logger.fine('Member $id updated successfully');
      return MemberModel.fromMap(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      logger.severe('Failed to update member $id', e, st);
      if (e.response?.statusCode == 404) {
        throw MemberNotFoundFailure(memberId: id, debugMessage: 'Member not found');
      }
      if (e.response?.statusCode == 400) {
        final backendMessage = e.response?.data?.toString();
        throw MemberUpdateFailure(
          memberId: id,
          debugMessage: backendMessage == null || backendMessage.isEmpty
              ? 'Invalid update data'
              : 'Invalid update data: $backendMessage',
        );
      }
      throw ServerErrorFailure(statusCode: e.response?.statusCode, debugMessage: e.message);
    }
  }

  @override
  Future<List<EnumItemModel>> getGenderOptions() =>
      _fetchEnumItems('Gender');

  @override
  Future<List<EnumItemModel>> getLevelOptions() =>
      _fetchEnumItems('Level');

  @override
  Future<List<EnumItemModel>> getSubscriptionOptions() =>
      _fetchEnumItems('Subscription');

  Future<List<EnumItemModel>> _fetchEnumItems(String model) async {
    final res = await membersClient.get('$_enumEndpoint$model/');
    final payload = res.data;
    final List<dynamic> results = payload is Map<String, dynamic>
        ? ((payload['results'] as List<dynamic>?) ?? const <dynamic>[])
        : (payload as List<dynamic>? ?? const <dynamic>[]);
    return results
        .whereType<Map<String, dynamic>>()
        .map(EnumItemModel.fromJson)
        .toList();
  }
}
