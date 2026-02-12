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
        '$_listRequestLogPrefix deckId=${query.deckId} page=$page queryParams=$requestQueryParams',
        name: _logName,
      );
    }

    final dynamic response = await _apiClient.get<dynamic>(
      _buildResourcePath(query.deckId),
      queryParameters: query.toQueryParameters(page: page),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final FlashcardPageResult pageResult = FlashcardPageResult.fromJson(json);
      if (kDebugMode) {
        log(
          '$_listResponseLogPrefix deckId=${query.deckId} page=${pageResult.page} items=${pageResult.items.length}',
          name: _logName,
        );
      }
      return pageResult;
    } catch (_) {
      if (kDebugMode) {
        log(
          '$_listErrorLogPrefix deckId=${query.deckId} page=$page',
          name: _logName,
        );
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<FlashcardItem> createFlashcard({
    required int deckId,
    required FlashcardUpsertInput input,
  }) async {
    if (kDebugMode) {
      log(
        '$_createRequestLogPrefix deckId=$deckId body=${input.toJson()}',
        name: _logName,
      );
    }

    final dynamic response = await _apiClient.post<dynamic>(
      _buildResourcePath(deckId),
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final FlashcardItem item = FlashcardItem.fromJson(json);
      if (kDebugMode) {
        log(
          '$_createResponseLogPrefix deckId=$deckId id=${item.id}',
          name: _logName,
        );
      }
      return item;
    } catch (_) {
      if (kDebugMode) {
        log('$_createErrorLogPrefix deckId=$deckId', name: _logName);
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<FlashcardItem> updateFlashcard({
    required int deckId,
    required int flashcardId,
    required FlashcardUpsertInput input,
  }) async {
    if (kDebugMode) {
      log(
        '$_updateRequestLogPrefix deckId=$deckId flashcardId=$flashcardId body=${input.toJson()}',
        name: _logName,
      );
    }

    final dynamic response = await _apiClient.put<dynamic>(
      '${_buildResourcePath(deckId)}/$flashcardId',
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final FlashcardItem item = FlashcardItem.fromJson(json);
      if (kDebugMode) {
        log(
          '$_updateResponseLogPrefix deckId=$deckId flashcardId=$flashcardId',
          name: _logName,
        );
      }
      return item;
    } catch (_) {
      if (kDebugMode) {
        log(
          '$_updateErrorLogPrefix deckId=$deckId flashcardId=$flashcardId',
          name: _logName,
        );
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<void> deleteFlashcard({
    required int deckId,
    required int flashcardId,
  }) async {
    await _apiClient.delete<dynamic>(
      '${_buildResourcePath(deckId)}/$flashcardId',
    );
  }

  String _buildResourcePath(int deckId) {
    return '${FlashcardConstants.decksResourcePath}/$deckId/${FlashcardConstants.flashcardsPathSegment}';
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
