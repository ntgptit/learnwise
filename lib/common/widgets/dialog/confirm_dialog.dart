import 'package:flutter/material.dart';

import 'app_dialog.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title, required this.message, required this.onConfirm, required this.onCancel, required this.confirmLabel, required this.cancelLabel, super.key,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      content: Text(message),
      actions: <Widget>[
        TextButton(onPressed: onCancel, child: Text(cancelLabel)),
        FilledButton(onPressed: onConfirm, child: Text(confirmLabel)),
      ],
    );
  }
}
