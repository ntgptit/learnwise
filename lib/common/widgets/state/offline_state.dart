import 'package:flutter/material.dart';

import 'error_state.dart';

class OfflineState extends StatelessWidget {
  const OfflineState({
    super.key,
    required this.title,
    required this.message,
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
