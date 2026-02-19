import '../../model/profile_models.dart';

class ProfileSettingsDraft {
  const ProfileSettingsDraft({
    required this.themeMode,
    required this.studyAutoPlayAudio,
    required this.studyCardsPerSession,
  });

  final UserThemeMode themeMode;
  final bool studyAutoPlayAudio;
  final int studyCardsPerSession;

  ProfileSettingsDraft copyWith({
    UserThemeMode? themeMode,
    bool? studyAutoPlayAudio,
    int? studyCardsPerSession,
  }) {
    return ProfileSettingsDraft(
      themeMode: themeMode ?? this.themeMode,
      studyAutoPlayAudio: studyAutoPlayAudio ?? this.studyAutoPlayAudio,
      studyCardsPerSession: UserStudySettings.normalizeStudyCardsPerSession(
        studyCardsPerSession ?? this.studyCardsPerSession,
      ),
    );
  }
}
