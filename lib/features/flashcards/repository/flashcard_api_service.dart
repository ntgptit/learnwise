import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../model/flashcard_constants.dart';
import '../model/flashcard_models.dart';
import 'flashcard_repository.dart';

class FlashcardApiService implements FlashcardRepository {
  FlashcardApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  static const String _logName = 'learnwise.flashcards.api';
  static const String _listRequestLogPrefix =
      'FlashcardApiService.getFlashcards request';
  static const String _listResponseLogPrefix =
      'FlashcardApiService.getFlashcards response';
  static const String _listErrorLogPrefix =
      'FlashcardApiService.getFlashcards parseError';
  static const String _createRequestLogPrefix =
      'FlashcardApiService.createFlashcard request';
  static const String _createResponseLogPrefix =
      'FlashcardApiService.createFlashcard response';
  static const String _createErrorLogPrefix =
      'FlashcardApiService.createFlashcard parseError';
  static const String _updateRequestLogPrefix =
      'FlashcardApiService.updateFlashcard request';
  static const String _updateResponseLogPrefix =
      'FlashcardApiService.updateFlashcard response';
  static const String _updateErrorLogPrefix =
      'FlashcardApiService.updateFlashcard parseError';

  @override
  Future<FlashcardPageResult> getFlashcards({
    required FlashcardListQuery query,
    required int page,
  }) async {
    if (kDebugMode) {
      final Map<String, dynamic> requestQueryParams = query.toQueryParameters(
        page: page,
      );
      log(
        '$_listRequestLogPrefix folderId=${query.folderId} page=$page queryParams=$requestQueryParams',
        name: _logName,
      );
    }

    final dynamic response = await _apiClient.get<dynamic>(
      _buildResourcePath(query.folderId),
      queryParameters: query.toQueryParameters(page: page),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final FlashcardPageResult pageResult = FlashcardPageResult.fromJson(json);
      if (kDebugMode) {
        log(
          '$_listResponseLogPrefix folderId=${query.folderId} page=${pageResult.page} items=${pageResult.items.length}',
          name: _logName,
        );
      }
      return pageResult;
    } catch (_) {
      if (kDebugMode) {
        log(
          '$_listErrorLogPrefix folderId=${query.folderId} page=$page',
          name: _logName,
        );
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<FlashcardItem> createFlashcard({
    required int folderId,
    required FlashcardUpsertInput input,
  }) async {
    if (kDebugMode) {
      log(
        '$_createRequestLogPrefix folderId=$folderId body=${input.toJson()}',
        name: _logName,
      );
    }

    final dynamic response = await _apiClient.post<dynamic>(
      _buildResourcePath(folderId),
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final FlashcardItem item = FlashcardItem.fromJson(json);
      if (kDebugMode) {
        log(
          '$_createResponseLogPrefix folderId=$folderId id=${item.id}',
          name: _logName,
        );
      }
      return item;
    } catch (_) {
      if (kDebugMode) {
        log('$_createErrorLogPrefix folderId=$folderId', name: _logName);
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<FlashcardItem> updateFlashcard({
    required int folderId,
    required int flashcardId,
    required FlashcardUpsertInput input,
  }) async {
    if (kDebugMode) {
      log(
        '$_updateRequestLogPrefix folderId=$folderId flashcardId=$flashcardId body=${input.toJson()}',
        name: _logName,
      );
    }

    final dynamic response = await _apiClient.put<dynamic>(
      '${_buildResourcePath(folderId)}/$flashcardId',
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final FlashcardItem item = FlashcardItem.fromJson(json);
      if (kDebugMode) {
        log(
          '$_updateResponseLogPrefix folderId=$folderId flashcardId=$flashcardId',
          name: _logName,
        );
      }
      return item;
    } catch (_) {
      if (kDebugMode) {
        log(
          '$_updateErrorLogPrefix folderId=$folderId flashcardId=$flashcardId',
          name: _logName,
        );
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<void> deleteFlashcard({
    required int folderId,
    required int flashcardId,
  }) async {
    await _apiClient.delete<dynamic>(
      '${_buildResourcePath(folderId)}/$flashcardId',
    );
  }

  String _buildResourcePath(int folderId) {
    return '${FlashcardConstants.foldersResourcePath}/$folderId/${FlashcardConstants.flashcardsPathSegment}';
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
