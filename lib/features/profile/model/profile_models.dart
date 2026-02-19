import 'package:flutter/foundation.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/string_utils.dart';

enum UserThemeMode {
  system,
  light,
  dark;

  String toApiValue() {
    if (this == UserThemeMode.light) {
      return 'LIGHT';
    }
    if (this == UserThemeMode.dark) {
      return 'DARK';
    }
    return 'SYSTEM';
  }

  static UserThemeMode fromApiValue(String? rawValue) {
    final String? normalizedRawValue = StringUtils.normalizeNullable(rawValue);
    if (normalizedRawValue == null) {
      return UserThemeMode.system;
    }
    final String normalizedValue = StringUtils.toUpper(normalizedRawValue);
    if (normalizedValue == 'LIGHT') {
      return UserThemeMode.light;
    }
    if (normalizedValue == 'DARK') {
      return UserThemeMode.dark;
    }
    return UserThemeMode.system;
  }
}

@immutable
class UserStudySettings {
  const UserStudySettings({
    required this.themeMode,
    required this.studyAutoPlayAudio,
    required this.studyCardsPerSession,
    required this.ttsVoiceId,
    required this.ttsSpeechRate,
    required this.ttsPitch,
    required this.ttsVolume,
  });

  static const bool defaultStudyAutoPlayAudio = false;
  static const int minStudyCardsPerSession = 5;
  static const int maxStudyCardsPerSession = 20;
  static const int defaultStudyCardsPerSession = 10;
  static const double minTtsSpeechRate = 0.2;
  static const double maxTtsSpeechRate = 1.0;
  static const double defaultTtsSpeechRate = 0.48;
  static const double minTtsPitch = 0.5;
  static const double maxTtsPitch = 2.0;
  static const double defaultTtsPitch = 1.0;
  static const double minTtsVolume = 0.0;
  static const double maxTtsVolume = 1.0;
  static const double defaultTtsVolume = 1.0;

  final UserThemeMode themeMode;
  final bool studyAutoPlayAudio;
  final int studyCardsPerSession;
  final String? ttsVoiceId;
  final double ttsSpeechRate;
  final double ttsPitch;
  final double ttsVolume;

  // quality-guard: allow-long-function - JSON parsing keeps typed normalization defaults in a single fail-safe entrypoint.
  factory UserStudySettings.fromJson(Map<String, dynamic> json) {
    final dynamic rawThemeMode = json['themeMode'];
    final dynamic rawStudyAutoPlayAudio = json['studyAutoPlayAudio'];
    final dynamic rawStudyCardsPerSession = json['studyCardsPerSession'];
    final dynamic rawTtsVoiceId = json['ttsVoiceId'];
    final dynamic rawTtsSpeechRate = json['ttsSpeechRate'];
    final dynamic rawTtsPitch = json['ttsPitch'];
    final dynamic rawTtsVolume = json['ttsVolume'];
    final String? themeModeValue = rawThemeMode is String ? rawThemeMode : null;

    bool resolvedStudyAutoPlayAudio = defaultStudyAutoPlayAudio;
    if (rawStudyAutoPlayAudio is bool) {
      resolvedStudyAutoPlayAudio = rawStudyAutoPlayAudio;
    }

    int resolvedStudyCardsPerSession = defaultStudyCardsPerSession;
    if (rawStudyCardsPerSession is num) {
      resolvedStudyCardsPerSession = normalizeStudyCardsPerSession(
        rawStudyCardsPerSession.toInt(),
      );
    }
    String? resolvedTtsVoiceId;
    if (rawTtsVoiceId is String) {
      resolvedTtsVoiceId = StringUtils.normalizeNullable(rawTtsVoiceId);
    }
    double resolvedTtsSpeechRate = defaultTtsSpeechRate;
    if (rawTtsSpeechRate is num) {
      resolvedTtsSpeechRate = normalizeTtsSpeechRate(
        rawTtsSpeechRate.toDouble(),
      );
    }
    double resolvedTtsPitch = defaultTtsPitch;
    if (rawTtsPitch is num) {
      resolvedTtsPitch = normalizeTtsPitch(rawTtsPitch.toDouble());
    }
    double resolvedTtsVolume = defaultTtsVolume;
    if (rawTtsVolume is num) {
      resolvedTtsVolume = normalizeTtsVolume(rawTtsVolume.toDouble());
    }

    return UserStudySettings(
      themeMode: UserThemeMode.fromApiValue(themeModeValue),
      studyAutoPlayAudio: resolvedStudyAutoPlayAudio,
      studyCardsPerSession: resolvedStudyCardsPerSession,
      ttsVoiceId: resolvedTtsVoiceId,
      ttsSpeechRate: resolvedTtsSpeechRate,
      ttsPitch: resolvedTtsPitch,
      ttsVolume: resolvedTtsVolume,
    );
  }

  Map<String, dynamic> toApiPayload() {
    return <String, dynamic>{
      'themeMode': themeMode.toApiValue(),
      'studyAutoPlayAudio': studyAutoPlayAudio,
      'studyCardsPerSession': normalizeStudyCardsPerSession(
        studyCardsPerSession,
      ),
      'ttsVoiceId': StringUtils.normalizeNullable(ttsVoiceId),
      'ttsSpeechRate': normalizeTtsSpeechRate(ttsSpeechRate),
      'ttsPitch': normalizeTtsPitch(ttsPitch),
      'ttsVolume': normalizeTtsVolume(ttsVolume),
    };
  }

  UserStudySettings copyWith({
    UserThemeMode? themeMode,
    bool? studyAutoPlayAudio,
    int? studyCardsPerSession,
    String? ttsVoiceId,
    bool clearTtsVoiceId = false,
    double? ttsSpeechRate,
    double? ttsPitch,
    double? ttsVolume,
  }) {
    final String? nextTtsVoiceId = clearTtsVoiceId
        ? null
        : (ttsVoiceId ?? this.ttsVoiceId);
    return UserStudySettings(
      themeMode: themeMode ?? this.themeMode,
      studyAutoPlayAudio: studyAutoPlayAudio ?? this.studyAutoPlayAudio,
      studyCardsPerSession: normalizeStudyCardsPerSession(
        studyCardsPerSession ?? this.studyCardsPerSession,
      ),
      ttsVoiceId: StringUtils.normalizeNullable(nextTtsVoiceId),
      ttsSpeechRate: normalizeTtsSpeechRate(
        ttsSpeechRate ?? this.ttsSpeechRate,
      ),
      ttsPitch: normalizeTtsPitch(ttsPitch ?? this.ttsPitch),
      ttsVolume: normalizeTtsVolume(ttsVolume ?? this.ttsVolume),
    );
  }

  static int normalizeStudyCardsPerSession(int value) {
    if (value < minStudyCardsPerSession) {
      return minStudyCardsPerSession;
    }
    if (value > maxStudyCardsPerSession) {
      return maxStudyCardsPerSession;
    }
    return value;
  }

  static double normalizeTtsSpeechRate(double value) {
    if (value < minTtsSpeechRate) {
      return minTtsSpeechRate;
    }
    if (value > maxTtsSpeechRate) {
      return maxTtsSpeechRate;
    }
    return value;
  }

  static double normalizeTtsPitch(double value) {
    if (value < minTtsPitch) {
      return minTtsPitch;
    }
    if (value > maxTtsPitch) {
      return maxTtsPitch;
    }
    return value;
  }

  static double normalizeTtsVolume(double value) {
    if (value < minTtsVolume) {
      return minTtsVolume;
    }
    if (value > maxTtsVolume) {
      return maxTtsVolume;
    }
    return value;
  }
}

@immutable
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.email,
    required this.username,
    required this.displayName,
    required this.settings,
  });

  final int userId;
  final String email;
  final String? username;
  final String displayName;
  final UserStudySettings settings;

  // quality-guard: allow-long-function - profile payload parsing validates core fields before delegating normalized settings parsing.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final dynamic rawUserId = json['userId'];
    final dynamic rawEmail = json['email'];
    final dynamic rawUsername = json['username'];
    final dynamic rawDisplayName = json['displayName'];
    final dynamic rawThemeMode = json['themeMode'];
    final dynamic rawStudyAutoPlayAudio = json['studyAutoPlayAudio'];
    final dynamic rawStudyCardsPerSession = json['studyCardsPerSession'];
    final dynamic rawTtsVoiceId = json['ttsVoiceId'];
    final dynamic rawTtsSpeechRate = json['ttsSpeechRate'];
    final dynamic rawTtsPitch = json['ttsPitch'];
    final dynamic rawTtsVolume = json['ttsVolume'];
    if (rawUserId is! num) {
      throw const UnexpectedResponseAppException();
    }
    if (rawEmail is! String) {
      throw const UnexpectedResponseAppException();
    }
    if (rawDisplayName is! String) {
      throw const UnexpectedResponseAppException();
    }
    String? username;
    if (rawUsername is String) {
      username = rawUsername;
    }
    return UserProfile(
      userId: rawUserId.toInt(),
      email: rawEmail,
      username: username,
      displayName: rawDisplayName,
      settings: UserStudySettings.fromJson(<String, dynamic>{
        'themeMode': rawThemeMode,
        'studyAutoPlayAudio': rawStudyAutoPlayAudio,
        'studyCardsPerSession': rawStudyCardsPerSession,
        'ttsVoiceId': rawTtsVoiceId,
        'ttsSpeechRate': rawTtsSpeechRate,
        'ttsPitch': rawTtsPitch,
        'ttsVolume': rawTtsVolume,
      }),
    );
  }
}
