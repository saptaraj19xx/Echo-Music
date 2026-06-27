/// Base failure class for the application.
sealed class Failure {
  final String message;

  const Failure(this.message);
}

/// Represents a server/network failure.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Represents a cache failure.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Represents a not found failure.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Represents an unexpected failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}