import '../../../core/network/api_client.dart';
import '../../../core/error/app_exception.dart';
import '../model/profile_constants.dart';
import '../model/profile_models.dart';
import 'profile_repository.dart';

class ProfileApiService implements ProfileRepository {
  ProfileApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<UserProfile> getProfile() {
    return _apiClient.getData<UserProfile>(
      ProfileConstants.resourcePath,
      decoder: (dynamic data) {
        if (data is! Map) {
          throw const UnexpectedResponseAppException();
        }
        final Map<String, dynamic> profileJson = Map<String, dynamic>.from(
          data,
        );
        return UserProfile.fromJson(profileJson);
      },
    );
  }

  @override
  Future<UserProfile> updateDisplayName(String displayName) async {
    final dynamic response = await _apiClient.patch<dynamic>(
      ProfileConstants.resourcePath,
      data: <String, dynamic>{'displayName': displayName},
    );
    final dynamic payload = response.data;
    if (payload is! Map) {
      throw const UnexpectedResponseAppException();
    }
    final Map<String, dynamic> profileJson = Map<String, dynamic>.from(payload);
    return UserProfile.fromJson(profileJson);
  }

  @override
  Future<UserProfile> updateSettings(UserStudySettings settings) async {
    const String settingsPath =
        '${ProfileConstants.resourcePath}/${ProfileConstants.settingsPathSegment}';
    final dynamic response = await _apiClient.patch<dynamic>(
      settingsPath,
      data: settings.toApiPayload(),
    );
    final dynamic payload = response.data;
    if (payload is! Map) {
      throw const UnexpectedResponseAppException();
    }
    final Map<String, dynamic> profileJson = Map<String, dynamic>.from(payload);
    return UserProfile.fromJson(profileJson);
  }
}
