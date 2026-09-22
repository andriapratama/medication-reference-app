import '../error/failure.dart';

/// Lightweight Either-like wrapper so repositories don't leak raw exceptions.
sealed class Result<T> {
  const Result();
}

/// Successful result holding [value].
class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

/// Failed result holding the mapped [failure].
class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
