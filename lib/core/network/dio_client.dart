import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'retry_interceptor.dart';

/// Builds a Dio instance pre-configured for the openFDA API.
class DioClient {
  DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    dio.interceptors.add(RetryInterceptor(dio));

    return dio;
  }
}
