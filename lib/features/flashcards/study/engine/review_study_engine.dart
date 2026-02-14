import '../../model/flashcard_models.dart';
import '../model/study_answer.dart';
import '../model/study_constants.dart';
import '../model/study_mode.dart';
import '../model/study_unit.dart';
import 'study_engine.dart';
import 'study_engine_utils.dart';

class ReviewStudyEngine implements StudyEngine {
  ReviewStudyEngine({
    required List<FlashcardItem> items,
    required int initialIndex,
  }) : _units = _buildUnits(items) {
    _currentIndex = StudyEngineUtils.resolveSafeInitialIndex(
      requestedIndex: initialIndex,
      itemCount: _units.length,
    );
  }

  final List<ReviewUnit> _units;
  int _currentIndex = StudyConstants.defaultIndex;

  @override
  StudyMode get mode => StudyMode.review;

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
  int get correctCount => StudyConstants.defaultIndex;

  @override
  int get wrongCount => StudyConstants.defaultIndex;

  @override
  bool get isCompleted {
    if (_units.isEmpty) {
      return true;
    }
    return _currentIndex >= _units.length;
  }

  @override
  void submitAnswer(StudyAnswer answer) {}

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

  static List<ReviewUnit> _buildUnits(List<FlashcardItem> items) {
    return items.map((item) {
      return ReviewUnit(
        unitId: item.id.toString(),
        flashcardId: item.id,
        frontText: item.frontText,
        backText: item.backText,
        note: item.note,
      );
    }).toList(growable: false);
  }
}
