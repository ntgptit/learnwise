import '../model/tts_models.dart';

abstract class TtsRepository {
  Future<void> init({TtsVoiceSettings settings = const TtsVoiceSettings()});

  Future<void> speak(
    String text, {
    TtsLanguageMode mode = TtsLanguageMode.auto,
    TtsVoiceSettings settings = const TtsVoiceSettings(),
    TtsVoiceOption? voice,
  });

  Future<void> stop();

  Future<void> dispose();

  Future<List<TtsVoiceOption>> getAvailableVoices({String? localePrefix});
}
