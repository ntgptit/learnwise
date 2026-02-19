import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'language_api_service.dart';
import 'language_repository.dart';

part 'language_repository_provider.g.dart';

@Riverpod(keepAlive: true)
LanguageRepository languageRepository(Ref ref) {
  final ApiClient apiClient = ref.read(apiClientProvider);
  return LanguageApiService(apiClient: apiClient);
}
