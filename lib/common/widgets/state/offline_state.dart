import 'package:flutter/material.dart';

import 'error_state.dart';

class OfflineState extends StatelessWidget {
  const OfflineState({
    required this.title, required this.message, super.key,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorState(title: title, message: message, onRetry: onRetry);
  }
}
