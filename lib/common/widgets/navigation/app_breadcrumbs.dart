import 'package:flutter/material.dart';

import '../../styles/app_opacities.dart';
import '../../styles/app_sizes.dart';

class AppBreadcrumbItem {
  const AppBreadcrumbItem({required this.label});

  final String label;
}

class AppBreadcrumbs extends StatelessWidget {
  const AppBreadcrumbs({
    required this.rootLabel, required this.items, required this.onRootPressed, required this.onItemPressed, super.key,
  });

  final String rootLabel;
  final List<AppBreadcrumbItem> items;
  final VoidCallback onRootPressed;
  final ValueChanged<int> onItemPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<Widget> children = _buildTrailChildren();

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: AppOpacities.outline26),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  List<Widget> _buildTrailChildren() {
    final List<Widget> children = <Widget>[
      ActionChip(label: Text(rootLabel), onPressed: onRootPressed),
    ];

    for (int index = 0; index < items.length; index++) {
      final AppBreadcrumbItem item = items[index];
      children.add(const SizedBox(width: AppSizes.spacingXs));
      children.add(
        const Icon(Icons.chevron_right_rounded, size: AppSizes.spacingLg),
      );
      children.add(const SizedBox(width: AppSizes.spacingXs));
      children.add(
        ActionChip(
          label: Text(item.label),
          onPressed: () => onItemPressed(index),
        ),
      );
    }

    return children;
  }
}
