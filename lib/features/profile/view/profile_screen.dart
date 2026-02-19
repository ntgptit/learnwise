import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme_mode_controller.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/string_utils.dart';
import '../model/profile_constants.dart';
import '../model/profile_models.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'widgets/personal_info_section.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _usernameController;
  late final ValueNotifier<ProfileSettingsDraft> _settingsDraftNotifier;
  int? _boundUserId;
  String? _boundSettingsSignature;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _usernameController = TextEditingController();
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
    _displayNameController.dispose();
    _usernameController.dispose();
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
      body: _buildBody(
        l10n: l10n,
        state: state,
        controller: controller,
        themeModeController: themeModeController,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(l10n: l10n),
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
        data: (profile) {
          return _buildProfileData(
            profile: profile,
            controller: controller,
            themeModeController: themeModeController,
          );
        },
        error: (error, stackTrace) {
          return _buildErrorState(
            error: error,
            l10n: l10n,
            controller: controller,
          );
        },
        loading: () => LoadingState(message: l10n.profileLoadingLabel),
      ),
    );
  }

  Widget _buildProfileData({
    required UserProfile profile,
    required ProfileController controller,
    required AppThemeModeController themeModeController,
  }) {
    _bindDisplayName(profile);
    _bindUsername(profile);
    _bindSettings(profile);

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: ProfileHeader(profile: profile, onSignOut: controller.signOut),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSizes.spacingMd),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              _buildSections(
                profile: profile,
                controller: controller,
                themeModeController: themeModeController,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState({
    required Object error,
    required AppLocalizations l10n,
    required ProfileController controller,
  }) {
    final String message = _resolveErrorMessage(error: error, l10n: l10n);
    return ErrorState(
      title: l10n.profileLoadErrorTitle,
      message: message,
      retryLabel: l10n.profileRetryLabel,
      onRetry: controller.refresh,
    );
  }

  List<Widget> _buildSections({
    required UserProfile profile,
    required ProfileController controller,
    required AppThemeModeController themeModeController,
  }) {
    return <Widget>[
      PersonalInfoSection(
        profile: profile,
        displayNameController: _displayNameController,
        usernameController: _usernameController,
        onSave: () => _submitProfileUpdate(
          controller: controller,
          profile: profile,
        ),
      ),
      const SizedBox(height: AppSizes.spacingLg),
      SettingsSection(
        profile: profile,
        settingsDraftNotifier: _settingsDraftNotifier,
        onSave: (draft) => _submitSettingsUpdate(
          controller: controller,
          themeModeController: themeModeController,
          draft: draft,
        ),
      ),
      const SizedBox(height: AppSizes.spacingLg),
    ];
  }

  Widget _buildBottomNavigationBar({required AppLocalizations l10n}) {
    return AppBottomNavBar(
      destinations: _buildNavDestinations(l10n),
      selectedIndex: ProfileConstants.profileNavIndex,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
    );
  }

  List<AppBottomNavDestination> _buildNavDestinations(AppLocalizations l10n) {
    return <AppBottomNavDestination>[
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
    ];
  }

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == ProfileConstants.dashboardNavIndex) {
      const DashboardRoute().go(context);
      return;
    }
    if (index == ProfileConstants.foldersNavIndex) {
      const FoldersRoute().go(context);
      return;
    }
    if (index == ProfileConstants.profileNavIndex) {
      return;
    }
  }

  Future<void> _submitProfileUpdate({
    required ProfileController controller,
    required UserProfile profile,
  }) async {
    final String? displayName = StringUtils.normalizeNullable(
      _displayNameController.text,
    );
    if (displayName == null) {
      return;
    }
     String? username = StringUtils.normalizeNullable(
      _usernameController.text,
    );
    if (username == null && profile.username != null) {
      username = '';
    }
    await controller.updateProfile(
      displayName: displayName,
      username: username,
    );
  }

  Future<void> _submitSettingsUpdate({
    required ProfileController controller,
    required AppThemeModeController themeModeController,
    required ProfileSettingsDraft draft,
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

  void _bindUsername(UserProfile profile) {
    final String profileUsername = profile.username ?? '';
    if (_boundUserId == profile.userId &&
        _usernameController.text == profileUsername) {
      return;
    }
    _boundUserId = profile.userId;
    _usernameController.value = TextEditingValue(
      text: profileUsername,
      selection: TextSelection.collapsed(offset: profileUsername.length),
    );
  }

  void _bindSettings(UserProfile profile) {
    final String settingsSignature = _toSettingsSignature(profile.settings);
    if (_boundUserId == profile.userId &&
        _boundSettingsSignature == settingsSignature) {
      return;
    }
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
