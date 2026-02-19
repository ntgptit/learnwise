import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../model/language_models.dart';
import 'language_repository.dart';

class LanguageApiService implements LanguageRepository {
  LanguageApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  static const String _logName = 'learnwise.languages.api';
  static const String _path = '/languages';

  @override
  Future<List<LanguageItem>> fetchLanguages() async {
    if (kDebugMode) {
      log('LanguageApiService.fetchLanguages request', name: _logName);
    }
    final response = await _apiClient.get<dynamic>(_path);
    final List<dynamic> list = response.data as List<dynamic>;
    final result = list
        .map((e) => LanguageItem.fromJson(e as Map<String, dynamic>))
        .toList();
    if (kDebugMode) {
      log(
        'LanguageApiService.fetchLanguages response count=${result.length}',
        name: _logName,
      );
    }
    return result;
  }
}
