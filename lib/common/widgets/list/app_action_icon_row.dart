import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class AppActionIconItem {
  const AppActionIconItem({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
}

class AppActionIconRow extends StatelessWidget {
  const AppActionIconRow({
    super.key,
    required this.items,
    this.spacing = AppSizes.spacing2Xs,
  });

  final List<AppActionIconItem> items;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> children = <Widget>[];
    for (int index = 0; index < items.length; index++) {
      final AppActionIconItem item = items[index];
      children.add(
        IconButton(
          onPressed: item.onPressed,
          icon: Icon(item.icon),
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
