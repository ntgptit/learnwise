import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({
    required this.progressValue, required this.progressText, super.key,
    this.height = _QuizProgressBarConstants.defaultHeight,
  }) : assert(progressValue >= 0, 'progressValue must be >= 0.'),
       assert(progressValue <= 1, 'progressValue must be <= 1.'),
       assert(height > 0, 'height must be greater than 0.');

  final double progressValue;
  final String progressText;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LinearProgressIndicator(value: progressValue, minHeight: height),
        const SizedBox(height: AppSizes.spacingXs),
        Text(progressText),
      ],
    );
  }
}

class _QuizProgressBarConstants {
  const _QuizProgressBarConstants._();

  static const double defaultHeight = 10;
}
