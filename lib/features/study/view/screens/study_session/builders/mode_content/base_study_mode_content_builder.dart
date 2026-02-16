import 'package:flutter/material.dart';

import 'package:learnwise/common/styles/app_screen_tokens.dart';
import 'study_mode_content_builder.dart';

export 'study_mode_content_builder.dart';

abstract class BaseStudyModeContentBuilder implements StudyModeContentBuilder {
  const BaseStudyModeContentBuilder();

  @override
  bool get centerTitle {
    return true;
  }

  @override
  double resolveHeaderToContentGap() {
    return FlashcardStudySessionTokens.sectionSpacing;
  }

  @override
  double resolveProgressToModeGap() {
    return FlashcardStudySessionTokens.answerSpacing;
  }

  @override
  List<Widget> buildAppBarActions(ModeAppBarActionBuildContext context) {
    return const <Widget>[];
  }

  @override
  Widget buildContentLayout(BuildContext context, Widget unitContent) {
    return unitContent;
  }
}
