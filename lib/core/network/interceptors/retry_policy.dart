import 'dart:math';

import 'package:dio/dio.dart';

import '../api_constants.dart';

typedef RandomFraction = double Function();

class RetryPolicy {
  RetryPolicy({
    required this.maxRetryCount,
    this.baseDelay = ApiConstants.retryBaseDelay,
    this.maxDelay = ApiConstants.retryMaxDelay,
    RandomFraction? randomFraction,
  }) : _randomFraction = randomFraction ?? Random().nextDouble;

  final int maxRetryCount;
  final Duration baseDelay;
  final Duration maxDelay;
  final RandomFraction _randomFraction;

  bool canRetry({
    required DioException error,
    required RequestOptions request,
    required int nextAttempt,
  }) {
    if (nextAttempt > maxRetryCount) {
      return false;
    }

    if (_shouldSkipRetry(request)) {
      return false;
    }

    if (!_isIdempotentMethod(request.method)) {
      return false;
    }

    if (_isTransientTransportError(error.type)) {
      return true;
    }

    if (!_isServerResponse(error.type)) {
      return false;
    }

    final int? statusCode = error.response?.statusCode;
    if (statusCode == null) {
      return false;
    }

    return statusCode >= ApiConstants.serverErrorLowerBound &&
        statusCode <= ApiConstants.serverErrorUpperBound;
  }

  Duration delayForAttempt(int attempt) {
    if (attempt <= 0) {
      return Duration.zero;
    }

    final int multiplier = 1 << (attempt - 1);
    final int rawDelayMs = baseDelay.inMilliseconds * multiplier;
    final int cappedDelayMs = min(rawDelayMs, maxDelay.inMilliseconds);
    final double jitter = _randomFraction();
    final double factor = 0.8 + (jitter * 0.4);
    final int jitteredMs = (cappedDelayMs * factor).round();
    return Duration(milliseconds: jitteredMs);
  }

  bool _shouldSkipRetry(RequestOptions request) {
    final dynamic skipRetry = request.extra[ApiConstants.skipRetryExtraKey];
    if (skipRetry is bool && skipRetry) {
      return true;
    }
    return false;
  }

  bool _isIdempotentMethod(String method) {
    final String normalizedMethod = method.toUpperCase();
    if (normalizedMethod == ApiConstants.methodGet) {
      return true;
    }
    if (normalizedMethod == ApiConstants.methodHead) {
      return true;
    }
    if (normalizedMethod == ApiConstants.methodOptions) {
      return true;
    }
    return false;
  }

  bool _isTransientTransportError(DioExceptionType type) {
    if (type == DioExceptionType.connectionTimeout) {
      return true;
    }
    if (type == DioExceptionType.sendTimeout) {
      return true;
    }
    if (type == DioExceptionType.receiveTimeout) {
      return true;
    }
    if (type == DioExceptionType.connectionError) {
      return true;
    }
    return false;
  }

  bool _isServerResponse(DioExceptionType type) {
    return type == DioExceptionType.badResponse;
  }
}
