import 'package:flutter/material.dart';

import '../../../../common/styles/app_sizes.dart';

class SwipeableListItem extends StatelessWidget {
  const SwipeableListItem({
    required this.dismissKey, required this.child, required this.onDismissed, super.key,
    this.confirmDismiss,
    this.background,
    this.secondaryBackground,
    this.direction = DismissDirection.horizontal,
  });

  final Key dismissKey;
  final Widget child;
  final DismissDirectionCallback onDismissed;
  final ConfirmDismissCallback? confirmDismiss;
  final Widget? background;
  final Widget? secondaryBackground;
  final DismissDirection direction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Widget startBackground =
        background ??
        _DefaultSwipeBackground(
          alignment: Alignment.centerLeft,
          color: colorScheme.tertiaryContainer,
          icon: Icons.edit,
        );
    final Widget endBackground =
        secondaryBackground ??
        _DefaultSwipeBackground(
          alignment: Alignment.centerRight,
          color: colorScheme.errorContainer,
          icon: Icons.delete,
        );

    return Dismissible(
      key: dismissKey,
      direction: direction,
      confirmDismiss: confirmDismiss,
      onDismissed: onDismissed,
      background: startBackground,
      secondaryBackground: endBackground,
      child: child,
    );
  }
}

class _DefaultSwipeBackground extends StatelessWidget {
  const _DefaultSwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMd),
      child: Icon(icon),
    );
  }
}
