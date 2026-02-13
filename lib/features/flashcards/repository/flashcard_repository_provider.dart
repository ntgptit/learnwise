import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'flashcard_api_service.dart';
import 'flashcard_repository.dart';

part 'flashcard_repository_provider.g.dart';

@Riverpod(keepAlive: true)
FlashcardRepository flashcardRepository(Ref ref) {
  final ApiClient apiClient = ref.read(apiClientProvider);
  return FlashcardApiService(apiClient: apiClient);
}
