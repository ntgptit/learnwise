import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/auth_session.dart';
import 'auth_action_repository.dart';

part 'auth_action_repository_provider.g.dart';

@Riverpod(keepAlive: true)
AuthActionRepository authActionRepository(Ref ref) {
  final AuthSessionManager authSessionManager = ref.read(
    authSessionManagerProvider,
  );
  return _AuthActionSessionRepository(authSessionManager: authSessionManager);
}

class _AuthActionSessionRepository implements AuthActionRepository {
  _AuthActionSessionRepository({required AuthSessionManager authSessionManager})
    : _authSessionManager = authSessionManager;

  final AuthSessionManager _authSessionManager;

  @override
  Future<void> login({required String identifier, required String password}) {
    return _authSessionManager.login(identifier: identifier, password: password);
  }

  @override
  Future<void> register({
    required String email,
    String? username,
    required String password,
    required String displayName,
  }) {
    return _authSessionManager.register(
      email: email,
      username: username,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<void> signOut() {
    return _authSessionManager.signOut();
  }
}
