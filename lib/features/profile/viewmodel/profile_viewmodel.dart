import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/api_error_mapper.dart';
import '../../../core/error/error_code.dart';
import '../model/profile_models.dart';
import '../repository/profile_repository.dart';
import '../repository/profile_repository_provider.dart';

part 'profile_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class ProfileController extends _$ProfileController {
  late final ProfileRepository _repository;
  late final AppErrorAdvisor _errorAdvisor;

  @override
  Future<UserProfile> build() async {
    _repository = ref.read(profileRepositoryProvider);
    _errorAdvisor = ref.read(appErrorAdvisorProvider);
    return _loadProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<UserProfile>();
    state = await AsyncValue.guard(_loadProfile);
  }

  Future<bool> updateDisplayName(String displayName) async {
    return _updateProfile(
      action: () => _repository.updateDisplayName(displayName),
    );
  }

  Future<bool> updateSettings(UserStudySettings settings) async {
    return _updateProfile(
      action: () => _repository.updateSettings(settings),
    );
  }

  Future<void> signOut() {
    return _repository.signOut();
  }

  Future<UserProfile> _loadProfile() async {
    try {
      return await _repository.getProfile();
    } catch (error) {
      _errorAdvisor.handle(error, fallback: AppErrorCode.unauthorized);
      rethrow;
    }
  }

  Future<bool> _updateProfile({
    required Future<UserProfile> Function() action,
  }) async {
    final UserProfile? previousProfile = switch (state) {
      AsyncData<UserProfile>(value: final profile) => profile,
      _ => null,
    };
    if (previousProfile != null) {
      state = AsyncData<UserProfile>(previousProfile);
    }
    state = const AsyncLoading<UserProfile>();
    try {
      final UserProfile updatedProfile = await action();
      state = AsyncData<UserProfile>(updatedProfile);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError<UserProfile>(error, stackTrace);
      _errorAdvisor.handle(
        error,
        fallback: AppErrorCode.unexpectedResponse,
      );
      return false;
    }
  }
}
