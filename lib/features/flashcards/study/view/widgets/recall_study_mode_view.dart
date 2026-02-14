import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../model/study_unit.dart';

class RecallStudyModeView extends StatelessWidget {
  const RecallStudyModeView({
    required this.unit,
    required this.onMissedPressed,
    required this.onRememberedPressed,
    required this.l10n,
    super.key,
  });

  final RecallUnit unit;
  final VoidCallback onMissedPressed;
  final VoidCallback onRememberedPressed;
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
                onPressed: onMissedPressed,
                child: Text(l10n.flashcardsStudyRecallMissedLabel),
              ),
            ),
            const SizedBox(width: FlashcardStudySessionTokens.bottomActionGap),
            Expanded(
              child: FilledButton(
                onPressed: onRememberedPressed,
                child: Text(l10n.flashcardsStudyRecallRememberedLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
