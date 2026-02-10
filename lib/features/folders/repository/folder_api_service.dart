import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../model/folder_constants.dart';
import '../model/folder_models.dart';
import 'folder_repository.dart';

class FolderApiService implements FolderRepository {
  FolderApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<FolderPageResult> getFolders({
    required FolderListQuery query,
    required int page,
  }) async {
    final dynamic response = await _apiClient.get<dynamic>(
      FolderConstants.resourcePath,
      queryParameters: query.toQueryParameters(page: page),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      return FolderPageResult.fromJson(json);
    } catch (_) {
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<FolderItem> createFolder(FolderUpsertInput input) async {
    final dynamic response = await _apiClient.post<dynamic>(
      FolderConstants.resourcePath,
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      return FolderItem.fromJson(json);
    } catch (_) {
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<FolderItem> updateFolder({
    required int folderId,
    required FolderUpsertInput input,
  }) async {
    final dynamic response = await _apiClient.put<dynamic>(
      '${FolderConstants.resourcePath}/$folderId',
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      return FolderItem.fromJson(json);
    } catch (_) {
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<void> deleteFolder(int folderId) async {
    await _apiClient.delete<dynamic>(
      '${FolderConstants.resourcePath}/$folderId',
    );
  }

  Map<String, dynamic> _extractResponseData(dynamic data) {
    if (data == null) {
      throw UnexpectedResponseAppException();
    }
    return _ensureMap(data);
  }

  Map<String, dynamic> _ensureMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw UnexpectedResponseAppException();
  }
}
