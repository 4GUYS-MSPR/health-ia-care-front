import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/member.dart';
import '../repositories/members_repository.dart';

/// Retrieves all members for the current user.
class GetAllMembersUsecase with LoggerMixin implements Usecase<List<Member>, NoParams> {
  final MembersRepository repository;

  GetAllMembersUsecase({required this.repository});

  @override
  String get loggerName => 'Members.Domain.GetAllMembersUsecase';

  @override
  TaskEither<Failure, List<Member>> call(NoParams params) {
    logger.finest('GetAllMembersUsecase called');
    return repository.getAllMembers();
  }
}

/// Empty params for usecases that don't require parameters.
class NoParams {
  const NoParams();
}
