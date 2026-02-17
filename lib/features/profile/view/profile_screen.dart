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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: state.when(
          data: (profile) {
            _bindDisplayName(profile);
            _bindSettings(profile);
            return CustomScrollView(
              slivers: <Widget>[
                // Modern Header with Avatar
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          colorScheme.primaryContainer,
                          colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.spacingMd,
                          AppSizes.spacingMd,
                          AppSizes.spacingMd,
                          AppSizes.size32,
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  l10n.profileTitle,
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                IconButton(
                                  onPressed: controller.signOut,
                                  icon: Icon(
                                    Icons.logout_rounded,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                  tooltip: l10n.profileSignOutLabel,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.spacingLg),
                            // Avatar
                            Container(
                              width: AppSizes.size72,
                              height: AppSizes.size72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: AppSizes.size1,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: colorScheme.shadow.withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: AppSizes.size24,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacingMd),
                            Text(
                              profile.displayName,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacingXs),
                            Text(
                              profile.email,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(AppSizes.spacingMd),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        // Personal Information Section
                        _buildSectionHeader(
                          context: context,
                          icon: Icons.person_outline_rounded,
                          title: l10n.profilePersonalInformationTitle,
                        ),
                        const SizedBox(height: AppSizes.spacingSm),
                        AppCard(
                          variant: AppCardVariant.elevated,
                          child: Column(
                            children: <Widget>[
                              _buildInfoTile(
                                context: context,
                                icon: Icons.badge_outlined,
                                label: 'User ID',
                                value: profile.userId.toString(),
                              ),
                              Divider(
                                height: AppSizes.size1,
                                color: colorScheme.outlineVariant,
                              ),
                              _buildInfoTile(
                                context: context,
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: profile.email,
                              ),
                              Divider(
                                height: AppSizes.size1,
                                color: colorScheme.outlineVariant,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(AppSizes.spacingMd),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
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
                                            StringUtils.normalizeNullable(
                                              value.text,
                                            );
                                        final String normalizedProfileName =
                                            StringUtils.normalize(
                                              profile.displayName,
                                            );
                                        final bool isChanged =
                                            normalizedInput != null &&
                                            normalizedInput !=
                                                normalizedProfileName;
                                        return PrimaryButton(
                                          label: l10n.profileSaveChangesLabel,
                                          onPressed: isChanged
                                              ? () => _submitProfileUpdate(
                                                  controller,
                                                )
                                              : null,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingLg),
                        // Preferences Section
                        _buildSectionHeader(
                          context: context,
                          icon: Icons.tune_rounded,
                          title: l10n.profileSettingsTitle,
                        ),
                        const SizedBox(height: AppSizes.spacingSm),
                        ValueListenableBuilder<_ProfileSettingsDraft>(
                          valueListenable: _settingsDraftNotifier,
                          builder: (context, draft, _) {
                            final bool isSettingsChanged = _isSettingsChanged(
                              profile: profile,
                              draft: draft,
                            );
                            return AppCard(
                              variant: AppCardVariant.elevated,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Theme Mode with Segmented Button
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSizes.spacingMd,
                                      AppSizes.spacingMd,
                                      AppSizes.spacingMd,
                                      AppSizes.spacingSm,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.palette_outlined,
                                          size: AppSizes.size24,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: AppSizes.spacingSm),
                                        Text(
                                          l10n.profileThemeLabel,
                                          style: textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.spacingMd,
                                    ),
                                    child: SegmentedButton<UserThemeMode>(
                                      segments: <ButtonSegment<UserThemeMode>>[
                                        ButtonSegment<UserThemeMode>(
                                          value: UserThemeMode.system,
                                          label: Text(
                                            l10n.profileThemeSystemOption,
                                          ),
                                          icon: const Icon(
                                            Icons.brightness_auto_rounded,
                                          ),
                                        ),
                                        ButtonSegment<UserThemeMode>(
                                          value: UserThemeMode.light,
                                          label: Text(
                                            l10n.profileThemeLightOption,
                                          ),
                                          icon: const Icon(
                                            Icons.light_mode_rounded,
                                          ),
                                        ),
                                        ButtonSegment<UserThemeMode>(
                                          value: UserThemeMode.dark,
                                          label: Text(
                                            l10n.profileThemeDarkOption,
                                          ),
                                          icon: const Icon(
                                            Icons.dark_mode_rounded,
                                          ),
                                        ),
                                      ],
                                      selected: <UserThemeMode>{draft.themeMode},
                                      onSelectionChanged: (newSelection) {
                                        _settingsDraftNotifier.value =
                                            draft.copyWith(
                                          themeMode: newSelection.first,
                                        );
                                      },
                                      showSelectedIcon: false,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.spacingMd),
                                  Divider(
                                    height: AppSizes.size1,
                                    color: colorScheme.outlineVariant,
                                  ),
                                  // Auto Play Audio Switch
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusSm,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.volume_up_rounded,
                                        size: AppSizes.size24,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    title: Text(
                                      l10n.profileStudyAutoPlayAudioLabel,
                                      style: textTheme.bodyLarge,
                                    ),
                                    trailing: Switch.adaptive(
                                      value: draft.studyAutoPlayAudio,
                                      onChanged: (value) {
                                        _settingsDraftNotifier.value =
                                            draft.copyWith(
                                          studyAutoPlayAudio: value,
                                        );
                                      },
                                    ),
                                  ),
                                  Divider(
                                    height: AppSizes.size1,
                                    color: colorScheme.outlineVariant,
                                  ),
                                  // Cards Per Session with Slider
                                  Padding(
                                    padding: const EdgeInsets.all(
                                      AppSizes.spacingMd,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: colorScheme
                                                    .secondaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppSizes.radiusSm,
                                                    ),
                                              ),
                                              child: Icon(
                                                Icons.collections_bookmark_rounded,
                                                size: AppSizes.size24,
                                                color: colorScheme
                                                    .onSecondaryContainer,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: AppSizes.spacingSm,
                                            ),
                                            Expanded(
                                              child: Text(
                                                l10n.profileStudyCardsPerSessionLabel,
                                                style: textTheme.bodyLarge,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                horizontal: AppSizes.spacingSm,
                                                vertical: AppSizes.spacingXs,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppSizes.radiusMd,
                                                    ),
                                              ),
                                              child: Text(
                                                l10n.profileStudyCardsPerSessionOption(
                                                  draft.studyCardsPerSession,
                                                ),
                                                style: textTheme.labelLarge
                                                    ?.copyWith(
                                                  color: colorScheme.onPrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSizes.spacingSm),
                                        Slider(
                                          value: draft.studyCardsPerSession
                                              .toDouble(),
                                          min: _studyCardsPerSessionOptions
                                              .first
                                              .toDouble(),
                                          max: _studyCardsPerSessionOptions
                                              .last
                                              .toDouble(),
                                          divisions:
                                              _studyCardsPerSessionOptions
                                                      .length -
                                                  1,
                                          onChanged: (value) {
                                            final int roundedValue =
                                                value.round();
                                            if (_studyCardsPerSessionOptions
                                                .contains(roundedValue)) {
                                              _settingsDraftNotifier.value =
                                                  draft.copyWith(
                                                studyCardsPerSession:
                                                    roundedValue,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSizes.spacingMd,
                                      0,
                                      AppSizes.spacingMd,
                                      AppSizes.spacingMd,
                                    ),
                                    child: PrimaryButton(
                                      label: l10n.profileSaveSettingsLabel,
                                      onPressed: isSettingsChanged
                                          ? () => _submitSettingsUpdate(
                                              controller: controller,
                                              themeModeController:
                                                  themeModeController,
                                              draft: draft,
                                            )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSizes.spacingLg),
                      ],
                    ),
                  ),
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

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: AppSizes.size24,
          color: colorScheme.primary,
        ),
        const SizedBox(width: AppSizes.spacingSm),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingSm,
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.spacingXs),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              icon,
              size: AppSizes.size24,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.size2),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
