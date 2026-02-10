import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading)
          const SizedBox(
            width: AppSizes.spacingMd,
            height: AppSizes.spacingMd,
            child: CircularProgressIndicator(strokeWidth: AppSizes.size2),
          ),
        if (!isLoading && leading != null) leading!,
        if (isLoading || leading != null)
          const SizedBox(width: AppSizes.spacingXs),
        Text(label),
      ],
    );

    final Widget button = FilledButton(
      onPressed: disabled ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.size48),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      child: content,
    );

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
