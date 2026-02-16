import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'profile_api_service.dart';
import 'profile_repository.dart';

part 'profile_repository_provider.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  final ApiClient apiClient = ref.read(apiClientProvider);
  return ProfileApiService(apiClient: apiClient);
}
