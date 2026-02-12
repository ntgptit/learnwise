import 'package:flutter/material.dart';

import '../../styles/app_opacities.dart';
import '../../styles/app_sizes.dart';

class AppMetadataList extends StatelessWidget {
  const AppMetadataList({
    required this.items, super.key,
    this.spacing = AppSizes.spacing2Xs,
    this.color,
  });

  final List<String> items;
  final double spacing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color textColor =
        color ?? colorScheme.onSurface.withValues(alpha: AppOpacities.muted82);
    final TextStyle? baseStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: textColor);

    final List<Widget> children = <Widget>[];
    for (int index = 0; index < items.length; index++) {
      children.add(Text(items[index], style: baseStyle));
      if (index == items.length - 1) {
        continue;
      }
      children.add(SizedBox(height: spacing));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
