import 'failures.dart';

/// Base class for network-related failures.
sealed class NetworkFailure extends Failure {
  const NetworkFailure({super.debugMessage});
}

/// No internet connection available.
class NoInternetConnectionFailure extends NetworkFailure {
  const NoInternetConnectionFailure({super.debugMessage});
}

/// Connection was lost during the request.
class ConnectionLostFailure extends NetworkFailure {
  const ConnectionLostFailure({super.debugMessage});
}

/// DNS resolution failed.
class DnsFailure extends NetworkFailure {
  const DnsFailure({super.debugMessage});
}

/// SSL/TLS certificate error.
class SslFailure extends NetworkFailure {
  const SslFailure({super.debugMessage});
}
