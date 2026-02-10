import 'package:flutter/material.dart';

class FloatingNavButton extends StatelessWidget {
  const FloatingNavButton({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
  });

  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return FloatingActionButton(onPressed: onPressed, child: Icon(icon));
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label!),
    );
  }
}
