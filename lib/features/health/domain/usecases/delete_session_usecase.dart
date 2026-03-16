import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/session_repository.dart';

class DeleteSessionUsecase with LoggerMixin implements Usecase<Unit, DeleteSessionParams> {
  final SessionRepository repository;

  DeleteSessionUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.DeleteSessionUsecase';

  @override
  TaskEither<Failure, Unit> call(DeleteSessionParams params) {
    logger.finest('DeleteSessionUsecase called for id=${params.id}');
    return repository.deleteSession(params.id);
  }
}

class DeleteSessionParams extends Equatable {
  final int id;
  const DeleteSessionParams({required this.id});

  @override
  List<Object?> get props => [id];
}
