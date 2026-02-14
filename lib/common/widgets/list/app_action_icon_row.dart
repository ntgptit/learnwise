import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';
import '../../styles/app_sizes.dart';

class AppActionIconItem {
  const AppActionIconItem({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
    this.activeIcon,
    this.activeColor,
    this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? activeIcon;
  final Color? activeColor;
  final bool isActive;
}

class AppActionIconRow extends StatelessWidget {
  const AppActionIconRow({
    required this.items,
    super.key,
    this.spacing = AppSizes.spacingSm,
    this.iconSize = AppSizes.size24,
    this.tapTargetSize = AppSizes.size40,
  });

  final List<AppActionIconItem> items;
  final double spacing;
  final double iconSize;
  final double tapTargetSize;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> children = <Widget>[];
    for (int index = 0; index < items.length; index++) {
      final AppActionIconItem item = items[index];
      final IconData resolvedIcon = item.isActive && item.activeIcon != null
          ? item.activeIcon!
          : item.icon;
      final Color? resolvedColor = item.isActive && item.activeColor != null
          ? item.activeColor
          : item.color;
      children.add(
        IconButton(
          onPressed: item.onPressed,
          iconSize: iconSize,
          constraints: BoxConstraints(
            minWidth: tapTargetSize,
            minHeight: tapTargetSize,
          ),
          splashRadius: tapTargetSize / 2,
          icon: AnimatedSwitcher(
            duration: AppDurations.animationQuick,
            child: Icon(
              resolvedIcon,
              key: ValueKey<String>(
                '${resolvedIcon.codePoint}-${item.isActive}',
              ),
              color: resolvedColor,
            ),
          ),
          tooltip: item.tooltip,
        ),
      );
      if (index == items.length - 1) {
        continue;
      }
      children.add(SizedBox(width: spacing));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
