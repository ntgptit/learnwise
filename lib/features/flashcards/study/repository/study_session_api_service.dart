import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../model/study_constants.dart';
import '../model/study_session_models.dart';
import 'study_session_repository.dart';

class StudySessionApiService implements StudySessionRepository {
  StudySessionApiService({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<StudySessionResponseModel> startSession({
    required int deckId,
    required StudySessionStartRequest request,
  }) async {
    final dynamic response = await _apiClient.post<dynamic>(
      _buildDeckStudySessionsPath(deckId),
      data: request.toJson(),
    );
    return _decodeStudySessionResponse(response.data);
  }

  @override
  Future<StudySessionResponseModel> getSession({required int sessionId}) async {
    final dynamic response = await _apiClient.get<dynamic>(
      _buildStudySessionPath(sessionId),
    );
    return _decodeStudySessionResponse(response.data);
  }

  @override
  Future<StudySessionResponseModel> submitEvent({
    required int sessionId,
    required StudySessionEventRequest request,
  }) async {
    final dynamic response = await _apiClient.post<dynamic>(
      _buildStudySessionEventsPath(sessionId),
      data: request.toJson(),
    );
    return _decodeStudySessionResponse(response.data);
  }

  @override
  Future<StudySessionResponseModel> completeSession({
    required int sessionId,
  }) async {
    final dynamic response = await _apiClient.post<dynamic>(
      _buildStudySessionCompletePath(sessionId),
    );
    return _decodeStudySessionResponse(response.data);
  }

  @override
  Future<StudySessionResponseModel> restartMode({
    required int sessionId,
  }) async {
    final dynamic response = await _apiClient.post<dynamic>(
      _buildStudySessionRestartModePath(sessionId),
    );
    return _decodeStudySessionResponse(response.data);
  }

  String _buildDeckStudySessionsPath(int deckId) {
    return '${StudyConstants.decksResourcePath}/$deckId/${StudyConstants.studySessionsPathSegment}';
  }

  String _buildStudySessionPath(int sessionId) {
    return '${StudyConstants.studySessionsResourcePath}/$sessionId';
  }

  String _buildStudySessionEventsPath(int sessionId) {
    return '${_buildStudySessionPath(sessionId)}/${StudyConstants.studySessionEventsPathSegment}';
  }

  String _buildStudySessionCompletePath(int sessionId) {
    return '${_buildStudySessionPath(sessionId)}/${StudyConstants.studySessionCompletePathSegment}';
  }

  String _buildStudySessionRestartModePath(int sessionId) {
    return '${_buildStudySessionPath(sessionId)}/${StudyConstants.studySessionRestartModePathSegment}';
  }

  StudySessionResponseModel _decodeStudySessionResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return StudySessionResponseModel.fromJson(data);
    }
    if (data is Map) {
      return StudySessionResponseModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }
    throw const UnexpectedResponseAppException();
  }
}
