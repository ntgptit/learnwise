import 'package:flutter/material.dart';

import 'app_dialog.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onAcknowledge,
    required this.buttonLabel,
  });

  final String title;
  final String message;
  final VoidCallback onAcknowledge;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      content: Text(message),
      actions: <Widget>[
        FilledButton(onPressed: onAcknowledge, child: Text(buttonLabel)),
      ],
    );
  }
}
