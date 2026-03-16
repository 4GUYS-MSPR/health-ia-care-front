import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/workout_session.dart';
import '../repositories/session_repository.dart';

class GetAllSessionsUsecase with LoggerMixin implements Usecase<List<WorkoutSession>, NoParams> {
  final SessionRepository repository;

  GetAllSessionsUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.GetAllSessionsUsecase';

  @override
  TaskEither<Failure, List<WorkoutSession>> call(NoParams params) {
    logger.finest('GetAllSessionsUsecase called');
    return repository.getAllSessions();
  }
}
