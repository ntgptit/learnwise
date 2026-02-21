import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_sizes.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../model/profile_models.dart';
import 'settings_common_widgets.dart';

const List<ButtonSegment<UserThemeMode>> _themeSegments =
    <ButtonSegment<UserThemeMode>>[
      ButtonSegment<UserThemeMode>(
        value: UserThemeMode.system,
        icon: Tooltip(
          message: 'Follow system theme',
          child: Icon(Icons.brightness_auto_rounded),
        ),
      ),
      ButtonSegment<UserThemeMode>(
        value: UserThemeMode.light,
        icon: Tooltip(
          message: 'Light theme',
          child: Icon(Icons.light_mode_rounded),
        ),
      ),
      ButtonSegment<UserThemeMode>(
        value: UserThemeMode.dark,
        icon: Tooltip(
          message: 'Dark theme',
          child: Icon(Icons.dark_mode_rounded),
        ),
      ),
    ];

class ThemeSettingRow extends StatelessWidget {
  const ThemeSettingRow({
    required this.l10n,
    required this.selectedThemeMode,
    required this.onChanged,
    super.key,
  });

  final AppLocalizations l10n;
  final UserThemeMode selectedThemeMode;
  final ValueChanged<UserThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return LwSpacedRow(
      spacing: AppSizes.spacingSm,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: SettingTitleRow(
            icon: Icons.palette_outlined,
            title: l10n.profileThemeLabel,
            containerColor: colorScheme.primaryContainer,
            iconColor: colorScheme.onPrimaryContainer,
          ),
        ),
        ThemeModeSegmentedControl(
          selectedThemeMode: selectedThemeMode,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class ThemeModeSegmentedControl extends StatelessWidget {
  const ThemeModeSegmentedControl({
    required this.selectedThemeMode,
    required this.onChanged,
    super.key,
  });

  final UserThemeMode selectedThemeMode;
  final ValueChanged<UserThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UserThemeMode>(
      segments: _themeSegments,
      selected: <UserThemeMode>{selectedThemeMode},
      onSelectionChanged: (newSelection) => onChanged(newSelection.first),
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
