import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../viewmodel/study_session_viewmodel.dart';

class ModeAppBarActionBuildContext {
  const ModeAppBarActionBuildContext({
    required this.context,
    required this.l10n,
    required this.provider,
    required this.showToast,
  });

  final BuildContext context;
  final AppLocalizations l10n;
  final StudySessionControllerProvider provider;
  final ValueChanged<String> showToast;
}
