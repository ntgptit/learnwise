import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import 'study_session_api_service.dart';
import 'study_session_repository.dart';

part 'study_session_repository_provider.g.dart';

@Riverpod(keepAlive: true)
StudySessionRepository studySessionRepository(Ref ref) {
  final ApiClient apiClient = ref.read(apiClientProvider);
  return StudySessionApiService(apiClient: apiClient);
}
