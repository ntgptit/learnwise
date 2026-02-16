import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/auth_session.dart';

part 'auth_action_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AuthActionController extends _$AuthActionController {
  late final AuthSessionManager _authSessionManager;

  @override
  FutureOr<void> build() {
    _authSessionManager = ref.read(authSessionManagerProvider);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() {
      return _authSessionManager.login(email: email, password: password);
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() {
      return _authSessionManager.register(
        email: email,
        password: password,
        displayName: displayName,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() {
      return _authSessionManager.signOut();
    });
  }

  void clearError() {
    state = const AsyncData<void>(null);
  }
}
