import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title, required this.content, required this.actions, super.key,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Text(title),
      content: content,
      actions: actions,
    );
  }
}
