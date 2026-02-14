import 'package:flutter/material.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../model/study_unit.dart';

class GuessStudyModeView extends StatelessWidget {
  const GuessStudyModeView({
    required this.unit,
    required this.onOptionSelected,
    super.key,
  });

  final GuessUnit unit;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          unit.prompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
        ...unit.options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: FlashcardStudySessionTokens.answerSpacing,
            ),
            child: FilledButton.tonal(
              onPressed: () {
                onOptionSelected(option.id);
              },
              child: Text(option.label),
            ),
          );
        }),
      ],
    );
  }
}
