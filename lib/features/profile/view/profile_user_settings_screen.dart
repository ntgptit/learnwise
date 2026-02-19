import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme_mode_controller.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../../core/error/app_exception.dart';
import '../model/profile_models.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'widgets/profile_settings_draft.dart';
import 'widgets/profile_tts_voice_settings_section.dart';
import 'widgets/settings_section.dart';

class ProfileUserSettingsScreen extends ConsumerStatefulWidget {
  const ProfileUserSettingsScreen({super.key});

  @override
  ConsumerState<ProfileUserSettingsScreen> createState() =>
      _ProfileUserSettingsScreenState();
}

class _ProfileUserSettingsScreenState
    extends ConsumerState<ProfileUserSettingsScreen> {
  late final ValueNotifier<ProfileSettingsDraft> _settingsDraftNotifier;
  int? _boundUserId;
  String? _boundSettingsSignature;

  @override
  void initState() {
    super.initState();
    _settingsDraftNotifier = ValueNotifier<ProfileSettingsDraft>(
      const ProfileSettingsDraft(
        themeMode: UserThemeMode.system,
        studyAutoPlayAudio: UserStudySettings.defaultStudyAutoPlayAudio,
        studyCardsPerSession: UserStudySettings.defaultStudyCardsPerSession,
      ),
    );
  }

  @override
  void dispose() {
    _settingsDraftNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<UserProfile> state = ref.watch(profileControllerProvider);
    final ProfileController controller = ref.read(
      profileControllerProvider.notifier,
    );
    final AppThemeModeController themeModeController = ref.read(
      appThemeModeControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => const ProfileRoute().go(context),
        ),
        title: Text(l10n.profileSettingsTitle),
      ),
      body: _buildBody(
        l10n: l10n,
        state: state,
        controller: controller,
        themeModeController: themeModeController,
      ),
    );
  }

  Widget _buildBody({
    required AppLocalizations l10n,
    required AsyncValue<UserProfile> state,
    required ProfileController controller,
    required AppThemeModeController themeModeController,
  }) {
    return SafeArea(
      child: state.when(
        data: (profile) => _buildDataState(
          profile: profile,
          controller: controller,
          themeModeController: themeModeController,
        ),
        error: (error, _) =>
            _buildErrorState(l10n: l10n, error: error, controller: controller),
        loading: () => LwLoadingState(message: l10n.profileLoadingLabel),
      ),
    );
  }

  Widget _buildDataState({
    required UserProfile profile,
    required ProfileController controller,
    required AppThemeModeController themeModeController,
  }) {
    _bindSettings(profile);
    final double bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSizes.spacingLg,
        AppSizes.spacingLg,
        AppSizes.spacingLg,
        AppSizes.spacing2Xl + bottomSafeArea,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SettingsSection(
            profile: profile,
            settingsDraftNotifier: _settingsDraftNotifier,
            onSave: (draft) => _submitSettingsUpdate(
              controller: controller,
              themeModeController: themeModeController,
              draft: draft,
              baseSettings: profile.settings,
            ),
          ),
          const SizedBox(height: AppSizes.spacingLg),
          const ProfileTtsVoiceSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required AppLocalizations l10n,
    required Object error,
    required ProfileController controller,
  }) {
    final String message = _resolveErrorMessage(error: error, l10n: l10n);
    return LwErrorState(
      title: l10n.profileLoadErrorTitle,
      message: message,
      retryLabel: l10n.profileRetryLabel,
      onRetry: controller.refresh,
    );
  }

  Future<void> _submitSettingsUpdate({
    required ProfileController controller,
    required AppThemeModeController themeModeController,
    required ProfileSettingsDraft draft,
    required UserStudySettings baseSettings,
  }) async {
    final UserStudySettings updatedSettings = UserStudySettings(
      themeMode: draft.themeMode,
      studyAutoPlayAudio: draft.studyAutoPlayAudio,
      studyCardsPerSession: draft.studyCardsPerSession,
      ttsVoiceId: baseSettings.ttsVoiceId,
      ttsSpeechRate: baseSettings.ttsSpeechRate,
      ttsPitch: baseSettings.ttsPitch,
      ttsVolume: baseSettings.ttsVolume,
    );
    final bool updated = await controller.updateSettings(updatedSettings);
    if (!updated) {
      return;
    }
    await themeModeController.setThemeMode(_toThemeMode(draft.themeMode));
  }

  void _bindSettings(UserProfile profile) {
    final String settingsSignature = _toSettingsSignature(profile.settings);
    if (_boundUserId == profile.userId &&
        _boundSettingsSignature == settingsSignature) {
      return;
    }
    _boundUserId = profile.userId;
    _boundSettingsSignature = settingsSignature;
    _settingsDraftNotifier.value = ProfileSettingsDraft(
      themeMode: profile.settings.themeMode,
      studyAutoPlayAudio: profile.settings.studyAutoPlayAudio,
      studyCardsPerSession: profile.settings.studyCardsPerSession,
    );
  }

  String _toSettingsSignature(UserStudySettings settings) {
    return '${settings.themeMode.name}|${settings.studyAutoPlayAudio}|${settings.studyCardsPerSession}';
  }

  ThemeMode _toThemeMode(UserThemeMode mode) {
    if (mode == UserThemeMode.light) {
      return ThemeMode.light;
    }
    if (mode == UserThemeMode.dark) {
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  String _resolveErrorMessage({
    required Object error,
    required AppLocalizations l10n,
  }) {
    if (error is AppException) {
      return error.message;
    }
    return l10n.profileDefaultErrorMessage;
  }
}
