import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import 'app_dialog.dart';

class FlashcardEditDialog extends StatelessWidget {
  const FlashcardEditDialog({
    super.key,
    required this.frontController,
    required this.backController,
    required this.onConfirm,
    required this.onCancel,
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.frontLabel,
    required this.backLabel,
  });

  final TextEditingController frontController;
  final TextEditingController backController;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String title;
  final String confirmLabel;
  final String cancelLabel;
  final String frontLabel;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: frontController,
            decoration: InputDecoration(labelText: frontLabel),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          TextField(
            controller: backController,
            decoration: InputDecoration(labelText: backLabel),
            maxLines: 3,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: onCancel, child: Text(cancelLabel)),
        FilledButton(onPressed: onConfirm, child: Text(confirmLabel)),
      ],
    );
  }
}
