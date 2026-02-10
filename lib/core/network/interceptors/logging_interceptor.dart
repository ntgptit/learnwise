import 'dart:developer';

import 'package:dio/dio.dart';

import '../api_constants.dart';

class HttpLogConstants {
  const HttpLogConstants._();

  static const String logName = 'learnwise.http';
  static const String requestPrefix = 'REQ';
  static const String responsePrefix = 'RES';
  static const String errorPrefix = 'ERR';
  static const String requestStartTimeKey = 'requestStartEpochMs';
  static const String redactedValue = '***';
  static const String queryLabel = 'query';
  static const String headersLabel = 'headers';
  static const String bodyLabel = 'body';
  static const String durationLabel = 'durationMs';
  static const String authorizationHeaderLower = 'authorization';
  static const String cookieHeaderLower = 'cookie';
  static const String setCookieHeaderLower = 'set-cookie';
}

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required bool enabled}) : _enabled = enabled;

  final bool _enabled;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_enabled) {
      handler.next(options);
      return;
    }

    options.extra[HttpLogConstants.requestStartTimeKey] =
        DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> redactedHeaders = _redactHeaders(
      options.headers,
    );
    log(
      '${HttpLogConstants.requestPrefix} ${options.method} ${options.uri} ${HttpLogConstants.queryLabel}=${options.queryParameters} ${HttpLogConstants.headersLabel}=$redactedHeaders',
      name: HttpLogConstants.logName,
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!_enabled) {
      handler.next(response);
      return;
    }

    final int durationMs = _calculateDurationMs(response.requestOptions);
    final bool shouldLogBody = _shouldLogBody(response.requestOptions);
    final Object? body = shouldLogBody ? response.data : null;

    log(
      '${HttpLogConstants.responsePrefix} ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri} ${HttpLogConstants.durationLabel}=$durationMs ${HttpLogConstants.bodyLabel}=$body',
      name: HttpLogConstants.logName,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_enabled) {
      handler.next(err);
      return;
    }

    final int durationMs = _calculateDurationMs(err.requestOptions);
    final Map<String, dynamic> redactedHeaders = _redactHeaders(
      err.requestOptions.headers,
    );
    log(
      '${HttpLogConstants.errorPrefix} ${err.response?.statusCode} ${err.requestOptions.method} ${err.requestOptions.uri} ${HttpLogConstants.durationLabel}=$durationMs ${HttpLogConstants.headersLabel}=$redactedHeaders',
      name: HttpLogConstants.logName,
      error: err,
    );
    handler.next(err);
  }

  bool _shouldLogBody(RequestOptions requestOptions) {
    final dynamic allowRawBodyLog =
        requestOptions.extra[ApiConstants.rawBodyLoggingExtraKey];
    if (allowRawBodyLog is bool && allowRawBodyLog) {
      return true;
    }
    return false;
  }

  int _calculateDurationMs(RequestOptions requestOptions) {
    final dynamic startedAt =
        requestOptions.extra[HttpLogConstants.requestStartTimeKey];
    if (startedAt is! int) {
      return 0;
    }

    final int endedAt = DateTime.now().millisecondsSinceEpoch;
    final int durationMs = endedAt - startedAt;
    if (durationMs < 0) {
      return 0;
    }
    return durationMs;
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MapEntry<String, dynamic> entry in headers.entries) {
      final String normalizedKey = entry.key.toLowerCase();
      if (_shouldRedactHeader(normalizedKey)) {
        result[entry.key] = HttpLogConstants.redactedValue;
        continue;
      }
      result[entry.key] = entry.value;
    }
    return result;
  }

  bool _shouldRedactHeader(String normalizedKey) {
    if (normalizedKey == HttpLogConstants.authorizationHeaderLower) {
      return true;
    }
    if (normalizedKey == HttpLogConstants.cookieHeaderLower) {
      return true;
    }
    if (normalizedKey == HttpLogConstants.setCookieHeaderLower) {
      return true;
    }
    return false;
  }
}
