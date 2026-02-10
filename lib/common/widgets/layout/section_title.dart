import 'package:flutter/material.dart';

import '../../styles/app_opacities.dart';
import '../../styles/app_sizes.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: AppSizes.spacingXs),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppOpacities.muted70,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: AppSizes.spacingSm),
          trailing!,
        ],
      ],
    );
  }
}
