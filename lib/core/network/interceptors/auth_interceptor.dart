import 'dart:async';

import 'package:dio/dio.dart';

import '../api_constants.dart';
import '../auth_session.dart';

typedef ExecuteRequest =
    Future<Response<dynamic>> Function(RequestOptions options);

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required AuthSessionManager authSessionManager,
    required ExecuteRequest executeRequest,
  }) : _authSessionManager = authSessionManager,
       _executeRequest = executeRequest;

  final AuthSessionManager _authSessionManager;
  final ExecuteRequest _executeRequest;
  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkipAuth(options)) {
      handler.next(options);
      return;
    }

    final String? token = await _authSessionManager.readAccessToken();
    if (!_hasToken(token)) {
      handler.next(options);
      return;
    }

    options.headers[ApiConstants.authorizationHeader] =
        '${ApiConstants.bearerTokenPrefix}${token!.trim()}';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions request = err.requestOptions;
    if (_shouldSkipAuth(request)) {
      handler.next(err);
      return;
    }

    if (!_isUnauthorized(err.response?.statusCode)) {
      handler.next(err);
      return;
    }

    if (_isRetried(request)) {
      await _authSessionManager.clearSession();
      handler.next(err);
      return;
    }

    final String? refreshedToken = await _refreshAccessToken();
    if (!_hasToken(refreshedToken)) {
      await _authSessionManager.clearSession();
      handler.next(err);
      return;
    }

    final RequestOptions retriedRequest = _cloneAsRetried(
      request: request,
      refreshedToken: refreshedToken!.trim(),
    );

    try {
      final Response<dynamic> response = await _executeRequest(retriedRequest);
      handler.resolve(response);
      return;
    } on DioException catch (retryError) {
      handler.next(retryError);
      return;
    }
  }

  bool _hasToken(String? token) {
    if (token == null) {
      return false;
    }
    return token.trim().isNotEmpty;
  }

  bool _shouldSkipAuth(RequestOptions request) {
    final dynamic extraValue = request.extra[ApiConstants.skipAuthExtraKey];
    if (extraValue is bool && extraValue) {
      return true;
    }
    return false;
  }

  bool _isRetried(RequestOptions request) {
    final dynamic extraValue = request.extra[ApiConstants.authRetriedExtraKey];
    if (extraValue is bool && extraValue) {
      return true;
    }
    return false;
  }

  bool _isUnauthorized(int? statusCode) {
    if (statusCode == null) {
      return false;
    }
    return statusCode == ApiConstants.unauthorizedStatusCode;
  }

  RequestOptions _cloneAsRetried({
    required RequestOptions request,
    required String refreshedToken,
  }) {
    final Map<String, dynamic> nextExtra = Map<String, dynamic>.from(
      request.extra,
    );
    nextExtra[ApiConstants.authRetriedExtraKey] = true;

    final Map<String, dynamic> nextHeaders = Map<String, dynamic>.from(
      request.headers,
    );
    nextHeaders[ApiConstants.authorizationHeader] =
        '${ApiConstants.bearerTokenPrefix}$refreshedToken';

    return request.copyWith(extra: nextExtra, headers: nextHeaders);
  }

  Future<String?> _refreshAccessToken() async {
    final Completer<String?>? running = _refreshCompleter;
    if (running != null) {
      return running.future;
    }

    final Completer<String?> completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final String? refreshedToken = await _authSessionManager
          .refreshAccessToken();
      completer.complete(refreshedToken);
      return refreshedToken;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }
}
