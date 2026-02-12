import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label, super.key,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.size10,
        vertical: AppSizes.spacing2Xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor ?? colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
