import 'package:flutter_tts/flutter_tts.dart';

import '../model/tts_const.dart';
import '../model/tts_exceptions.dart';
import '../model/tts_models.dart';
import 'tts_repository.dart';

class TtsService implements TtsRepository {
  TtsService() {
    _flutterTts = FlutterTts();
  }

  late final FlutterTts _flutterTts;
  bool _isInitialized = false;
  final RegExp _hangulPattern = RegExp(TtsConst.hangulPattern);

  @override
  Future<void> init({
    TtsVoiceSettings settings = const TtsVoiceSettings(),
  }) async {
    if (_isInitialized) {
      return;
    }

    try {
      await _flutterTts.setLanguage(TtsConst.englishLanguageCode);
      await _applyVoiceSettings(settings);
      await _flutterTts.awaitSpeakCompletion(true);
      _isInitialized = true;
    } catch (error) {
      throw TtsInitException(error);
    }
  }

  @override
  Future<void> speak(
    String text, {
    TtsLanguageMode mode = TtsLanguageMode.auto,
    TtsVoiceSettings settings = const TtsVoiceSettings(),
    TtsVoiceOption? voice,
  }) async {
    final String message = text.trim();
    if (message.isEmpty) {
      return;
    }

    try {
      if (!_isInitialized) {
        await init(settings: settings);
      }

      if (voice != null) {
        await _flutterTts.setVoice(voice.params);
      } else {
        await _flutterTts.setLanguage(_resolveLanguage(message, mode));
      }
      await _applyVoiceSettings(settings);
      await _flutterTts.stop();
      await _flutterTts.speak(message);
    } on TtsException {
      rethrow;
    } catch (error) {
      throw TtsSpeakException(error);
    }
  }

  String _resolveLanguage(String text, TtsLanguageMode mode) {
    switch (mode) {
      case TtsLanguageMode.english:
        return TtsConst.englishLanguageCode;
      case TtsLanguageMode.korean:
        return TtsConst.koreanLanguageCode;
      case TtsLanguageMode.auto:
        return _hangulPattern.hasMatch(text)
            ? TtsConst.koreanLanguageCode
            : TtsConst.englishLanguageCode;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (error) {
      throw TtsStopException(error);
    }
  }

  @override
  Future<List<TtsVoiceOption>> getAvailableVoices({
    String? localePrefix,
  }) async {
    try {
      if (!_isInitialized) {
        await init();
      }

      final dynamic result = await _flutterTts.getVoices;
      if (result is! List) {
        return const <TtsVoiceOption>[];
      }

      final List<TtsVoiceOption> voices = <TtsVoiceOption>[];
      final Set<String> seen = <String>{};

      for (final dynamic item in result) {
        if (item is! Map) {
          continue;
        }

        final Map<String, dynamic> rawVoice = Map<String, dynamic>.from(item);
        final String id = _readString(rawVoice, TtsConst.voiceIdKeys);
        final String name = _readString(rawVoice, TtsConst.voiceNameKeys);
        final String locale = _readString(rawVoice, TtsConst.voiceLocaleKeys);
        final String dedupeKey = '${id.toLowerCase()}|${locale.toLowerCase()}';

        if (id.isEmpty || seen.contains(dedupeKey)) {
          continue;
        }
        if (localePrefix != null &&
            !locale.toLowerCase().startsWith(localePrefix.toLowerCase())) {
          continue;
        }

        final Map<String, String> params = <String, String>{};
        if (name.isNotEmpty) {
          params['name'] = name;
        }
        if (locale.isNotEmpty) {
          params['locale'] = locale;
        }
        if (params.isEmpty) {
          continue;
        }

        voices.add(
          TtsVoiceOption(
            id: id,
            name: name.isEmpty ? id : name,
            locale: locale.isEmpty ? TtsConst.unknownVoiceLocale : locale,
            params: params,
          ),
        );
        seen.add(dedupeKey);
      }

      voices.sort(
        (a, b) => '${a.locale}-${a.name}'.compareTo('${b.locale}-${b.name}'),
      );
      return voices;
    } on TtsException {
      rethrow;
    } catch (error) {
      throw TtsLoadVoicesException(error);
    }
  }

  Future<void> _applyVoiceSettings(TtsVoiceSettings settings) async {
    await _flutterTts.setSpeechRate(settings.speechRate);
    await _flutterTts.setVolume(settings.volume);
    await _flutterTts.setPitch(settings.pitch);
  }

  String _readString(Map<String, dynamic> data, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = data[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}
