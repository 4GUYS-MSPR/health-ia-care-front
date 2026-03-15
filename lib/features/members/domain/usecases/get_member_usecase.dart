import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/member.dart';
import '../repositories/members_repository.dart';

/// Retrieves a single member by ID.
class GetMemberUsecase with LoggerMixin implements Usecase<Member, GetMemberUsecaseParams> {
  final MembersRepository repository;

  GetMemberUsecase({required this.repository});

  @override
  String get loggerName => 'Members.Domain.GetMemberUsecase';

  @override
  TaskEither<Failure, Member> call(GetMemberUsecaseParams params) {
    logger.finest('GetMemberUsecase called for id=${params.id}');
    return repository.getMember(params.id);
  }
}

/// Parameters for [GetMemberUsecase].
class GetMemberUsecaseParams extends Equatable {
  final int id;

  const GetMemberUsecaseParams({required this.id});

  @override
  List<Object?> get props => [id];
}
