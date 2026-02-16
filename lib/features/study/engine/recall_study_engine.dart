import 'package:learnwise/features/flashcards/model/flashcard_models.dart';
import '../model/study_answer.dart';
import '../model/study_constants.dart';
import '../model/study_mode.dart';
import '../model/study_unit.dart';
import 'study_engine.dart';
import 'study_engine_utils.dart';

class RecallStudyEngine implements StudyEngine {
  RecallStudyEngine({
    required List<FlashcardItem> items,
    required int initialIndex,
  }) : _units = _buildUnits(items) {
    _currentIndex = StudyEngineUtils.resolveSafeInitialIndex(
      requestedIndex: initialIndex,
      itemCount: _units.length,
    );
  }

  final List<RecallUnit> _units;
  final Set<int> _submittedIndexes = <int>{};
  int _currentIndex = StudyConstants.defaultIndex;
  int _correctCount = StudyConstants.defaultIndex;
  int _wrongCount = StudyConstants.defaultIndex;

  @override
  StudyMode get mode => StudyMode.recall;

  @override
  StudyUnit? get currentUnit {
    if (isCompleted) {
      return null;
    }
    return _units[_currentIndex];
  }

  @override
  int get currentIndex => _currentIndex;

  @override
  int get totalUnits => _units.length;

  @override
  int get correctCount => _correctCount;

  @override
  int get wrongCount => _wrongCount;

  @override
  bool get isCompleted {
    if (_units.isEmpty) {
      return true;
    }
    return _currentIndex >= _units.length;
  }

  @override
  void submitAnswer(StudyAnswer answer) {
    if (isCompleted) {
      return;
    }
    if (answer is! RecallStudyAnswer) {
      return;
    }
    if (_submittedIndexes.contains(_currentIndex)) {
      return;
    }
    _submittedIndexes.add(_currentIndex);
    if (answer.isRemembered) {
      _correctCount++;
      return;
    }
    _wrongCount++;
  }

  @override
  void next() {
    if (isCompleted) {
      return;
    }
    if (_currentIndex >= _units.length - 1) {
      _currentIndex = _units.length;
      return;
    }
    _currentIndex++;
  }

  @override
  void previous() {
    if (_units.isEmpty) {
      return;
    }
    if (_currentIndex > _units.length - 1) {
      _currentIndex = _units.length - 1;
      return;
    }
    if (_currentIndex <= StudyConstants.defaultIndex) {
      return;
    }
    _currentIndex--;
  }

  @override
  void goTo(int index) {
    if (_units.isEmpty) {
      return;
    }
    final int clampedIndex = index.clamp(
      StudyConstants.defaultIndex,
      _units.length - 1,
    );
    if (_currentIndex == clampedIndex) {
      return;
    }
    _currentIndex = clampedIndex;
  }

  static List<RecallUnit> _buildUnits(List<FlashcardItem> items) {
    return items
        .map((item) {
          return RecallUnit(
            unitId: item.id.toString(),
            prompt: item.frontText,
            answer: item.backText,
          );
        })
        .toList(growable: false);
  }
}
