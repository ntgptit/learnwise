import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../../../common/widgets/widgets.dart';
import '../../model/profile_models.dart';
import 'profile_settings_draft.dart';
import 'settings_section_content.dart';

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

  static const double _horizontalPadding = AppSizes.spacingMd;
  static const double _verticalPadding = AppSizes.spacingMd;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<ProfileSettingsDraft>(
      valueListenable: settingsDraftNotifier,
      builder: (context, draft, _) {
        final bool isChanged = _isSettingsChanged(profile, draft);

        return LwCard(
          variant: AppCardVariant.elevated,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _horizontalPadding,
              vertical: _verticalPadding,
            ),
            child: SettingsSectionContent(
              draft: draft,
              l10n: l10n,
              isChanged: isChanged,
              onDraftChanged: (nextDraft) {
                settingsDraftNotifier.value = nextDraft;
              },
              onSave: onSave,
            ),
          ),
        );
      },
    );
  }

  bool _isSettingsChanged(UserProfile profile, ProfileSettingsDraft draft) {
    return draft.themeMode != profile.settings.themeMode ||
        draft.studyAutoPlayAudio != profile.settings.studyAutoPlayAudio ||
        draft.studyCardsPerSession != profile.settings.studyCardsPerSession;
  }
}
