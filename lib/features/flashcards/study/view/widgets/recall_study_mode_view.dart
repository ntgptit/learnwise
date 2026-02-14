import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../model/study_answer.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';

class RecallStudyModeView extends StatelessWidget {
  const RecallStudyModeView({
    required this.unit,
    required this.controller,
    required this.l10n,
    super.key,
  });

  final RecallUnit unit;
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
        Text(
          unit.answer,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  controller.submitAnswer(
                    const RecallStudyAnswer(isRemembered: false),
                  );
                  controller.next();
                },
                child: Text(l10n.flashcardsStudyRecallMissedLabel),
              ),
            ),
            const SizedBox(width: FlashcardStudySessionTokens.bottomActionGap),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  controller.submitAnswer(
                    const RecallStudyAnswer(isRemembered: true),
                  );
                  controller.next();
                },
                child: Text(l10n.flashcardsStudyRecallRememberedLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
