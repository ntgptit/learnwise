import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'deck_api_service.dart';
import 'deck_repository.dart';

part 'deck_repository_provider.g.dart';

@Riverpod(keepAlive: true)
DeckRepository deckRepository(Ref ref) {
  final ApiClient apiClient = ref.read(apiClientProvider);
  return DeckApiService(apiClient: apiClient);
}
