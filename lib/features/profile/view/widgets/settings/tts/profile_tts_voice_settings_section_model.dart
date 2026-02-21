part of 'profile_tts_voice_settings_section.dart';

class _TtsDraft {
  const _TtsDraft({
    required this.voiceId,
    required this.speechRate,
    required this.pitch,
    required this.volume,
  });

  final String? voiceId;
  final double speechRate;
  final double pitch;
  final double volume;

  factory _TtsDraft.initial() {
    return const _TtsDraft(
      voiceId: null,
      speechRate: UserStudySettings.defaultTtsSpeechRate,
      pitch: UserStudySettings.defaultTtsPitch,
      volume: UserStudySettings.defaultTtsVolume,
    );
  }

  factory _TtsDraft.fromSettings(UserStudySettings settings) {
    return _TtsDraft(
      voiceId: settings.ttsVoiceId,
      speechRate: settings.ttsSpeechRate,
      pitch: settings.ttsPitch,
      volume: settings.ttsVolume,
    );
  }

  _TtsDraft copyWith({
    String? voiceId,
    bool clearVoiceId = false,
    double? speechRate,
    double? pitch,
    double? volume,
  }) {
    final String? nextVoiceId = clearVoiceId ? null : (voiceId ?? this.voiceId);
    return _TtsDraft(
      voiceId: nextVoiceId,
      speechRate: UserStudySettings.normalizeTtsSpeechRate(
        speechRate ?? this.speechRate,
      ),
      pitch: UserStudySettings.normalizeTtsPitch(pitch ?? this.pitch),
      volume: UserStudySettings.normalizeTtsVolume(volume ?? this.volume),
    );
  }
}

class _LanguageCode {
  const _LanguageCode._();

  static const String en = 'en';
  static const String vi = 'vi';
  static const String ko = 'ko';
  static const String ja = 'ja';
}
