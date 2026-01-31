import 'failures.dart';

/// Base class for server-related failures.
abstract class ServerFailure extends Failure {
  const ServerFailure({super.debugMessage});
}

/// Server returned an error response.
class ServerErrorFailure extends ServerFailure {
  final int? statusCode;

  const ServerErrorFailure({this.statusCode, super.debugMessage});

  @override
  List<Object?> get props => [statusCode, debugMessage];
}

/// Request timed out.
class ServerTimeoutFailure extends ServerFailure {
  const ServerTimeoutFailure({super.debugMessage});
}

/// Server is unavailable (503, maintenance, etc.).
class ServerUnavailableFailure extends ServerFailure {
  const ServerUnavailableFailure({super.debugMessage});
}
