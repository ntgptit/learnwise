import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../model/study_mode.dart';
import '../../../../../model/study_unit.dart';
import 'base_study_mode_content_builder.dart';
import '../../../../widgets/recall_study_mode_view.dart';

class RecallModeContentBuilder extends BaseStudyModeContentBuilder {
  const RecallModeContentBuilder();

  @override
  StudyMode get mode {
    return StudyMode.recall;
  }

  @override
  String resolveModeLabel(AppLocalizations l10n) {
    return l10n.flashcardsStudyModeRecall;
  }

  @override
  IconData resolveModeIcon() {
    return Icons.psychology_alt_outlined;
  }

  @override
  Widget buildContent(ModeContentBuildContext context) {
    final StudyUnit currentUnit = context.currentUnit;
    if (currentUnit is! RecallUnit) {
      return const SizedBox.shrink();
    }
    return RecallStudyModeView(
      key: ValueKey<int>(context.state.currentIndex),
      unit: currentUnit,
      onMissedPressed: () {
        context.controller.submitRecallEvaluation(isRemembered: false);
      },
      onRememberedPressed: () {
        context.controller.submitRecallEvaluation(isRemembered: true);
      },
      l10n: context.l10n,
    );
  }
}
