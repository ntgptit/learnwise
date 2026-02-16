import 'package:flutter/foundation.dart';

@immutable
abstract class StudyAnswer {
  const StudyAnswer();
}

@immutable
class GuessStudyAnswer extends StudyAnswer {
  const GuessStudyAnswer({required this.optionId});

  final String optionId;
}

@immutable
class RecallStudyAnswer extends StudyAnswer {
  const RecallStudyAnswer({required this.isRemembered});

  final bool isRemembered;
}

@immutable
class FillStudyAnswer extends StudyAnswer {
  const FillStudyAnswer({required this.text});

  final String text;
}

@immutable
class MatchSelectLeftStudyAnswer extends StudyAnswer {
  const MatchSelectLeftStudyAnswer({required this.leftId});

  final int leftId;
}

@immutable
class MatchSelectRightStudyAnswer extends StudyAnswer {
  const MatchSelectRightStudyAnswer({required this.rightId});

  final int rightId;
}
