/// Represents the state of an asynchronous UI operation.
///
/// Used across features to model loading, success, and error states.
sealed class UiState<T> {
  const UiState();

  /// Returns true if this instance represents a success state.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this instance represents a loading state.
  bool get isLoading => this is Loading<T>;

  /// Returns true if this instance represents an error state.
  bool get isError => this is Error<T>;

  /// Maps the state to a new value based on the current state.
  R when<R>({
    required R Function(T data) success,
    required R Function() loading,
    required R Function(dynamic error) error,
  });
}

/// Represents a successful operation with data of type [T].
class Success<T> extends UiState<T> {
  final T data;

  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function() loading,
    required R Function(dynamic error) error,
  }) =>
      success(data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && other.data == data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Represents a loading state that may optionally hold previous data.
class Loading<T> extends UiState<T> {
  final T? previousData;

  const Loading([this.previousData]);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function() loading,
    required R Function(dynamic error) error,
  }) =>
      loading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loading<T> && other.previousData == previousData;

  @override
  int get hashCode => previousData.hashCode;

  @override
  String toString() => 'Loading(previousData: $previousData)';
}

/// Represents a failed operation with an error.
class Error<T> extends UiState<T> {
  final dynamic error;

  const Error(this.error);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function() loading,
    required R Function(dynamic error) error,
  }) =>
      error(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Error<T> && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Error($error)';
}