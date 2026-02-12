import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({required this.label, super.key, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}
