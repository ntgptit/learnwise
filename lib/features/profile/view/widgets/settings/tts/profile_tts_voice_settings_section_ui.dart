part of 'profile_tts_voice_settings_section.dart';

class _VoiceTestSection extends StatelessWidget {
  const _VoiceTestSection({
    required this.l10n,
    required this.useDefaultTestTextNotifier,
    required this.customTestTextErrorNotifier,
    required this.testTextController,
    required this.defaultTestText,
    required this.isInputDisabled,
  });

  final AppLocalizations l10n;
  final ValueNotifier<bool> useDefaultTestTextNotifier;
  final ValueNotifier<String?> customTestTextErrorNotifier;
  final TextEditingController testTextController;
  final String defaultTestText;
  final bool isInputDisabled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: useDefaultTestTextNotifier,
      builder: (context, useDefaultText, _) {
        final bool canEditInput = !useDefaultText && !isInputDisabled;
        final String toggleLabel = useDefaultText
            ? l10n.profileVoiceTestUseDefaultLabel
            : l10n.profileVoiceTestUseCustomLabel;
        final IconData toggleIcon = useDefaultText
            ? Icons.auto_awesome_rounded
            : Icons.edit_note_rounded;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _VoiceSettingLabel(
                    title: l10n.profileVoiceTestModeLabel,
                  ),
                ),
                SizedBox(
                  width: _VoiceTestSectionConstants.toggleButtonWidth,
                  child: OutlinedButton.icon(
                    onPressed: isInputDisabled
                        ? null
                        : () {
                            customTestTextErrorNotifier.value = null;
                            useDefaultTestTextNotifier.value = !useDefaultText;
                          },
                    icon: Icon(toggleIcon),
                    label: Text(toggleLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _VoiceSettingsLayoutConstants.itemGap),
            ValueListenableBuilder<String?>(
              valueListenable: customTestTextErrorNotifier,
              builder: (context, customTextError, _) {
                return LwTextArea(
                  key: ValueKey<String>(
                    'voice-test-panel-$useDefaultText-$defaultTestText',
                  ),
                  controller: useDefaultText ? null : testTextController,
                  initialValue: useDefaultText ? defaultTestText : null,
                  enabled: useDefaultText ? true : canEditInput,
                  readOnly: useDefaultText,
                  maxLines: _VoiceTestSectionConstants.textPanelMaxLines,
                  minLines: _VoiceTestSectionConstants.textPanelMinLines,
                  labelText: useDefaultText
                      ? l10n.profileVoiceTestUseDefaultLabel
                      : l10n.profileVoiceTestInputLabel,
                  hintText: useDefaultText ? null : l10n.profileVoiceTestHint,
                  errorText: useDefaultText ? null : customTextError,
                  onChanged: useDefaultText
                      ? null
                      : (_) {
                          if (customTextError == null) {
                            return;
                          }
                          customTestTextErrorNotifier.value = null;
                        },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _VoiceSettingsActionRow extends StatelessWidget {
  const _VoiceSettingsActionRow({
    required this.testVoiceLabel,
    required this.saveLabel,
    required this.canTestVoice,
    required this.canSaveSettings,
    required this.onTestVoicePressed,
    required this.onSavePressed,
  });

  final String testVoiceLabel;
  final String saveLabel;
  final bool canTestVoice;
  final bool canSaveSettings;
  final VoidCallback onTestVoicePressed;
  final VoidCallback onSavePressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _VoiceActionButton(
              label: testVoiceLabel,
              enabled: canTestVoice,
              onPressed: onTestVoicePressed,
              tonal: true,
            ),
            const SizedBox(
              width: _VoiceSettingsLayoutConstants.actionButtonGap,
            ),
            _VoiceActionButton(
              label: saveLabel,
              enabled: canSaveSettings,
              onPressed: onSavePressed,
              tonal: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceActionButton extends StatelessWidget {
  const _VoiceActionButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    required this.tonal,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ButtonStyle style = FilledButton.styleFrom(
      minimumSize: const Size(0, AppSizes.size48),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingLg),
      textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
    if (tonal) {
      return FilledButton.tonal(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: Text(label),
      );
    }
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: style,
      child: Text(label),
    );
  }
}

class _VoiceTestSectionConstants {
  const _VoiceTestSectionConstants._();

  static const int textPanelMinLines = 4;
  static const int textPanelMaxLines = 5;
  static const double toggleButtonWidth = AppSizes.size144 + AppSizes.size32;
}

class _VoiceSettingsLayoutConstants {
  const _VoiceSettingsLayoutConstants._();

  static const double cardPadding = AppSizes.spacingMd;
  static const double subsectionGap = AppSizes.spacingXs;
  static const double itemGap = AppSizes.spacingSm;
  static const double groupItemGap = AppSizes.spacingMd;
  static const double actionRowTopGap = AppSizes.spacingMd;
  static const double actionButtonGap = AppSizes.spacingSm;
}

class _VoiceSettingLabel extends StatelessWidget {
  const _VoiceSettingLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _VoiceSettingHeader extends StatelessWidget {
  const _VoiceSettingHeader({
    required this.icon,
    required this.title,
    required this.containerColor,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final Color containerColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SettingTitleRow(
      icon: icon,
      title: title,
      containerColor: containerColor,
      iconColor: iconColor,
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({
    required this.title,
    required this.icon,
    required this.onRefresh,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: _VoiceSettingHeader(
            icon: icon,
            title: title,
            containerColor: colorScheme.primaryContainer,
            iconColor: colorScheme.onPrimaryContainer,
          ),
        ),
        LwIconButton(
          onPressed: onRefresh,
          tooltip: AppLocalizations.of(context)!.loadKoreanVoices,
          icon: Icons.refresh_rounded,
        ),
      ],
    );
  }
}

class _TtsSliderRow extends StatelessWidget {
  const _TtsSliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final String valueText = value.toStringAsFixed(2);
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _VoiceSettingLabel(title: label)),
            const SizedBox(width: _VoiceSettingsLayoutConstants.subsectionGap),
            Text(
              valueText,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: _VoiceSettingsLayoutConstants.subsectionGap),
        LwSliderInput(
          value: value.clamp(min, max),
          min: min,
          max: max,
          label: null,
          displayValueText: valueText,
          divisions: TtsConstants.sliderDivisions,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}
