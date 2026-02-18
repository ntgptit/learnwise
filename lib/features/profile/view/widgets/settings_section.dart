import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../../../common/widgets/widgets.dart';
import '../../model/profile_models.dart';

// quality-guard: allow-large-class
// Justification: Settings section contains multiple related UI components
// quality-guard: allow-long-function
// Justification: build() keeps section rhythm and card composition in one place.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.profile,
    required this.settingsDraftNotifier,
    required this.onSave,
    super.key,
  });

  final UserProfile profile;
  final ValueNotifier<ProfileSettingsDraft> settingsDraftNotifier;
  final void Function(ProfileSettingsDraft) onSave;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionHeader(
          context: context,
          icon: Icons.tune_rounded,
          title: l10n.profileSettingsTitle,
        ),
        const SizedBox(height: AppSizes.spacingSm),
        ValueListenableBuilder<ProfileSettingsDraft>(
          valueListenable: settingsDraftNotifier,
          builder: (context, draft, _) {
            final bool isChanged = _isSettingsChanged(profile, draft);
            return AppCard(
              variant: AppCardVariant.elevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildThemeModeSection(context, l10n, draft),
                  const SizedBox(height: AppSizes.spacingMd),
                  _buildDivider(context),
                  _buildAutoPlayAudioTile(context, l10n, draft),
                  _buildDivider(context),
                  _buildCardsPerSessionSection(context, l10n, draft),
                  _buildSaveButton(context, l10n, isChanged, draft),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildThemeModeSection(
    BuildContext context,
    AppLocalizations l10n,
    ProfileSettingsDraft draft,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ButtonStyle segmentedStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        if (states.contains(WidgetState.focused)) {
          return colorScheme.primaryContainer;
        }
        return colorScheme.surfaceContainer;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.onPrimary;
        }
        if (states.contains(WidgetState.focused)) {
          return colorScheme.onPrimaryContainer;
        }
        return colorScheme.onSurface;
      }),
      iconColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.onPrimary;
        }
        if (states.contains(WidgetState.focused)) {
          return colorScheme.onPrimaryContainer;
        }
        return colorScheme.onSurface;
      }),
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.selected)) {
          return BorderSide(color: colorScheme.primary);
        }
        if (states.contains(WidgetState.focused)) {
          return BorderSide(color: colorScheme.primaryContainer);
        }
        return BorderSide(color: colorScheme.outlineVariant);
      }),
      textStyle: WidgetStateProperty.all(
        textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMd),
          child: SegmentedButton<UserThemeMode>(
            segments: _buildThemeModeSegments(l10n),
            selected: <UserThemeMode>{draft.themeMode},
            onSelectionChanged: (newSelection) {
              settingsDraftNotifier.value = draft.copyWith(
                themeMode: newSelection.first,
              );
            },
            style: segmentedStyle,
            showSelectedIcon: false,
          ),
        ),
      ],
    );
  }

  List<ButtonSegment<UserThemeMode>> _buildThemeModeSegments(
    AppLocalizations l10n,
  ) {
    return <ButtonSegment<UserThemeMode>>[
      ButtonSegment<UserThemeMode>(
        value: UserThemeMode.system,
        label: Text(l10n.profileThemeSystemOption),
        icon: const Icon(Icons.brightness_auto_rounded),
      ),
      ButtonSegment<UserThemeMode>(
        value: UserThemeMode.light,
        label: Text(l10n.profileThemeLightOption),
        icon: const Icon(Icons.light_mode_rounded),
      ),
      ButtonSegment<UserThemeMode>(
        value: UserThemeMode.dark,
        label: Text(l10n.profileThemeDarkOption),
        icon: const Icon(Icons.dark_mode_rounded),
      ),
    ];
  }

  Widget _buildAutoPlayAudioTile(
    BuildContext context,
    AppLocalizations l10n,
    ProfileSettingsDraft draft,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSizes.spacingSm),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
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
      trailing: Theme(
        data: Theme.of(context).copyWith(
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primary;
              }
              return colorScheme.surface;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primaryContainer;
              }
              return colorScheme.outlineVariant;
            }),
          ),
        ),
        child: Switch.adaptive(
          value: draft.studyAutoPlayAudio,
          onChanged: (value) {
            settingsDraftNotifier.value = draft.copyWith(
              studyAutoPlayAudio: value,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardsPerSessionSection(
    BuildContext context,
    AppLocalizations l10n,
    ProfileSettingsDraft draft,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCardsPerSessionHeader(context, l10n, draft),
          const SizedBox(height: AppSizes.spacingSm),
          _buildCardsPerSessionSlider(context, l10n, draft),
        ],
      ),
    );
  }

  Widget _buildCardsPerSessionHeader(
    BuildContext context,
    AppLocalizations l10n,
    ProfileSettingsDraft draft,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.spacingSm),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(
            Icons.collections_bookmark_rounded,
            size: AppSizes.size24,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSm),
        Expanded(
          child: Text(
            l10n.profileStudyCardsPerSessionLabel,
            style: textTheme.bodyLarge,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingSm,
            vertical: AppSizes.spacingXs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Text(
            l10n.profileStudyCardsPerSessionOption(draft.studyCardsPerSession),
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardsPerSessionSlider(
    BuildContext context,
    AppLocalizations l10n,
    ProfileSettingsDraft draft,
  ) {
    final int normalizedCardsPerSession =
        UserStudySettings.normalizeStudyCardsPerSession(
          draft.studyCardsPerSession,
        );
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbColor: colorScheme.primary,
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primaryContainer,
      ),
      child: Slider(
        value: normalizedCardsPerSession.toDouble(),
        min: UserStudySettings.minStudyCardsPerSession.toDouble(),
        max: UserStudySettings.maxStudyCardsPerSession.toDouble(),
        divisions:
            UserStudySettings.maxStudyCardsPerSession -
            UserStudySettings.minStudyCardsPerSession,
        label: l10n.profileStudyCardsPerSessionOption(
          normalizedCardsPerSession,
        ),
        onChanged: (value) {
          final int nextCardsPerSession =
              UserStudySettings.normalizeStudyCardsPerSession(value.round());
          settingsDraftNotifier.value = draft.copyWith(
            studyCardsPerSession: nextCardsPerSession,
          );
        },
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isChanged,
    ProfileSettingsDraft draft,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingMd,
        0,
        AppSizes.spacingMd,
        AppSizes.spacingMd,
      ),
      child: PrimaryButton(
        label: l10n.profileSaveSettingsLabel,
        onPressed: isChanged ? () => onSave(draft) : null,
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Divider(height: AppSizes.size1, color: colorScheme.outlineVariant);
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
        Icon(icon, size: AppSizes.size24, color: colorScheme.primary),
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

  bool _isSettingsChanged(UserProfile profile, ProfileSettingsDraft draft) {
    return draft.themeMode != profile.settings.themeMode ||
        draft.studyAutoPlayAudio != profile.settings.studyAutoPlayAudio ||
        draft.studyCardsPerSession != profile.settings.studyCardsPerSession;
  }
}

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
    final int nextStudyCardsPerSession =
        UserStudySettings.normalizeStudyCardsPerSession(
          studyCardsPerSession ?? this.studyCardsPerSession,
        );
    return ProfileSettingsDraft(
      themeMode: themeMode ?? this.themeMode,
      studyAutoPlayAudio: studyAutoPlayAudio ?? this.studyAutoPlayAudio,
      studyCardsPerSession: nextStudyCardsPerSession,
    );
  }
}
