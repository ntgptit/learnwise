import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import 'quiz_progress_bar.dart';

class QuizQuestionHeader extends StatelessWidget {
  const QuizQuestionHeader({
    super.key,
    required this.question,
    required this.progressValue,
    required this.progressText,
    this.trailing,
  });

  final String question;
  final double progressValue;
  final String progressText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget trailingWidget = trailing ?? const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            trailingWidget,
          ],
        ),
        const SizedBox(height: AppSizes.spacingSm),
        QuizProgressBar(
          progressValue: progressValue,
          progressText: progressText,
        ),
      ],
    );
  }
}
