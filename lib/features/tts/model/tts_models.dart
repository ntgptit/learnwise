import 'package:flutter/foundation.dart';

import 'tts_const.dart';

@immutable
class TtsVoiceSettings {
  const TtsVoiceSettings({
    this.speechRate = TtsConst.defaultSpeechRate,
    this.volume = TtsConst.defaultVolume,
    this.pitch = TtsConst.defaultPitch,
  });

  final double speechRate;
  final double volume;
  final double pitch;
}

enum TtsLanguageMode { auto, english, korean }

@immutable
class TtsVoiceOption {
  const TtsVoiceOption({
    required this.id,
    required this.name,
    required this.locale,
    required this.params,
  });

  final String id;
  final String name;
  final String locale;
  final Map<String, String> params;

  String get displayLabel => '$name ($locale)';
}
