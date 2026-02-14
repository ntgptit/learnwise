import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/string_utils.dart';

part 'secure_storage.g.dart';

class SecureStorageKey {
  const SecureStorageKey._();

  static const String accessToken = 'learnwise.auth.access_token';
  static const String refreshToken = 'learnwise.auth.refresh_token';
}

abstract class SecureStorage {
  Future<void> writeAccessToken(String token);

  Future<void> writeRefreshToken(String token);

  Future<void> deleteAccessToken();

  Future<void> deleteRefreshToken();

  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> clearSession();
}

@Riverpod(keepAlive: true)
FlutterSecureStorage flutterSecureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

@Riverpod(keepAlive: true)
SecureStorage secureStorage(Ref ref) {
  final FlutterSecureStorage storage = ref.read(flutterSecureStorageProvider);
  return SecureStorageImpl(storage);
}

class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl(this._storage);

  final FlutterSecureStorage _storage;
  String? _accessTokenCache;
  String? _refreshTokenCache;

  @override
  Future<void> writeAccessToken(String token) async {
    final String? value = StringUtils.normalizeNullable(token);
    if (value == null) {
      throw ArgumentError.value(
        token,
        'token',
        'Access token must not be empty.',
      );
    }
    _accessTokenCache = value;
    await _storage.write(key: SecureStorageKey.accessToken, value: value);
  }

  @override
  Future<void> writeRefreshToken(String token) async {
    final String? value = StringUtils.normalizeNullable(token);
    if (value == null) {
      throw ArgumentError.value(
        token,
        'token',
        'Refresh token must not be empty.',
      );
    }
    _refreshTokenCache = value;
    await _storage.write(key: SecureStorageKey.refreshToken, value: value);
  }

  @override
  Future<void> deleteAccessToken() async {
    _accessTokenCache = null;
    await _storage.delete(key: SecureStorageKey.accessToken);
  }

  @override
  Future<void> deleteRefreshToken() async {
    _refreshTokenCache = null;
    await _storage.delete(key: SecureStorageKey.refreshToken);
  }

  @override
  Future<String?> readAccessToken() async {
    final String? cachedToken = _accessTokenCache;
    if (cachedToken != null) {
      return cachedToken;
    }

    final String? token = await _storage.read(
      key: SecureStorageKey.accessToken,
    );
    if (token == null) {
      return null;
    }

    final String? normalizedToken = StringUtils.normalizeNullable(token);
    if (normalizedToken == null) {
      _accessTokenCache = null;
      await _storage.delete(key: SecureStorageKey.accessToken);
      return null;
    }

    _accessTokenCache = normalizedToken;
    return normalizedToken;
  }

  @override
  Future<String?> readRefreshToken() async {
    final String? cachedToken = _refreshTokenCache;
    if (cachedToken != null) {
      return cachedToken;
    }

    final String? token = await _storage.read(
      key: SecureStorageKey.refreshToken,
    );
    if (token == null) {
      return null;
    }

    final String? normalizedToken = StringUtils.normalizeNullable(token);
    if (normalizedToken == null) {
      _refreshTokenCache = null;
      await _storage.delete(key: SecureStorageKey.refreshToken);
      return null;
    }

    _refreshTokenCache = normalizedToken;
    return normalizedToken;
  }

  @override
  Future<void> clearSession() async {
    await deleteAccessToken();
    await deleteRefreshToken();
  }
}
