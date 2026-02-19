import '../../../core/network/api_client.dart';
import '../../../core/network/auth_session.dart';
import '../../../core/error/app_exception.dart';
import '../model/profile_constants.dart';
import '../model/profile_models.dart';
import 'profile_repository.dart';

class ProfileApiService implements ProfileRepository {
  ProfileApiService({
    required ApiClient apiClient,
    required AuthSessionManager authSessionManager,
  }) : _apiClient = apiClient,
       _authSessionManager = authSessionManager;

  final ApiClient _apiClient;
  final AuthSessionManager _authSessionManager;

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
  Future<UserProfile> updateProfile({
    required String displayName,
    String? username,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'displayName': displayName,
    };
    if (username != null) {
      payload['username'] = username;
    }
    final dynamic response = await _apiClient.patch<dynamic>(
      ProfileConstants.resourcePath,
      data: payload,
    );
    final dynamic rawPayload = response.data;
    if (rawPayload is! Map) {
      throw const UnexpectedResponseAppException();
    }
    final Map<String, dynamic> profileJson = Map<String, dynamic>.from(
      rawPayload,
    );
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

  @override
  Future<void> signOut() {
    return _authSessionManager.signOut();
  }
}
