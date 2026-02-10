import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../local/secure_storage.dart';

part 'auth_session.g.dart';

abstract class AuthSessionManager {
  Future<String?> readAccessToken();

  Future<String?> refreshAccessToken();

  Future<void> clearSession();
}

@Riverpod(keepAlive: true)
AuthSessionManager authSessionManager(Ref ref) {
  final SecureStorage storage = ref.read(secureStorageProvider);
  return SecureStorageAuthSessionManager(storage);
}

class SecureStorageAuthSessionManager implements AuthSessionManager {
  SecureStorageAuthSessionManager(this._storage);

  final SecureStorage _storage;

  @override
  Future<String?> readAccessToken() {
    return _storage.readAccessToken();
  }

  @override
  Future<String?> refreshAccessToken() async {
    return null;
  }

  @override
  Future<void> clearSession() {
    return _storage.clearSession();
  }
}
