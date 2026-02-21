import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_sizes.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../model/profile_models.dart';
import 'profile_settings_draft.dart';
import 'settings_autoplay_row.dart';
import 'settings_cards_per_session_section.dart';
import 'settings_common_widgets.dart';
import 'settings_theme_row.dart';

class SettingsSectionContent extends StatelessWidget {
  const SettingsSectionContent({
    required this.draft,
    required this.l10n,
    required this.isChanged,
    required this.onDraftChanged,
    required this.onSave,
    super.key,
  });

  final ProfileSettingsDraft draft;
  final AppLocalizations l10n;
  final bool isChanged;
  final ValueChanged<ProfileSettingsDraft> onDraftChanged;
  final void Function(ProfileSettingsDraft) onSave;

  @override
  Widget build(BuildContext context) {
    return LwSpacedColumn(
      spacing: AppSizes.size1,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ThemeSettingRow(
          l10n: l10n,
          selectedThemeMode: draft.themeMode,
          onChanged: _onThemeChanged,
        ),
        const SettingsGroupDivider(),
        AutoPlaySettingRow(
          l10n: l10n,
          enabled: draft.studyAutoPlayAudio,
          onChanged: _onAutoPlayChanged,
        ),
        const SettingsGroupDivider(),
        CardsPerSessionSection(
          l10n: l10n,
          cardsPerSession: draft.studyCardsPerSession,
          onChanged: _onCardsPerSessionChanged,
        ),
        const SettingsGroupGap(),
        SaveButtonRow(
          label: l10n.profileSaveSettingsLabel,
          enabled: isChanged,
          onPressed: _onSavePressed,
        ),
      ],
    );
  }

  void _onThemeChanged(UserThemeMode mode) {
    onDraftChanged(draft.copyWith(themeMode: mode));
  }

  void _onAutoPlayChanged(bool enabled) {
    onDraftChanged(draft.copyWith(studyAutoPlayAudio: enabled));
  }

  void _onCardsPerSessionChanged(int value) {
    onDraftChanged(draft.copyWith(studyCardsPerSession: value));
  }

  void _onSavePressed() {
    onSave(draft);
  }
}
