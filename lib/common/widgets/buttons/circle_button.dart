import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({
    required this.icon, super.key,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size = AppSizes.size48,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor ?? colorScheme.primary,
          foregroundColor: foregroundColor ?? colorScheme.onPrimary,
        ),
        child: Icon(icon),
      ),
    );
  }
}
