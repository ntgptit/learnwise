import 'package:freezed_annotation/freezed_annotation.dart';

import 'tts_constants.dart';

part 'tts_models.freezed.dart';
part 'tts_models.g.dart';

@freezed
sealed class TtsVoiceSettings with _$TtsVoiceSettings {
  @JsonSerializable(explicitToJson: true)
  const factory TtsVoiceSettings({
    @Default(TtsConstants.defaultSpeechRate) double speechRate,
    @Default(TtsConstants.defaultVolume) double volume,
    @Default(TtsConstants.defaultPitch) double pitch,
  }) = _TtsVoiceSettings;

  factory TtsVoiceSettings.fromJson(Map<String, dynamic> json) =>
      _$TtsVoiceSettingsFromJson(json);
}

enum TtsLanguageMode { auto, english, korean }

@freezed
sealed class TtsVoiceOption with _$TtsVoiceOption {
  const TtsVoiceOption._();

  @JsonSerializable(explicitToJson: true)
  const factory TtsVoiceOption({
    required String id,
    required String name,
    required String locale,
    required Map<String, String> params,
  }) = _TtsVoiceOption;

  factory TtsVoiceOption.fromJson(Map<String, dynamic> json) =>
      _$TtsVoiceOptionFromJson(json);

  String get displayLabel => '$name ($locale)';
}
