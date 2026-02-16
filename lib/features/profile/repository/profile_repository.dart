import '../model/profile_models.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateDisplayName(String displayName);

  Future<UserProfile> updateSettings(UserStudySettings settings);
}
