import '../../../../core/errors/failures.dart';

sealed class SessionFailure extends Failure {
  const SessionFailure({super.debugMessage});
}

class SessionNotFoundException extends SessionFailure {
  final int id;
  const SessionNotFoundException({required this.id, super.debugMessage});

  @override
  List<Object?> get props => [id, debugMessage];
}

class SessionCreationFailure extends SessionFailure {
  const SessionCreationFailure({super.debugMessage});
}

class SessionUpdateFailure extends SessionFailure {
  final int id;
  const SessionUpdateFailure({required this.id, super.debugMessage});

  @override
  List<Object?> get props => [id, debugMessage];
}

class SessionDeleteFailure extends SessionFailure {
  final int id;
  const SessionDeleteFailure({required this.id, super.debugMessage});

  @override
  List<Object?> get props => [id, debugMessage];
}

class SessionsFetchFailure extends SessionFailure {
  const SessionsFetchFailure({super.debugMessage});
}
