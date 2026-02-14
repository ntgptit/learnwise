import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../model/study_answer.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';

class FillStudyModeView extends StatelessWidget {
  const FillStudyModeView({
    required this.unit,
    required this.controller,
    required this.l10n,
    required this.fillController,
    super.key,
  });

  final FillUnit unit;
  final StudySessionController controller;
  final AppLocalizations l10n;
  final TextEditingController fillController;

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
        AppTextField(
          controller: fillController,
          label: l10n.flashcardsStudyFillInputLabel,
          hint: l10n.flashcardsStudyFillInputHint,
        ),
        const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
        FilledButton(
          onPressed: () {
            final String normalizedAnswer = fillController.text.normalized;
            if (normalizedAnswer.isEmpty) {
              return;
            }
            controller.submitAnswer(FillStudyAnswer(text: normalizedAnswer));
            controller.next();
            fillController.clear();
          },
          child: Text(l10n.flashcardsStudySubmitLabel),
        ),
      ],
    );
  }
}
