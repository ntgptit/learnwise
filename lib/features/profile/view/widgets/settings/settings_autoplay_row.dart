import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_sizes.dart';
import '../../../../../common/widgets/widgets.dart';
import 'settings_common_widgets.dart';

class AutoPlaySettingRow extends StatelessWidget {
  const AutoPlaySettingRow({
    required this.l10n,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final AppLocalizations l10n;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return LwSpacedRow(
      spacing: AppSizes.spacingSm,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: SettingTitleRow(
            icon: Icons.volume_up_rounded,
            title: l10n.profileStudyAutoPlayAudioLabel,
            containerColor: colorScheme.tertiaryContainer,
            iconColor: colorScheme.onTertiaryContainer,
          ),
        ),
        Theme(
          data: Theme.of(
            context,
          ).copyWith(switchTheme: _buildSwitchTheme(colorScheme)),
          child: Switch.adaptive(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: enabled,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  SwitchThemeData _buildSwitchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
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
    );
  }
}
