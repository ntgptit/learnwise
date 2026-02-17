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
    final String normalizedValue = normalizedRawValue.toUpperCase();
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
  });

  static const bool defaultStudyAutoPlayAudio = false;
  static const int minStudyCardsPerSession = 5;
  static const int maxStudyCardsPerSession = 20;
  static const int defaultStudyCardsPerSession = 10;

  final UserThemeMode themeMode;
  final bool studyAutoPlayAudio;
  final int studyCardsPerSession;

  factory UserStudySettings.fromJson(Map<String, dynamic> json) {
    final dynamic rawThemeMode = json['themeMode'];
    final dynamic rawStudyAutoPlayAudio = json['studyAutoPlayAudio'];
    final dynamic rawStudyCardsPerSession = json['studyCardsPerSession'];
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

    return UserStudySettings(
      themeMode: UserThemeMode.fromApiValue(themeModeValue),
      studyAutoPlayAudio: resolvedStudyAutoPlayAudio,
      studyCardsPerSession: resolvedStudyCardsPerSession,
    );
  }

  Map<String, dynamic> toApiPayload() {
    return <String, dynamic>{
      'themeMode': themeMode.toApiValue(),
      'studyAutoPlayAudio': studyAutoPlayAudio,
      'studyCardsPerSession': normalizeStudyCardsPerSession(
        studyCardsPerSession,
      ),
    };
  }

  UserStudySettings copyWith({
    UserThemeMode? themeMode,
    bool? studyAutoPlayAudio,
    int? studyCardsPerSession,
  }) {
    return UserStudySettings(
      themeMode: themeMode ?? this.themeMode,
      studyAutoPlayAudio: studyAutoPlayAudio ?? this.studyAutoPlayAudio,
      studyCardsPerSession: normalizeStudyCardsPerSession(
        studyCardsPerSession ?? this.studyCardsPerSession,
      ),
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
}

@immutable
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.settings,
  });

  final int userId;
  final String email;
  final String displayName;
  final UserStudySettings settings;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final dynamic rawUserId = json['userId'];
    final dynamic rawEmail = json['email'];
    final dynamic rawDisplayName = json['displayName'];
    final dynamic rawThemeMode = json['themeMode'];
    final dynamic rawStudyAutoPlayAudio = json['studyAutoPlayAudio'];
    final dynamic rawStudyCardsPerSession = json['studyCardsPerSession'];
    if (rawUserId is! num) {
      throw const UnexpectedResponseAppException();
    }
    if (rawEmail is! String) {
      throw const UnexpectedResponseAppException();
    }
    if (rawDisplayName is! String) {
      throw const UnexpectedResponseAppException();
    }
    return UserProfile(
      userId: rawUserId.toInt(),
      email: rawEmail,
      displayName: rawDisplayName,
      settings: UserStudySettings.fromJson(<String, dynamic>{
        'themeMode': rawThemeMode,
        'studyAutoPlayAudio': rawStudyAutoPlayAudio,
        'studyCardsPerSession': rawStudyCardsPerSession,
      }),
    );
  }
}
