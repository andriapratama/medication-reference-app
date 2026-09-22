import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

/// Retries a request with exponential backoff when the server returns 429.
class RetryInterceptor extends Interceptor {
  final Dio dio;

  RetryInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isRateLimited =
        err.response?.statusCode == ApiConstants.rateLimitStatusCode;
    final requestOptions = err.requestOptions;
    final attempt = (requestOptions.extra['retryAttempt'] as int?) ?? 0;

    if (!isRateLimited || attempt >= ApiConstants.maxRetries) {
      handler.next(err);
      return;
    }

    final delay = ApiConstants.initialRetryDelay * (1 << attempt);
    await Future.delayed(delay);

    requestOptions.extra['retryAttempt'] = attempt + 1;

    try {
      final response = await dio.fetch(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
