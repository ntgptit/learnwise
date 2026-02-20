import 'dart:async';

// quality-guard: allow-long-function - phase3 legacy backlog tracked for incremental extraction.
// quality-guard: allow-large-class - TtsService consolidates warm-up synchronization, voice fallback, and speech retry in one repository boundary.
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/utils/string_utils.dart';
import '../model/tts_constants.dart';
import '../model/tts_exceptions.dart';
import '../model/tts_models.dart';
import 'tts_repository.dart';

class TtsService implements TtsRepository {
  TtsService() {
    _flutterTts = FlutterTts();
  }

  late final FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isWarmUpDone = false;
  Completer<void>? _warmUpCompleter;
  final RegExp _hangulPattern = RegExp(TtsConstants.hangulPattern);

  @override
  Future<void> init({
    TtsVoiceSettings settings = const TtsVoiceSettings(),
  }) async {
    if (_isInitialized) {
      return;
    }
    final Completer<void>? existingCompleter = _warmUpCompleter;
    if (existingCompleter != null) {
      await existingCompleter.future;
      return;
    }

    final Completer<void> warmUpCompleter = Completer<void>();
    _warmUpCompleter = warmUpCompleter;

    try {
      await _flutterTts.setLanguage(TtsConstants.englishLanguageCode);
      await _applyVoiceSettings(settings);
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.getVoices;
      await _flutterTts.speak(TtsConstants.warmUpText);
      await _flutterTts.stop();
      _isWarmUpDone = true;
      _isInitialized = true;
      if (!warmUpCompleter.isCompleted) {
        warmUpCompleter.complete();
      }
    } catch (error) {
      if (!warmUpCompleter.isCompleted) {
        warmUpCompleter.completeError(error);
      }
      _warmUpCompleter = null;
      _isWarmUpDone = false;
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
    final String message = StringUtils.normalize(text);
    if (message.isEmpty) {
      return;
    }

    try {
      if (!_isInitialized) {
        await init(settings: settings);
      }
      if (!_isWarmUpDone) {
        await (_warmUpCompleter?.future ?? Future<void>.value());
      }
      await _speakCore(
        text: message,
        mode: mode,
        settings: settings,
        voice: voice,
      );
    } on TtsException {
      rethrow;
    } catch (error) {
      if (_isRetryableSpeechSynthesisError(error)) {
        await _retrySpeakAfterInterruption(
          text: message,
          mode: mode,
          settings: settings,
          voice: voice,
        );
        return;
      }
      throw TtsSpeakException(error);
    }
  }

  Future<void> _speakCore({
    required String text,
    required TtsLanguageMode mode,
    required TtsVoiceSettings settings,
    required TtsVoiceOption? voice,
  }) async {
    final String fallbackLanguage = _resolveLanguage(text, mode);
    if (voice != null) {
      await _speakWithPreferredVoice(
        text: text,
        settings: settings,
        voice: voice,
        fallbackLanguage: fallbackLanguage,
      );
      return;
    }
    await _setLanguageSafely(fallbackLanguage);
    await _applyVoiceSettings(settings);
    await _flutterTts.speak(text);
  }

  Future<void> _retrySpeakAfterInterruption({
    required String text,
    required TtsLanguageMode mode,
    required TtsVoiceSettings settings,
    required TtsVoiceOption? voice,
  }) async {
    try {
      await Future<void>.delayed(
        const Duration(milliseconds: TtsConstants.speechRetryDelayMilliseconds),
      );
      await _flutterTts.stop();
      await _speakCore(
        text: text,
        mode: mode,
        settings: settings,
        voice: voice,
      );
    } catch (error) {
      throw TtsSpeakException(error);
    }
  }

  bool _isRetryableSpeechSynthesisError(Object error) {
    final String errorText = StringUtils.toLower(
      StringUtils.normalize('$error'),
    );
    if (errorText.isEmpty) {
      return false;
    }
    return errorText.contains(TtsConstants.speechSynthesisErrorToken);
  }

  Future<void> _speakWithPreferredVoice({
    required String text,
    required TtsVoiceSettings settings,
    required TtsVoiceOption voice,
    required String fallbackLanguage,
  }) async {
    try {
      final String preferredLanguage =
          _resolveVoiceLocale(voice) ?? fallbackLanguage;
      await _setLanguageSafely(preferredLanguage);
      await _flutterTts.setVoice(voice.params);
      await _applyVoiceSettings(settings);
      await _flutterTts.speak(text);
    } catch (_) {
      // Fallback avoids repeated browser SpeechSynthesis errors when a selected
      // voice becomes unavailable on a given device/runtime.
      await _setLanguageSafely(fallbackLanguage);
      await _applyVoiceSettings(settings);
      await _flutterTts.speak(text);
    }
  }

  Future<void> _setLanguageSafely(String languageCode) async {
    final String normalizedLanguageCode = StringUtils.normalize(languageCode);
    if (normalizedLanguageCode.isEmpty) {
      return;
    }
    await _flutterTts.setLanguage(normalizedLanguageCode);
  }

  String? _resolveVoiceLocale(TtsVoiceOption voice) {
    final String normalizedLocale = StringUtils.normalize(voice.locale);
    if (normalizedLocale.isEmpty) {
      return null;
    }
    return normalizedLocale;
  }

  String _resolveLanguage(String text, TtsLanguageMode mode) {
    switch (mode) {
      case TtsLanguageMode.english:
        return TtsConstants.englishLanguageCode;
      case TtsLanguageMode.korean:
        return TtsConstants.koreanLanguageCode;
      case TtsLanguageMode.auto:
        return _hangulPattern.hasMatch(text)
            ? TtsConstants.koreanLanguageCode
            : TtsConstants.englishLanguageCode;
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
  Future<void> dispose() async {
    try {
      await _flutterTts.stop();
      _isInitialized = false;
      _isWarmUpDone = false;
      _warmUpCompleter = null;
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
        final String id = _readString(rawVoice, TtsConstants.voiceIdKeys);
        final String name = _readString(rawVoice, TtsConstants.voiceNameKeys);
        final String locale = _readString(
          rawVoice,
          TtsConstants.voiceLocaleKeys,
        );
        final String dedupeKey = StringUtils.toLower(id);

        if (id.isEmpty || seen.contains(dedupeKey)) {
          continue;
        }
        if (localePrefix != null &&
            !StringUtils.startsWithIgnoreCase(
              value: locale,
              prefix: localePrefix,
            )) {
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
            locale: locale.isEmpty ? TtsConstants.unknownVoiceLocale : locale,
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
