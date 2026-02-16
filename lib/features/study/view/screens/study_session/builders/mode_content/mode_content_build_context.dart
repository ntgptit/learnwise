import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../model/study_unit.dart';
import '../../../../../viewmodel/study_session_viewmodel.dart';

class ModeContentBuildContext {
  const ModeContentBuildContext({
    required this.currentUnit,
    required this.state,
    required this.controller,
    required this.l10n,
    required this.fillController,
  });

  final StudyUnit currentUnit;
  final StudySessionState state;
  final StudySessionController controller;
  final AppLocalizations l10n;
  final TextEditingController fillController;
}
