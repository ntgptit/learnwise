import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repository/auth_action_repository.dart';
import '../repository/auth_action_repository_provider.dart';

part 'auth_action_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AuthActionController extends _$AuthActionController {
  late final AuthActionRepository _authActionRepository;

  @override
  FutureOr<void> build() {
    _authActionRepository = ref.read(authActionRepositoryProvider);
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() {
      return _authActionRepository.login(
        identifier: identifier,
        password: password,
      );
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String? username,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() {
      return _authActionRepository.register(
        email: email,
        username: username,
        password: password,
        displayName: displayName,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() {
      return _authActionRepository.signOut();
    });
  }

  void clearError() {
    state = const AsyncData<void>(null);
  }
}
