import 'package:flutter/material.dart';

import '../../../../common/styles/app_sizes.dart';

class SettingsGroupGap extends StatelessWidget {
  const SettingsGroupGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: AppSizes.spacingLg);
  }
}

class SettingsGroupDivider extends StatelessWidget {
  const SettingsGroupDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: AppSizes.spacingLg),
        _DividerLine(),
        SizedBox(height: AppSizes.spacingLg),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Divider(
      height: AppSizes.size1,
      thickness: AppSizes.size1,
      color: colorScheme.outlineVariant,
    );
  }
}

class SaveButtonRow extends StatelessWidget {
  const SaveButtonRow({
    required this.label,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: SizedBox(
        height: AppSizes.size48,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingLg),
            textStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class SettingTitleRow extends StatelessWidget {
  const SettingTitleRow({
    required this.icon,
    required this.title,
    required this.containerColor,
    required this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final Color containerColor;
  final Color iconColor;

  static const double _iconBoxSize = AppSizes.size40;
  static const double _iconToTextSpacing = AppSizes.spacingMd;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: _iconBoxSize,
          height: _iconBoxSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(icon, size: AppSizes.size24, color: iconColor),
        ),
        const SizedBox(width: _iconToTextSpacing),
        Expanded(
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
