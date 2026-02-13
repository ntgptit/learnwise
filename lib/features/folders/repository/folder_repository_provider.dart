import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'folder_api_service.dart';
import 'folder_repository.dart';

part 'folder_repository_provider.g.dart';

@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) {
  final ApiClient apiClient = ref.read(apiClientProvider);
  return FolderApiService(apiClient: apiClient);
}
