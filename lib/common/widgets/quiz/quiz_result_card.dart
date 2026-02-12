import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import '../buttons/primary_button.dart';
import '../card/app_card.dart';

class QuizResultCard extends StatelessWidget {
  const QuizResultCard({
    required this.titleText, required this.correctText, required this.scoreText, required this.progressValue, super.key,
    this.onRetry,
    this.retryLabel,
  }) : assert(progressValue >= 0, 'progressValue must be >= 0.'),
       assert(progressValue <= 1, 'progressValue must be <= 1.'),
       assert(
         onRetry == null || retryLabel != null,
         'retryLabel must be provided when onRetry is set.',
       );

  final String titleText;
  final String correctText;
  final String scoreText;
  final double progressValue;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(titleText, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.spacingSm),
          Text(correctText),
          const SizedBox(height: AppSizes.spacingXs),
          LinearProgressIndicator(value: progressValue),
          const SizedBox(height: AppSizes.spacingXs),
          Text(scoreText),
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
    );
  }
}
