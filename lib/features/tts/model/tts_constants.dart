class TtsConstants {
  const TtsConstants._();

  static const double defaultSpeechRate = 0.48;
  static const double defaultPitch = 1.0;
  static const double defaultVolume = 1.0;

  static const double speechRateMin = 0.2;
  static const double speechRateMax = 1.0;
  static const double pitchMin = 0.5;
  static const double pitchMax = 2.0;
  static const double volumeMin = 0.0;
  static const double volumeMax = 1.0;

  static const int sliderDivisions = 20;
  static const int sliderPrecision = 2;
  static const int livePreviewDebounceMilliseconds = 400;
  static const int speechRetryDelayMilliseconds = 120;
  static const int voiceAliasPadWidth = 2;
  static const String voiceAliasPadChar = '0';
  static const String speechSynthesisErrorToken = 'speechsynthesiserrorevent';
  static const String warmUpText = ' ';

  static const String koreanLocalePrefix = 'ko';
  static const String englishLanguageCode = 'en-US';
  static const String koreanLanguageCode = 'ko-KR';
  static const String unknownVoiceLocale = 'unknown';
  static const String hangulPattern =
      r'[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AF]';

  static const List<String> voiceIdKeys = <String>[
    'identifier',
    'name',
    'voice',
  ];
  static const List<String> voiceNameKeys = <String>[
    'name',
    'identifier',
    'voice',
  ];
  static const List<String> voiceLocaleKeys = <String>['locale', 'language'];
}
