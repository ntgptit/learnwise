// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../model/folder_constants.dart';
import '../model/folder_models.dart';
import 'folder_repository.dart';

class FolderApiService implements FolderRepository {
  FolderApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  static const String _logName = 'learnwise.folders.api';
  static const String _requestLogPrefix = 'FolderApiService.getFolders request';
  static const String _responseLogPrefix =
      'FolderApiService.getFolders response';
  static const String _errorLogPrefix =
      'FolderApiService.getFolders parseError';
  static const String _createRequestLogPrefix =
      'FolderApiService.createFolder request';
  static const String _createResponseLogPrefix =
      'FolderApiService.createFolder response';
  static const String _createErrorLogPrefix =
      'FolderApiService.createFolder parseError';
  static const String _updateRequestLogPrefix =
      'FolderApiService.updateFolder request';
  static const String _updateResponseLogPrefix =
      'FolderApiService.updateFolder response';
  static const String _updateErrorLogPrefix =
      'FolderApiService.updateFolder parseError';

  @override
  Future<FolderPageResult> getFolders({
    required FolderListQuery query,
    required int page,
  }) async {
    if (kDebugMode) {
      final Map<String, dynamic> requestQueryParams = query.toQueryParameters(
        page: page,
      );
      log(
        '$_requestLogPrefix page=$page parentFolderId=${query.parentFolderId} queryParams=$requestQueryParams',
        name: _logName,
      );
    }

    final dynamic response = await _apiClient.get<dynamic>(
      FolderConstants.resourcePath,
      queryParameters: query.toQueryParameters(page: page),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final FolderPageResult pageResult = FolderPageResult.fromJson(json);
      if (kDebugMode) {
        log(
          '$_responseLogPrefix page=${pageResult.page} parentFolderId=${query.parentFolderId} items=${pageResult.items.length}',
          name: _logName,
        );
      }
      return pageResult;
    } catch (_) {
      if (kDebugMode) {
        log(
          '$_errorLogPrefix page=$page parentFolderId=${query.parentFolderId}',
          name: _logName,
        );
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<FolderItem> createFolder(FolderUpsertInput input) async {
    if (kDebugMode) {
      final Map<String, dynamic> requestBody = input.toJson();
      log(
        '$_createRequestLogPrefix parentFolderId=${input.parentFolderId} body=$requestBody',
        name: _logName,
      );
    }

    final dynamic response = await _apiClient.post<dynamic>(
      FolderConstants.resourcePath,
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final FolderItem folder = FolderItem.fromJson(json);
      if (kDebugMode) {
        log(
          '$_createResponseLogPrefix id=${folder.id} parentFolderId=${folder.parentFolderId}',
          name: _logName,
        );
      }
      return folder;
    } catch (_) {
      if (kDebugMode) {
        log(
          '$_createErrorLogPrefix parentFolderId=${input.parentFolderId}',
          name: _logName,
        );
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<FolderItem> updateFolder({
    required int folderId,
    required FolderUpsertInput input,
  }) async {
    if (kDebugMode) {
      final Map<String, dynamic> requestBody = input.toJson();
      log(
        '$_updateRequestLogPrefix folderId=$folderId parentFolderId=${input.parentFolderId} body=$requestBody',
        name: _logName,
      );
    }

    final dynamic response = await _apiClient.put<dynamic>(
      '${FolderConstants.resourcePath}/$folderId',
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final FolderItem folder = FolderItem.fromJson(json);
      if (kDebugMode) {
        log(
          '$_updateResponseLogPrefix id=${folder.id} parentFolderId=${folder.parentFolderId}',
          name: _logName,
        );
      }
      return folder;
    } catch (_) {
      if (kDebugMode) {
        log(
          '$_updateErrorLogPrefix folderId=$folderId parentFolderId=${input.parentFolderId}',
          name: _logName,
        );
      }
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
      throw const UnexpectedResponseAppException();
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
    throw const UnexpectedResponseAppException();
  }
}
