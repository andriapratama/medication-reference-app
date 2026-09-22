/// Constants for the openFDA Drug Labeling API.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.fda.gov/drug/label.json';

  /// Items per request/page.
  static const int defaultLimit = 20;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// HTTP status openFDA returns when the rate limit is exceeded.
  static const int rateLimitStatusCode = 429;

  /// Max retry attempts for a 429 response.
  static const int maxRetries = 3;

  /// Base delay for exponential backoff (1s, 2s, 4s...).
  static const Duration initialRetryDelay = Duration(seconds: 1);
}
