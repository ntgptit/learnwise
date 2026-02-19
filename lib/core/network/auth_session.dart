// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
// quality-guard: allow-large-class - AuthSession manager will be modularized in next refactor phase.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/config/app_config.dart';
import '../error/api_error_mapper.dart';
import '../error/app_exception.dart';
import '../error/error_code.dart';
import '../local/secure_storage.dart';
import '../utils/string_utils.dart';
import 'api_constants.dart';

part 'auth_session.g.dart';

class AuthSessionEndpoint {
  const AuthSessionEndpoint._();

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
}

class AuthSessionPayloadKey {
  const AuthSessionPayloadKey._();

  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
  static const String userId = 'userId';
  static const String email = 'email';
}

class AuthSessionConfig {
  const AuthSessionConfig._();

  static const Duration idleTimeout = Duration(minutes: 15);
}

abstract class AuthSessionManager implements Listenable {
  bool get isReady;

  bool get isAuthenticated;

  Future<String?> readAccessToken();

  Future<String?> refreshAccessToken();

  Future<void> login({required String identifier, required String password});

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String? username,
  });

  void markUserActivity();

  Future<void> signOut();

  Future<void> clearSession();
}

@Riverpod(keepAlive: true)
AuthSessionManager authSessionManager(Ref ref) {
  final SecureStorage storage = ref.read(secureStorageProvider);
  final AppErrorMapper errorMapper = ref.read(appErrorMapperProvider);
  final SecureStorageAuthSessionManager manager =
      SecureStorageAuthSessionManager(
        storage: storage,
        appConfig: AppConfig.fromEnv(),
        errorMapper: errorMapper,
      );
  ref.onDispose(manager.dispose);
  return manager;
}

class SecureStorageAuthSessionManager extends ChangeNotifier
    implements AuthSessionManager {
  SecureStorageAuthSessionManager({
    required SecureStorage storage,
    required AppConfig appConfig,
    required AppErrorMapper errorMapper,
  }) : _storage = storage,
       _errorMapper = errorMapper,
       _dio = Dio(
         BaseOptions(
           baseUrl: appConfig.apiBasePath,
           connectTimeout: const Duration(seconds: 20),
           receiveTimeout: const Duration(seconds: 20),
           sendTimeout: const Duration(seconds: 20),
           responseType: ResponseType.json,
           receiveDataWhenStatusError: true,
           headers: <String, Object>{
             ApiConstants.acceptHeader: ApiConstants.jsonMimeType,
             ApiConstants.contentTypeHeader: ApiConstants.jsonMimeType,
           },
         ),
       ) {
    unawaited(_restoreSession());
  }

  final SecureStorage _storage;
  final AppErrorMapper _errorMapper;
  final Dio _dio;
  Timer? _idleTimer;
  bool _isReady = false;
  bool _isAuthenticated = false;

  @override
  bool get isReady => _isReady;

  @override
  bool get isAuthenticated => _isAuthenticated;

  Future<void> _restoreSession() async {
    try {
      final String? accessToken = await readAccessToken();
      final String? refreshToken = await _storage.readRefreshToken();
      if (accessToken == null) {
        final bool restoredFromRefreshToken = await _restoreFromRefreshToken(
          refreshToken,
        );
        if (restoredFromRefreshToken) {
          return;
        }
        await _storage.clearSession();
        _setUnauthenticatedState();
        return;
      }
      final bool accessTokenValid = await _isAccessTokenValid(accessToken);
      if (accessTokenValid) {
        _setAuthenticatedState();
        return;
      }
      final bool restoredFromRefreshToken = await _restoreFromRefreshToken(
        refreshToken,
      );
      if (restoredFromRefreshToken) {
        return;
      }
      await _storage.clearSession();
      _setUnauthenticatedState();
      return;
    } catch (_) {
      try {
        await _storage.clearSession();
      } catch (_) {}
      _setUnauthenticatedState();
    }
  }

  Future<bool> _restoreFromRefreshToken(String? refreshToken) async {
    final String? normalizedRefreshToken = StringUtils.normalizeNullable(
      refreshToken,
    );
    if (normalizedRefreshToken == null) {
      return false;
    }
    try {
      final String? refreshedAccessToken = await _refreshAccessTokenForRestore(
        normalizedRefreshToken,
      );
      if (refreshedAccessToken == null) {
        return false;
      }
      final bool accessTokenValid = await _isAccessTokenValid(
        refreshedAccessToken,
      );
      if (!accessTokenValid) {
        return false;
      }
      _setAuthenticatedState();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isAccessTokenValid(String accessToken) async {
    try {
      await _requestCurrentUser(accessToken);
      return true;
    } catch (error) {
      final AppException appException = _errorMapper.toAppException(error);
      if (appException.code == AppErrorCode.unauthorized) {
        return false;
      }
      if (appException.code == AppErrorCode.forbidden) {
        return false;
      }
      if (appException.code == AppErrorCode.notFound) {
        return false;
      }
      rethrow;
    }
  }

  Future<void> _requestCurrentUser(String accessToken) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      AuthSessionEndpoint.me,
      options: Options(
        headers: <String, String>{
          ApiConstants.authorizationHeader:
              '${ApiConstants.bearerTokenPrefix}$accessToken',
        },
      ),
    );
    final dynamic payload = response.data;
    if (payload is! Map) {
      throw const UnexpectedResponseAppException();
    }
    final dynamic rawUserId = payload[AuthSessionPayloadKey.userId];
    final String? email = StringUtils.normalizeNullable(
      payload[AuthSessionPayloadKey.email]?.toString(),
    );
    if (rawUserId == null) {
      throw const UnexpectedResponseAppException();
    }
    if (email == null) {
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.readAccessToken();
  }

  @override
  Future<String?> refreshAccessToken() async {
    final String? refreshToken = await _storage.readRefreshToken();
    final String? normalizedRefreshToken = StringUtils.normalizeNullable(
      refreshToken,
    );
    if (normalizedRefreshToken == null) {
      return null;
    }

    final AuthTokenPair tokenPair = await _requestTokenPair(
      endpoint: AuthSessionEndpoint.refresh,
      body: <String, String>{'refreshToken': normalizedRefreshToken},
    );
    await _persistSession(tokenPair);
    return tokenPair.accessToken;
  }

  Future<String?> _refreshAccessTokenForRestore(String refreshToken) async {
    final AuthTokenPair tokenPair = await _requestTokenPair(
      endpoint: AuthSessionEndpoint.refresh,
      body: <String, String>{'refreshToken': refreshToken},
    );
    await _writeSessionTokenPair(tokenPair);
    return tokenPair.accessToken;
  }

  @override
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final AuthTokenPair tokenPair = await _requestTokenPair(
      endpoint: AuthSessionEndpoint.login,
      body: <String, String>{'identifier': identifier, 'password': password},
    );
    await _persistSession(tokenPair);
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String? username,
  }) async {
    final Map<String, String> body = <String, String>{
      'email': email,
      'password': password,
      'displayName': displayName,
    };
    if (username != null && username.isNotEmpty) {
      body['username'] = username;
    }
    final AuthTokenPair tokenPair = await _requestTokenPair(
      endpoint: AuthSessionEndpoint.register,
      body: body,
    );
    await _persistSession(tokenPair);
  }

  Future<AuthTokenPair> _requestTokenPair({
    required String endpoint,
    required Map<String, String> body,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        endpoint,
        data: body,
      );
      return _parseTokenPair(response.data);
    } catch (error) {
      throw _errorMapper.toAppException(error);
    }
  }

  AuthTokenPair _parseTokenPair(dynamic payload) {
    if (payload is! Map) {
      throw const UnexpectedResponseAppException();
    }
    final Map<dynamic, dynamic> mapPayload = payload;
    final String? accessToken = StringUtils.normalizeNullable(
      mapPayload[AuthSessionPayloadKey.accessToken]?.toString(),
    );
    final String? refreshToken = StringUtils.normalizeNullable(
      mapPayload[AuthSessionPayloadKey.refreshToken]?.toString(),
    );
    if (accessToken == null) {
      throw const UnexpectedResponseAppException();
    }
    if (refreshToken == null) {
      throw const UnexpectedResponseAppException();
    }
    return AuthTokenPair(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> _persistSession(AuthTokenPair tokenPair) async {
    await _writeSessionTokenPair(tokenPair);
    _setAuthenticatedState();
  }

  Future<void> _writeSessionTokenPair(AuthTokenPair tokenPair) async {
    await _storage.writeAccessToken(tokenPair.accessToken);
    await _storage.writeRefreshToken(tokenPair.refreshToken);
  }

  void _setAuthenticatedState() {
    _isAuthenticated = true;
    _isReady = true;
    _startIdleTimer();
    notifyListeners();
  }

  void _setUnauthenticatedState() {
    _isAuthenticated = false;
    _isReady = true;
    notifyListeners();
  }

  @override
  void markUserActivity() {
    if (!_isAuthenticated) {
      return;
    }
    _startIdleTimer();
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(AuthSessionConfig.idleTimeout, _handleIdleTimeout);
  }

  void _handleIdleTimeout() {
    unawaited(clearSession());
  }

  @override
  Future<void> signOut() {
    return clearSession();
  }

  @override
  Future<void> clearSession() async {
    _idleTimer?.cancel();
    await _storage.clearSession();
    _setUnauthenticatedState();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _dio.close();
    super.dispose();
  }
}

class AuthTokenPair {
  const AuthTokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}
