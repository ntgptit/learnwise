import 'package:dio/dio.dart';

import '../api_const.dart';
import 'retry_policy.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({required Dio dio, required RetryPolicy retryPolicy})
    : _dio = dio,
      _retryPolicy = retryPolicy;

  final Dio _dio;
  final RetryPolicy _retryPolicy;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final int nextAttempt = _readAttempt(err.requestOptions) + 1;
    if (!_retryPolicy.canRetry(
      error: err,
      request: err.requestOptions,
      nextAttempt: nextAttempt,
    )) {
      handler.next(err);
      return;
    }

    final RequestOptions nextRequest = _copyRequestWithAttempt(
      err.requestOptions,
      nextAttempt,
    );
    final Duration delay = _retryPolicy.delayForAttempt(nextAttempt);
    await Future<void>.delayed(delay);

    try {
      final Response<dynamic> response = await _dio.fetch<dynamic>(nextRequest);
      handler.resolve(response);
      return;
    } on DioException catch (retryError) {
      handler.next(retryError);
      return;
    }
  }

  int _readAttempt(RequestOptions options) {
    final dynamic value = options.extra[ApiConst.retryAttemptKey];
    if (value is int && value >= 0) {
      return value;
    }
    return 0;
  }

  RequestOptions _copyRequestWithAttempt(RequestOptions options, int attempt) {
    final Map<String, dynamic> extra = Map<String, dynamic>.from(options.extra);
    extra[ApiConst.retryAttemptKey] = attempt;
    return options.copyWith(extra: extra);
  }
}
