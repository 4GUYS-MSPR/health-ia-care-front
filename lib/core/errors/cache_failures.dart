import 'failures.dart';

/// Base class for cache-related failures.
abstract class CacheFailure extends Failure {
  const CacheFailure({super.debugMessage});
}

/// Failed to read from cache.
class CacheReadFailure extends CacheFailure {
  const CacheReadFailure({super.debugMessage});
}

/// Failed to write to cache.
class CacheWriteFailure extends CacheFailure {
  const CacheWriteFailure({super.debugMessage});
}

/// Cache entry not found.
class CacheNotFoundFailure extends CacheFailure {
  const CacheNotFoundFailure({super.debugMessage});
}

/// Cache entry expired.
class CacheExpiredFailure extends CacheFailure {
  const CacheExpiredFailure({super.debugMessage});
}
