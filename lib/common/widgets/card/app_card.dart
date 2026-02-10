import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import '../../styles/app_opacities.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.spacingMd),
    this.margin,
    this.backgroundColor,
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Widget body = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border:
            border ??
            Border.all(
              color: colorScheme.onSurface.withValues(
                alpha: AppOpacities.soft10,
              ),
            ),
      ),
      child: child,
    );

    if (onTap == null) {
      return body;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      onTap: onTap,
      child: body,
    );
  }
}
