import 'package:flutter/material.dart';

class LwFloatingNavButton extends StatelessWidget {
  const LwFloatingNavButton({
    required this.icon,
    super.key,
    this.label,
    this.onPressed,
  });

  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final String tooltip = label ?? 'Navigation';
    if (label == null) {
      return FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        child: Icon(icon),
      );
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      label: Text(label!),
    );
  }
}
