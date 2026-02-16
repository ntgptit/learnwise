import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_theme_mode_controller.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/string_utils.dart';
import '../model/profile_constants.dart';
import '../model/profile_models.dart';
import '../viewmodel/profile_viewmodel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _displayNameController;
  late final ValueNotifier<_ProfileSettingsDraft> _settingsDraftNotifier;
  int? _boundUserId;
  String? _boundSettingsSignature;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _settingsDraftNotifier = ValueNotifier<_ProfileSettingsDraft>(
      const _ProfileSettingsDraft(
        themeMode: UserThemeMode.system,
        studyAutoPlayAudio: UserStudySettings.defaultStudyAutoPlayAudio,
        studyCardsPerSession: UserStudySettings.defaultStudyCardsPerSession,
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
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
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: state.when(
          data: (profile) {
            _bindDisplayName(profile);
            _bindSettings(profile);
            return ListView(
              padding: const EdgeInsets.all(AppSizes.spacingMd),
              children: <Widget>[
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.profilePersonalInformationTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.spacingMd),
                      Text(
                        l10n.profileUserIdLabel(profile.userId),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSizes.spacingXs),
                      Text(
                        l10n.profileEmailLabel(profile.email),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSizes.spacingMd),
                      AppTextField(
                        controller: _displayNameController,
                        label: l10n.profileDisplayNameLabel,
                        hint: l10n.profileDisplayNameHint,
                      ),
                      const SizedBox(height: AppSizes.spacingMd),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _displayNameController,
                        builder: (context, value, _) {
                          final String? normalizedInput =
                              StringUtils.normalizeNullable(value.text);
                          final String normalizedProfileName = StringUtils
                              .normalize(profile.displayName);
                          final bool isChanged =
                              normalizedInput != null &&
                              normalizedInput != normalizedProfileName;
                          return PrimaryButton(
                            label: l10n.profileSaveChangesLabel,
                            onPressed: isChanged
                                ? () => _submitProfileUpdate(controller)
                                : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: ValueListenableBuilder<_ProfileSettingsDraft>(
                    valueListenable: _settingsDraftNotifier,
                    builder: (context, draft, _) {
                      final bool isSettingsChanged = _isSettingsChanged(
                        profile: profile,
                        draft: draft,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.profileSettingsTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSizes.spacingMd),
                          DropdownButtonFormField<UserThemeMode>(
                            key: ValueKey<UserThemeMode>(draft.themeMode),
                            initialValue: draft.themeMode,
                            decoration: InputDecoration(
                              labelText: l10n.profileThemeLabel,
                            ),
                            items: <DropdownMenuItem<UserThemeMode>>[
                              DropdownMenuItem<UserThemeMode>(
                                value: UserThemeMode.system,
                                child: Text(l10n.profileThemeSystemOption),
                              ),
                              DropdownMenuItem<UserThemeMode>(
                                value: UserThemeMode.light,
                                child: Text(l10n.profileThemeLightOption),
                              ),
                              DropdownMenuItem<UserThemeMode>(
                                value: UserThemeMode.dark,
                                child: Text(l10n.profileThemeDarkOption),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              _settingsDraftNotifier.value = draft.copyWith(
                                themeMode: value,
                              );
                            },
                          ),
                          const SizedBox(height: AppSizes.spacingMd),
                          SwitchListTile.adaptive(
                            value: draft.studyAutoPlayAudio,
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.profileStudyAutoPlayAudioLabel),
                            onChanged: (value) {
                              _settingsDraftNotifier.value = draft.copyWith(
                                studyAutoPlayAudio: value,
                              );
                            },
                          ),
                          const SizedBox(height: AppSizes.spacingMd),
                          DropdownButtonFormField<int>(
                            key: ValueKey<int>(draft.studyCardsPerSession),
                            initialValue: draft.studyCardsPerSession,
                            decoration: InputDecoration(
                              labelText: l10n.profileStudyCardsPerSessionLabel,
                            ),
                            items: _studyCardsPerSessionOptions
                                .map(
                                  (option) => DropdownMenuItem<int>(
                                    value: option,
                                    child: Text(
                                      l10n.profileStudyCardsPerSessionOption(
                                        option,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              _settingsDraftNotifier.value = draft.copyWith(
                                studyCardsPerSession: value,
                              );
                            },
                          ),
                          const SizedBox(height: AppSizes.spacingMd),
                          PrimaryButton(
                            label: l10n.profileSaveSettingsLabel,
                            onPressed: isSettingsChanged
                                ? () => _submitSettingsUpdate(
                                    controller: controller,
                                    themeModeController: themeModeController,
                                    draft: draft,
                                  )
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                OutlinedButton.icon(
                  onPressed: controller.signOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.profileSignOutLabel),
                ),
              ],
            );
          },
          error: (error, stackTrace) {
            final String message = _resolveErrorMessage(
              error: error,
              l10n: l10n,
            );
            return ErrorState(
              title: l10n.profileLoadErrorTitle,
              message: message,
              retryLabel: l10n.profileRetryLabel,
              onRetry: controller.refresh,
            );
          },
          loading: () {
            return LoadingState(message: l10n.profileLoadingLabel);
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        destinations: <AppBottomNavDestination>[
          AppBottomNavDestination(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: l10n.dashboardNavHome,
          ),
          AppBottomNavDestination(
            icon: Icons.folder_open_outlined,
            selectedIcon: Icons.folder_rounded,
            label: l10n.dashboardNavFolders,
          ),
          AppBottomNavDestination(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.dashboardNavProfile,
          ),
        ],
        selectedIndex: ProfileConstants.profileNavIndex,
        onDestinationSelected: (index) {
          if (index == ProfileConstants.dashboardNavIndex) {
            context.go(RouteNames.dashboard);
            return;
          }
          if (index == ProfileConstants.foldersNavIndex) {
            context.go(RouteNames.folders);
            return;
          }
          if (index == ProfileConstants.profileNavIndex) {
            return;
          }
        },
      ),
    );
  }

  Future<void> _submitProfileUpdate(ProfileController controller) async {
    final String? displayName = StringUtils.normalizeNullable(
      _displayNameController.text,
    );
    if (displayName == null) {
      return;
    }
    await controller.updateDisplayName(displayName);
  }

  Future<void> _submitSettingsUpdate({
    required ProfileController controller,
    required AppThemeModeController themeModeController,
    required _ProfileSettingsDraft draft,
  }) async {
    final UserStudySettings updatedSettings = UserStudySettings(
      themeMode: draft.themeMode,
      studyAutoPlayAudio: draft.studyAutoPlayAudio,
      studyCardsPerSession: draft.studyCardsPerSession,
    );
    final bool updated = await controller.updateSettings(updatedSettings);
    if (!updated) {
      return;
    }
    await themeModeController.setThemeMode(_toThemeMode(draft.themeMode));
  }

  void _bindDisplayName(UserProfile profile) {
    if (_boundUserId == profile.userId &&
        _displayNameController.text == profile.displayName) {
      return;
    }
    _boundUserId = profile.userId;
    _displayNameController.value = TextEditingValue(
      text: profile.displayName,
      selection: TextSelection.collapsed(offset: profile.displayName.length),
    );
  }

  void _bindSettings(UserProfile profile) {
    final String settingsSignature = _toSettingsSignature(profile.settings);
    if (_boundUserId == profile.userId &&
        _boundSettingsSignature == settingsSignature) {
      return;
    }
    _boundSettingsSignature = settingsSignature;
    _settingsDraftNotifier.value = _ProfileSettingsDraft(
      themeMode: profile.settings.themeMode,
      studyAutoPlayAudio: profile.settings.studyAutoPlayAudio,
      studyCardsPerSession: profile.settings.studyCardsPerSession,
    );
  }

  bool _isSettingsChanged({
    required UserProfile profile,
    required _ProfileSettingsDraft draft,
  }) {
    if (draft.themeMode != profile.settings.themeMode) {
      return true;
    }
    if (draft.studyAutoPlayAudio != profile.settings.studyAutoPlayAudio) {
      return true;
    }
    if (draft.studyCardsPerSession != profile.settings.studyCardsPerSession) {
      return true;
    }
    return false;
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

class _ProfileSettingsDraft {
  const _ProfileSettingsDraft({
    required this.themeMode,
    required this.studyAutoPlayAudio,
    required this.studyCardsPerSession,
  });

  final UserThemeMode themeMode;
  final bool studyAutoPlayAudio;
  final int studyCardsPerSession;

  _ProfileSettingsDraft copyWith({
    UserThemeMode? themeMode,
    bool? studyAutoPlayAudio,
    int? studyCardsPerSession,
  }) {
    return _ProfileSettingsDraft(
      themeMode: themeMode ?? this.themeMode,
      studyAutoPlayAudio: studyAutoPlayAudio ?? this.studyAutoPlayAudio,
      studyCardsPerSession:
          studyCardsPerSession ?? this.studyCardsPerSession,
    );
  }
}

const List<int> _studyCardsPerSessionOptions = <int>[5, 10, 15, 20, 25, 30, 40, 50];
