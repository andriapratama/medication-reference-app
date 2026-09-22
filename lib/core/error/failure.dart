import 'package:equatable/equatable.dart';

/// Base type for mapped errors passed from data layer to UI.
sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// No connection or low-level connection error.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Server responded with a 5xx status code.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Server responded with 429 after retries were exhausted.
class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message);
}

/// Response parsing failed or an important field was missing.
class InvalidDataFailure extends Failure {
  const InvalidDataFailure(super.message);
}

/// Fallback for anything that doesn't fit the categories above.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
