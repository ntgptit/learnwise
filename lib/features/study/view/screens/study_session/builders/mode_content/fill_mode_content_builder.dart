import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import 'package:learnwise/common/styles/app_screen_tokens.dart';
import '../../../../../model/study_mode.dart';
import '../../../../../model/study_unit.dart';
import 'base_study_mode_content_builder.dart';
import '../../../../widgets/fill_study_mode_view.dart';

class FillModeContentBuilder extends BaseStudyModeContentBuilder {
  const FillModeContentBuilder();

  @override
  StudyMode get mode {
    return StudyMode.fill;
  }

  @override
  String resolveModeLabel(AppLocalizations l10n) {
    return l10n.flashcardsStudyModeFill;
  }

  @override
  IconData resolveModeIcon() {
    return Icons.edit_note_rounded;
  }

  @override
  double resolveHeaderToContentGap() {
    return FlashcardStudySessionTokens.fillHeaderToContentGap;
  }

  @override
  double resolveProgressToModeGap() {
    return FlashcardStudySessionTokens.fillProgressToModeGap;
  }

  @override
  Widget buildContent(ModeContentBuildContext context) {
    final StudyUnit currentUnit = context.currentUnit;
    if (currentUnit is! FillUnit) {
      return const SizedBox.shrink();
    }
    return FillStudyModeView(
      unit: currentUnit,
      onSubmitAnswer: context.controller.submitFillAnswer,
      l10n: context.l10n,
      fillController: context.fillController,
    );
  }
}
