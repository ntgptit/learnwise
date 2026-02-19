import '../model/profile_models.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile({required String displayName});

  Future<UserProfile> updateSettings(UserStudySettings settings);

  Future<void> signOut();
}
