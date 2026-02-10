import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../model/folder_const.dart';
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
      FolderConst.resourcePath,
      queryParameters: query.toQueryParameters(page: page),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      return FolderPageResult.fromJson(json);
    } on FormatException {
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<FolderItem> createFolder(FolderUpsertInput input) async {
    final dynamic response = await _apiClient.post<dynamic>(
      FolderConst.resourcePath,
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      return FolderItem.fromJson(json);
    } on FormatException {
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<FolderItem> updateFolder({
    required int folderId,
    required FolderUpsertInput input,
  }) async {
    final dynamic response = await _apiClient.put<dynamic>(
      '${FolderConst.resourcePath}/$folderId',
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      return FolderItem.fromJson(json);
    } on FormatException {
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<void> deleteFolder(int folderId) async {
    await _apiClient.delete<dynamic>('${FolderConst.resourcePath}/$folderId');
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
