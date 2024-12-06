/// Represents the state of an asynchronous operation.
sealed class AsyncValue<T> {
  final T? data;
  final bool hasData;
  final bool hasError;
  final bool isLoading;
  final Object? error;
  final StackTrace? stackTrace;

  const AsyncValue({
    this.data,
    required this.hasData,
    required this.hasError,
    required this.isLoading,
    this.error,
    this.stackTrace,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is AsyncValue<T> &&
        other.data == data &&
        other.hasData == hasData &&
        other.hasError == hasError &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.stackTrace?.toString() == stackTrace?.toString();
  }

  @override
  int get hashCode => Object.hash(
        data,
        hasData,
        hasError,
        isLoading,
        error,
        stackTrace?.toString(),
      );

  @override
  String toString() =>
      '$runtimeType: has data:$hasData, data:$data, loading:$isLoading, has error: $hasError, error:$error,';
}

/// Async operation is in progress.
class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading()
      : super(
          hasData: false,
          isLoading: true,
          hasError: false,
        );
}

/// Async operation completed successfully.
class AsyncSuccess<T> extends AsyncValue<T> {
  const AsyncSuccess(
    T data,
  ) : super(
          data: data,
          hasData: true,
          isLoading: false,
          hasError: false,
        );
}

/// Async operation failed with an error.
class AsyncError<T> extends AsyncValue<T> {
  const AsyncError(
    Object error, [
    StackTrace? stackTrace,
  ]) : super(
          hasData: false,
          hasError: true,
          error: error,
          stackTrace: stackTrace,
          isLoading: false,
        );
}
