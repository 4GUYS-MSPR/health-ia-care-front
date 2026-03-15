import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/members_repository.dart';

/// Deletes a member by ID.
class DeleteMemberUsecase with LoggerMixin implements Usecase<Unit, DeleteMemberUsecaseParams> {
  final MembersRepository repository;

  DeleteMemberUsecase({required this.repository});

  @override
  String get loggerName => 'Members.Domain.DeleteMemberUsecase';

  @override
  TaskEither<Failure, Unit> call(DeleteMemberUsecaseParams params) {
    logger.finest('DeleteMemberUsecase called for id=${params.id}');
    return repository.deleteMember(params.id);
  }
}

/// Parameters for [DeleteMemberUsecase].
class DeleteMemberUsecaseParams extends Equatable {
  final int id;

  const DeleteMemberUsecaseParams({required this.id});

  @override
  List<Object?> get props => [id];
}
