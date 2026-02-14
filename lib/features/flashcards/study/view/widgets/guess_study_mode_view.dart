import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../model/study_answer.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';

class GuessStudyModeView extends StatelessWidget {
  const GuessStudyModeView({
    required this.unit,
    required this.controller,
    required this.l10n,
    super.key,
  });

  final GuessUnit unit;
  final StudySessionController controller;
  final AppLocalizations l10n;

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
                controller.submitAnswer(GuessStudyAnswer(optionId: option.id));
                controller.next();
              },
              child: Text(option.label),
            ),
          );
        }),
      ],
    );
  }
}
