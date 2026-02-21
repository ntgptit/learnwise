import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme_mode_controller.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../../core/error/app_exception.dart';
import '../../tts/viewmodel/tts_viewmodel.dart';
import '../model/profile_constants.dart';
import '../model/profile_models.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'widgets/settings/profile_settings_draft.dart';
import 'widgets/settings/settings_section.dart';
import 'widgets/settings/tts/profile_tts_voice_settings_section.dart';

class ProfileUserSettingsScreen extends HookConsumerWidget {
  const ProfileUserSettingsScreen({super.key});

  @override
  // quality-guard: allow-long-function - build composes pop handling, appbar back behavior, and data-state wiring in one lifecycle-safe entrypoint.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<UserProfile> state = ref.watch(profileControllerProvider);
    final ProfileController controller = ref.read(
      profileControllerProvider.notifier,
    );
    final AppThemeModeController themeModeController = ref.read(
      appThemeModeControllerProvider.notifier,
    );
    final ScrollController scrollController = useScrollController();
    final ValueNotifier<ProfileSettingsDraft> settingsDraftNotifier =
        useValueNotifier<ProfileSettingsDraft>(
          const ProfileSettingsDraft(
            themeMode: UserThemeMode.system,
            studyAutoPlayAudio: UserStudySettings.defaultStudyAutoPlayAudio,
            studyCardsPerSession: UserStudySettings.defaultStudyCardsPerSession,
          ),
        );
    final ObjectRef<int?> boundUserIdRef = useRef<int?>(null);
    final ObjectRef<String?> boundSettingsSignatureRef = useRef<String?>(null);
    final LwPageContentState contentState = _resolveContentState(state);
    final UserProfile? profile = _resolveProfile(state);
    final String errorMessage = _resolveErrorMessageFromState(
      l10n: l10n,
      state: state,
    );
    useEffect(
      () {
        final UserProfile? data = profile;
        if (data == null) {
          return null;
        }
        _bindSettings(
          profile: data,
          settingsDraftNotifier: settingsDraftNotifier,
          boundUserIdRef: boundUserIdRef,
          boundSettingsSignatureRef: boundSettingsSignatureRef,
        );
        return null;
      },
      <Object?>[
        profile?.userId,
        profile == null ? null : _toSettingsSignature(profile.settings),
        settingsDraftNotifier,
      ],
    );
    final VoidCallback onRefresh = useCallback(() {
      _refresh(controller);
    }, <Object?>[controller]);
    final VoidCallback onTapBack = useCallback(() {
      _onBackPressed(context: context, ref: ref);
    }, <Object?>[context, ref]);
    final VoidCallback onRefreshAndScrollToTop = useCallback(() {
      _refreshAndScrollToTop(
        controller: controller,
        scrollController: scrollController,
      );
    }, <Object?>[controller, scrollController]);

    return PopScope<void>(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          return;
        }
        unawaited(_stopVoiceReading(ref));
      },
      child: LwPageTemplate(
        title: l10n.profileSettingsTitle,
        appBarLeadingAction: LwPageLeadingAction.back,
        body: _ProfileUserSettingsBody(
          profile: profile,
          settingsDraftNotifier: settingsDraftNotifier,
          controller: controller,
          themeModeController: themeModeController,
          scrollController: scrollController,
        ),
        selectedIndex: ProfileConstants.profileNavIndex,
        contentState: contentState,
        loadingMessage: l10n.profileLoadingLabel,
        errorTitle: l10n.profileLoadErrorTitle,
        errorMessage: errorMessage,
        errorRetryLabel: l10n.profileRetryLabel,
        contentPadding: EdgeInsets.zero,
        onTapBack: onTapBack,
        onRetry: onRefresh,
        onRefreshAndScrollToTop: onRefreshAndScrollToTop,
        onDestinationSelected: (index) {
          _onDestinationSelected(context: context, ref: ref, index: index);
        },
        onRefresh: onRefresh,
      ),
    );
  }

  LwPageContentState _resolveContentState(AsyncValue<UserProfile> state) {
    return state.when(
      data: (_) => LwPageContentState.content,
      error: (error, stackTrace) => LwPageContentState.error,
      loading: () => LwPageContentState.loading,
    );
  }

  UserProfile? _resolveProfile(AsyncValue<UserProfile> state) {
    return state.when(
      data: (profile) => profile,
      error: (error, stackTrace) => null,
      loading: () => null,
    );
  }

  String _resolveErrorMessageFromState({
    required AppLocalizations l10n,
    required AsyncValue<UserProfile> state,
  }) {
    return state.when(
      data: (_) => l10n.profileDefaultErrorMessage,
      error: (error, stackTrace) {
        return _resolveErrorMessage(error: error, l10n: l10n);
      },
      loading: () => l10n.profileDefaultErrorMessage,
    );
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

  void _onDestinationSelected({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
  }) {
    unawaited(_stopVoiceReading(ref));
    if (index == ProfileConstants.dashboardNavIndex) {
      const DashboardRoute().go(context);
      return;
    }
    if (index == ProfileConstants.foldersNavIndex) {
      const FoldersRoute().go(context);
      return;
    }
    const ProfileRoute().go(context);
  }

  void _bindSettings({
    required UserProfile profile,
    required ValueNotifier<ProfileSettingsDraft> settingsDraftNotifier,
    required ObjectRef<int?> boundUserIdRef,
    required ObjectRef<String?> boundSettingsSignatureRef,
  }) {
    final String settingsSignature = _toSettingsSignature(profile.settings);
    if (boundUserIdRef.value == profile.userId &&
        boundSettingsSignatureRef.value == settingsSignature) {
      return;
    }
    boundUserIdRef.value = profile.userId;
    boundSettingsSignatureRef.value = settingsSignature;
    settingsDraftNotifier.value = ProfileSettingsDraft(
      themeMode: profile.settings.themeMode,
      studyAutoPlayAudio: profile.settings.studyAutoPlayAudio,
      studyCardsPerSession: profile.settings.studyCardsPerSession,
    );
  }

  String _toSettingsSignature(UserStudySettings settings) {
    return '${settings.themeMode.name}|${settings.studyAutoPlayAudio}|${settings.studyCardsPerSession}';
  }

  void _onBackPressed({required BuildContext context, required WidgetRef ref}) {
    unawaited(_stopVoiceReading(ref));
    if (context.canPop()) {
      context.pop();
      return;
    }
    const ProfileRoute().go(context);
  }

  Future<void> _stopVoiceReading(WidgetRef ref) async {
    final TtsController ttsController = ref.read(
      ttsControllerProvider.notifier,
    );
    await ttsController.stopReading();
  }

  void _refresh(ProfileController controller) {
    unawaited(controller.refresh());
  }

  void _refreshAndScrollToTop({
    required ProfileController controller,
    required ScrollController scrollController,
  }) {
    if (scrollController.hasClients) {
      unawaited(
        scrollController.animateTo(
          0,
          duration: AppDurations.animationFast,
          curve: AppMotionCurves.decelerateCubic,
        ),
      );
    }
    _refresh(controller);
  }
}

class _ProfileUserSettingsBody extends StatelessWidget {
  const _ProfileUserSettingsBody({
    required this.profile,
    required this.settingsDraftNotifier,
    required this.controller,
    required this.themeModeController,
    required this.scrollController,
  });

  static const double _screenHorizontalPadding = AppSizes.spacingMd;
  static const double _screenTopPadding = AppSizes.spacingMd;
  static const double _screenBottomPadding = AppSizes.spacingMd;
  static const double _sectionGap = AppSizes.spacingMd;

  final UserProfile? profile;
  final ValueNotifier<ProfileSettingsDraft> settingsDraftNotifier;
  final ProfileController controller;
  final AppThemeModeController themeModeController;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final UserProfile? resolvedProfile = profile;
    if (resolvedProfile == null) {
      return const SizedBox.shrink();
    }
    final double bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              _screenHorizontalPadding,
              _screenTopPadding,
              _screenHorizontalPadding,
              _screenBottomPadding + bottomSafeArea,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SettingsSection(
                    profile: resolvedProfile,
                    settingsDraftNotifier: settingsDraftNotifier,
                    onSave: (draft) {
                      unawaited(
                        _submitSettingsUpdate(
                          controller: controller,
                          themeModeController: themeModeController,
                          draft: draft,
                          baseSettings: resolvedProfile.settings,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: _sectionGap),
                  const ProfileTtsVoiceSettingsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
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

  ThemeMode _toThemeMode(UserThemeMode mode) {
    if (mode == UserThemeMode.light) {
      return ThemeMode.light;
    }
    if (mode == UserThemeMode.dark) {
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }
}
