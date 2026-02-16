import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../model/study_mode.dart';
import 'mode_app_bar_action_build_context.dart';
import 'mode_content_build_context.dart';

export 'mode_app_bar_action_build_context.dart';
export 'mode_content_build_context.dart';

abstract interface class StudyModeContentBuilder {
  StudyMode get mode;

  String resolveModeLabel(AppLocalizations l10n);

  IconData resolveModeIcon();

  bool get centerTitle;

  double resolveHeaderToContentGap();

  double resolveProgressToModeGap();

  List<Widget> buildAppBarActions(ModeAppBarActionBuildContext context);

  Widget buildContent(ModeContentBuildContext context);

  Widget buildContentLayout(BuildContext context, Widget unitContent);
}
