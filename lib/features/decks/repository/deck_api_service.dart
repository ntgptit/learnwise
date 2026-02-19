// quality-guard: allow-long-function - phase3 legacy backlog tracked for incremental extraction.
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../model/deck_constants.dart';
import '../model/deck_models.dart';
import 'deck_repository.dart';

class DeckApiService implements DeckRepository {
  DeckApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  static const String _logName = 'learnwise.decks.api';
  static const String _listRequestLogPrefix = 'DeckApiService.getDecks request';
  static const String _listResponseLogPrefix =
      'DeckApiService.getDecks response';
  static const String _listErrorLogPrefix =
      'DeckApiService.getDecks parseError';
  static const String _createRequestLogPrefix =
      'DeckApiService.createDeck request';
  static const String _createResponseLogPrefix =
      'DeckApiService.createDeck response';
  static const String _createErrorLogPrefix =
      'DeckApiService.createDeck parseError';
  static const String _updateRequestLogPrefix =
      'DeckApiService.updateDeck request';
  static const String _updateResponseLogPrefix =
      'DeckApiService.updateDeck response';
  static const String _updateErrorLogPrefix =
      'DeckApiService.updateDeck parseError';
  static const String _getAudioSettingsRequestLogPrefix =
      'DeckApiService.getDeckAudioSettings request';
  static const String _getAudioSettingsResponseLogPrefix =
      'DeckApiService.getDeckAudioSettings response';
  static const String _getAudioSettingsErrorLogPrefix =
      'DeckApiService.getDeckAudioSettings parseError';
  static const String _updateAudioSettingsRequestLogPrefix =
      'DeckApiService.updateDeckAudioSettings request';
  static const String _updateAudioSettingsResponseLogPrefix =
      'DeckApiService.updateDeckAudioSettings response';
  static const String _updateAudioSettingsErrorLogPrefix =
      'DeckApiService.updateDeckAudioSettings parseError';

  @override
  Future<DeckPageResult> getDecks({
    required DeckListQuery query,
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
      final DeckPageResult pageResult = DeckPageResult.fromJson(json);
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
  Future<DeckItem> createDeck({
    required int folderId,
    required DeckUpsertInput input,
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
      final DeckItem item = DeckItem.fromJson(json);
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
  Future<DeckItem> updateDeck({
    required int folderId,
    required int deckId,
    required DeckUpsertInput input,
  }) async {
    if (kDebugMode) {
      log(
        '$_updateRequestLogPrefix folderId=$folderId deckId=$deckId body=${input.toJson()}',
        name: _logName,
      );
    }

    final dynamic response = await _apiClient.put<dynamic>(
      '${_buildResourcePath(folderId)}/$deckId',
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final DeckItem item = DeckItem.fromJson(json);
      if (kDebugMode) {
        log(
          '$_updateResponseLogPrefix folderId=$folderId deckId=$deckId',
          name: _logName,
        );
      }
      return item;
    } catch (_) {
      if (kDebugMode) {
        log(
          '$_updateErrorLogPrefix folderId=$folderId deckId=$deckId',
          name: _logName,
        );
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<DeckAudioSettings> getDeckAudioSettings({required int deckId}) async {
    if (kDebugMode) {
      log('$_getAudioSettingsRequestLogPrefix deckId=$deckId', name: _logName);
    }
    final dynamic response = await _apiClient.get<dynamic>(
      _buildDeckSettingsPath(deckId),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final DeckAudioSettings settings = DeckAudioSettings.fromJson(json);
      if (kDebugMode) {
        log(
          '$_getAudioSettingsResponseLogPrefix deckId=${settings.deckId}',
          name: _logName,
        );
      }
      return settings;
    } catch (_) {
      if (kDebugMode) {
        log(
          '$_getAudioSettingsErrorLogPrefix deckId=$deckId',
          name: _logName,
        );
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<DeckAudioSettings> updateDeckAudioSettings({
    required int deckId,
    required DeckAudioSettingsUpdateInput input,
  }) async {
    if (kDebugMode) {
      log(
        '$_updateAudioSettingsRequestLogPrefix deckId=$deckId body=${input.toJson()}',
        name: _logName,
      );
    }
    final dynamic response = await _apiClient.patch<dynamic>(
      _buildDeckSettingsPath(deckId),
      data: input.toJson(),
    );
    try {
      final Map<String, dynamic> json = _extractResponseData(response.data);
      final DeckAudioSettings settings = DeckAudioSettings.fromJson(json);
      if (kDebugMode) {
        log(
          '$_updateAudioSettingsResponseLogPrefix deckId=${settings.deckId}',
          name: _logName,
        );
      }
      return settings;
    } catch (_) {
      if (kDebugMode) {
        log(
          '$_updateAudioSettingsErrorLogPrefix deckId=$deckId',
          name: _logName,
        );
      }
      throw const UnexpectedResponseAppException();
    }
  }

  @override
  Future<void> deleteDeck({required int folderId, required int deckId}) async {
    await _apiClient.delete<dynamic>('${_buildResourcePath(folderId)}/$deckId');
  }

  String _buildResourcePath(int folderId) {
    return '${DeckConstants.foldersResourcePath}/$folderId/${DeckConstants.decksPathSegment}';
  }

  String _buildDeckSettingsPath(int deckId) {
    return '${DeckConstants.decksResourcePath}/$deckId/${DeckConstants.settingsPathSegment}';
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
