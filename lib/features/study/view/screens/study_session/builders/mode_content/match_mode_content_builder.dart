import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../model/study_answer.dart';
import '../../../../../model/study_mode.dart';
import '../../../../../model/study_unit.dart';
import 'base_study_mode_content_builder.dart';
import '../../../../widgets/match_study_mode_view.dart';

class MatchModeContentBuilder extends BaseStudyModeContentBuilder {
  const MatchModeContentBuilder();

  @override
  StudyMode get mode {
    return StudyMode.match;
  }

  @override
  String resolveModeLabel(AppLocalizations l10n) {
    return l10n.flashcardsStudyModeMatch;
  }

  @override
  IconData resolveModeIcon() {
    return Icons.join_inner_rounded;
  }

  @override
  Widget buildContent(ModeContentBuildContext context) {
    final StudyUnit currentUnit = context.currentUnit;
    if (currentUnit is! MatchUnit) {
      return const SizedBox.shrink();
    }
    return MatchStudyModeView(
      unit: currentUnit,
      state: context.state,
      onLeftPressed: (leftId) {
        context.controller.submitAnswer(
          MatchSelectLeftStudyAnswer(leftId: leftId),
        );
      },
      onRightPressed: (rightId) {
        context.controller.submitAnswer(
          MatchSelectRightStudyAnswer(rightId: rightId),
        );
      },
      l10n: context.l10n,
    );
  }
}
