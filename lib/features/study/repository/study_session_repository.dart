import '../model/study_session_models.dart';

abstract class StudySessionRepository {
  Future<StudySessionResponseModel> startSession({
    required int deckId,
    required StudySessionStartRequest request,
  });

  Future<StudySessionResponseModel> getSession({required int sessionId});

  Future<StudySessionResponseModel> submitEvent({
    required int sessionId,
    required StudySessionEventRequest request,
  });

  Future<StudySessionResponseModel> completeSession({required int sessionId});

  Future<StudySessionResponseModel> restartMode({required int sessionId});
}
