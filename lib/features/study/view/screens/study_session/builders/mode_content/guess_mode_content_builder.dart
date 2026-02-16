import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../model/study_mode.dart';
import '../../../../../model/study_unit.dart';
import 'base_study_mode_content_builder.dart';
import '../../../../widgets/guess_study_mode_view.dart';

class GuessModeContentBuilder extends BaseStudyModeContentBuilder {
  const GuessModeContentBuilder();

  @override
  StudyMode get mode {
    return StudyMode.guess;
  }

  @override
  String resolveModeLabel(AppLocalizations l10n) {
    return l10n.flashcardsStudyModeGuess;
  }

  @override
  IconData resolveModeIcon() {
    return Icons.help_outline_rounded;
  }

  @override
  Widget buildContent(ModeContentBuildContext context) {
    final StudyUnit currentUnit = context.currentUnit;
    if (currentUnit is! GuessUnit) {
      return const SizedBox.shrink();
    }
    return GuessStudyModeView(
      unit: currentUnit,
      feedbackState: context.state.guessInteractionFeedback,
      onOptionSelected: context.controller.submitGuessOption,
    );
  }
}
