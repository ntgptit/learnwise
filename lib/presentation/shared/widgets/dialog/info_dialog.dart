import 'package:flutter/material.dart';

import 'app_dialog.dart';

class LwInfoDialog extends StatelessWidget {
  const LwInfoDialog({
    required this.title,
    required this.message,
    required this.onAcknowledge,
    required this.buttonLabel,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback onAcknowledge;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return LwDialog(
      title: title,
      content: Text(message),
      actions: <Widget>[
        FilledButton(onPressed: onAcknowledge, child: Text(buttonLabel)),
      ],
    );
  }
}
