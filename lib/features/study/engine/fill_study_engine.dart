// quality-guard: allow-long-function - phase3 legacy backlog tracked for incremental extraction.
import 'package:learnwise/features/flashcards/model/flashcard_models.dart';
import '../../../../core/utils/string_utils.dart';
import '../model/study_answer.dart';
import '../model/study_constants.dart';
import '../model/study_mode.dart';
import '../model/study_unit.dart';
import 'study_engine.dart';
import 'study_engine_utils.dart';

class FillStudyEngine implements StudyEngine {
  FillStudyEngine({
    required List<FlashcardItem> items,
    required int initialIndex,
  }) : _units = _buildUnits(items) {
    _currentIndex = StudyEngineUtils.resolveSafeInitialIndex(
      requestedIndex: initialIndex,
      itemCount: _units.length,
    );
  }

  final List<FillUnit> _units;
  final Set<int> _submittedIndexes = <int>{};
  int _currentIndex = StudyConstants.defaultIndex;
  int _correctCount = StudyConstants.defaultIndex;
  int _wrongCount = StudyConstants.defaultIndex;

  @override
  StudyMode get mode => StudyMode.fill;

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
    if (answer is! FillStudyAnswer) {
      return;
    }
    if (_submittedIndexes.contains(_currentIndex)) {
      return;
    }
    _submittedIndexes.add(_currentIndex);
    final FillUnit unit = _units[_currentIndex];
    final bool isCorrect = _isCorrect(
      actual: answer.text,
      expected: unit.expectedAnswer,
    );
    if (isCorrect) {
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

  static List<FillUnit> _buildUnits(List<FlashcardItem> items) {
    return items
        .map((item) {
          return FillUnit(
            unitId: item.id.toString(),
            prompt: item.frontText,
            expectedAnswer: item.backText,
          );
        })
        .toList(growable: false);
  }

  bool _isCorrect({required String actual, required String expected}) {
    final String normalizedActual = _normalizeForCompare(actual);
    final String normalizedExpected = _normalizeForCompare(expected);
    if (normalizedActual.isEmpty) {
      return false;
    }
    if (normalizedActual == normalizedExpected) {
      return true;
    }
    final int distance = _levenshteinDistance(
      left: normalizedActual,
      right: normalizedExpected,
    );
    return distance <= StudyConstants.fillToleranceDistance;
  }

  String _normalizeForCompare(String value) {
    return StringUtils.normalize(value).toLowerCase();
  }

  int _levenshteinDistance({required String left, required String right}) {
    if (left.isEmpty) {
      return right.length;
    }
    if (right.isEmpty) {
      return left.length;
    }
    final int columnCount = right.length + 1;
    List<int> previous = List<int>.generate(columnCount, (index) => index);
    for (
      int leftIndex = StudyConstants.defaultIndex;
      leftIndex < left.length;
    ) {
      final List<int> current = List<int>.filled(columnCount, 0);
      current[StudyConstants.defaultIndex] = leftIndex + 1;
      for (
        int rightIndex = StudyConstants.defaultIndex;
        rightIndex < right.length;
      ) {
        final int insertionCost = current[rightIndex] + 1;
        final int deletionCost = previous[rightIndex + 1] + 1;
        final int substitutionCost =
            previous[rightIndex] +
            (left[leftIndex] == right[rightIndex] ? 0 : 1);
        current[rightIndex + 1] = _min3(
          insertionCost,
          deletionCost,
          substitutionCost,
        );
        rightIndex++;
      }
      previous = current;
      leftIndex++;
    }
    return previous[columnCount - 1];
  }

  int _min3(int first, int second, int third) {
    int minValue = first;
    if (second < minValue) {
      minValue = second;
    }
    if (third < minValue) {
      minValue = third;
    }
    return minValue;
  }
}
