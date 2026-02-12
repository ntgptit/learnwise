import 'package:flutter/material.dart';

import '../../styles/icons.dart';
import '../../styles/app_sizes.dart';
import '../buttons/primary_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title, super.key,
    this.message,
    this.retryLabel,
    this.onRetry,
  }) : assert(
         onRetry == null || retryLabel != null,
         'retryLabel must be provided when onRetry is set.',
       );

  final String title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(AppIcons.refresh, size: AppSizes.spacingLg),
            const SizedBox(height: AppSizes.spacingSm),
            Text(title, textAlign: TextAlign.center),
            if (message != null) ...<Widget>[
              const SizedBox(height: AppSizes.spacingXs),
              Text(message!, textAlign: TextAlign.center),
            ],
            if (onRetry != null && retryLabel != null) ...<Widget>[
              const SizedBox(height: AppSizes.spacingMd),
              PrimaryButton(
                label: retryLabel!,
                expanded: false,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
