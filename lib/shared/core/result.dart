/// Represents the result of an operation that can succeed or fail.
///
/// This is a functional programming pattern used to handle errors
/// without exceptions.
sealed class Result<T, E> {
  const Result();

  bool get isSuccess => this is Success<T, E>;

  bool get isError => this is Failure<T, E>;

  R fold<R>(R Function(T success) success, R Function(E error) error);
}

/// Represents a successful operation with data of type [T].
class Success<T, E> extends Result<T, E> {
  final T value;

  const Success(this.value);

  @override
  R fold<R>(R Function(T success) success, R Function(E error) error) =>
      success(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T, E> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed operation with an error of type [E].
class Failure<T, E> extends Result<T, E> {
  final E error;

  const Failure(this.error);

  @override
  R fold<R>(R Function(T success) success, R Function(E error) errorCallback) =>
      errorCallback(error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Failure<T, E> && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}