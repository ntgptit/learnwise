import '../model/study_answer.dart';
import '../model/study_mode.dart';
import '../model/study_unit.dart';

abstract class StudyEngine {
  StudyMode get mode;
  StudyUnit? get currentUnit;
  int get currentIndex;
  int get totalUnits;
  int get correctCount;
  int get wrongCount;
  bool get isCompleted;

  void submitAnswer(StudyAnswer answer);
  void next();
}
