import 'package:flutter/material.dart';

import '../buttons/primary_button.dart';
import 'empty_state.dart';

class UnauthorizedState extends StatelessWidget {
  const UnauthorizedState({
    required this.title, required this.message, required this.actionLabel, super.key,
    this.onSignIn,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: title,
      subtitle: message,
      icon: Icons.lock_outline,
      action: PrimaryButton(
        label: actionLabel,
        expanded: false,
        onPressed: onSignIn,
      ),
    );
  }
}
