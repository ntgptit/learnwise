import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/core/network/api_constants.dart';
import 'package:learnwise/core/network/interceptors/retry_policy.dart';

void main() {
  group('RetryPolicy', () {
    final RetryPolicy policy = RetryPolicy(
      maxRetryCount: 2,
      baseDelay: const Duration(milliseconds: 100),
      maxDelay: const Duration(milliseconds: 500),
      randomFraction: () => 0.5,
    );

    test('retries idempotent request for transient transport error', () {
      final RequestOptions request = RequestOptions(
        path: '/v1/items',
        method: ApiConstants.methodGet,
      );
      final DioException error = DioException(
        requestOptions: request,
        type: DioExceptionType.connectionTimeout,
      );

      final bool canRetry = policy.canRetry(
        error: error,
        request: request,
        nextAttempt: 1,
      );

      expect(canRetry, isTrue);
    });

    test('does not retry non-idempotent request', () {
      final RequestOptions request = RequestOptions(
        path: '/v1/items',
        method: 'POST',
      );
      final DioException error = DioException(
        requestOptions: request,
        type: DioExceptionType.connectionTimeout,
      );

      final bool canRetry = policy.canRetry(
        error: error,
        request: request,
        nextAttempt: 1,
      );

      expect(canRetry, isFalse);
    });

    test('does not retry when skip flag enabled', () {
      final RequestOptions request = RequestOptions(
        path: '/v1/items',
        method: ApiConstants.methodGet,
        extra: <String, dynamic>{ApiConstants.skipRetryExtraKey: true},
      );
      final DioException error = DioException(
        requestOptions: request,
        type: DioExceptionType.connectionTimeout,
      );

      final bool canRetry = policy.canRetry(
        error: error,
        request: request,
        nextAttempt: 1,
      );

      expect(canRetry, isFalse);
    });

    test('retries 5xx and not 4xx response', () {
      final RequestOptions request = RequestOptions(
        path: '/v1/items',
        method: ApiConstants.methodGet,
      );

      final DioException serverError = DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: request,
          statusCode: ApiConstants.serverErrorLowerBound,
        ),
      );
      final DioException clientError = DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: request,
          statusCode: ApiConstants.badRequestStatusCode,
        ),
      );

      expect(
        policy.canRetry(error: serverError, request: request, nextAttempt: 1),
        isTrue,
      );
      expect(
        policy.canRetry(error: clientError, request: request, nextAttempt: 1),
        isFalse,
      );
    });

    test('uses exponential backoff and max delay cap', () {
      expect(policy.delayForAttempt(1), const Duration(milliseconds: 100));
      expect(policy.delayForAttempt(2), const Duration(milliseconds: 200));
      expect(policy.delayForAttempt(4), const Duration(milliseconds: 500));
    });
  });
}
