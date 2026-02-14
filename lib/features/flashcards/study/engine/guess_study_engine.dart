import 'dart:math';

import '../../model/flashcard_models.dart';
import '../model/study_answer.dart';
import '../model/study_constants.dart';
import '../model/study_mode.dart';
import '../model/study_unit.dart';
import 'study_engine.dart';
import 'study_engine_utils.dart';

// quality-guard: allow-long-function
class GuessStudyEngine implements StudyEngine {
  GuessStudyEngine({
    required List<FlashcardItem> items,
    required int initialIndex,
    required Random random,
  }) : _units = _buildUnits(items: items, random: random) {
    _currentIndex = StudyEngineUtils.resolveSafeInitialIndex(
      requestedIndex: initialIndex,
      itemCount: _units.length,
    );
  }

  final List<GuessUnit> _units;
  final Set<int> _submittedIndexes = <int>{};
  int _currentIndex = StudyConstants.defaultIndex;
  int _correctCount = StudyConstants.defaultIndex;
  int _wrongCount = StudyConstants.defaultIndex;

  @override
  StudyMode get mode => StudyMode.guess;

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
    if (answer is! GuessStudyAnswer) {
      return;
    }
    if (_submittedIndexes.contains(_currentIndex)) {
      return;
    }
    _submittedIndexes.add(_currentIndex);
    final GuessUnit unit = _units[_currentIndex];
    if (answer.optionId == unit.correctOptionId) {
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
    final int clampedIndex = index.clamp(StudyConstants.defaultIndex, _units.length - 1);
    if (_currentIndex == clampedIndex) {
      return;
    }
    _currentIndex = clampedIndex;
  }

  static List<GuessUnit> _buildUnits({
    required List<FlashcardItem> items,
    required Random random,
  }) {
    return items.map((item) {
      final List<FlashcardItem> distractorPool = items.where((candidate) {
        return candidate.id != item.id;
      }).toList(growable: false);
      final List<FlashcardItem> shuffledPool = StudyEngineUtils.shuffledCopy(
        values: distractorPool,
        random: random,
      );
      const int maxDistractorCount = StudyConstants.defaultGuessOptionCount - 1;
      final int distractorCount = min(maxDistractorCount, shuffledPool.length);
      final List<GuessOption> options = <GuessOption>[
        GuessOption(
          id: item.id.toString(),
          label: item.backText,
        ),
      ];
      for (int index = StudyConstants.defaultIndex; index < distractorCount;) {
        final FlashcardItem distractor = shuffledPool[index];
        options.add(
          GuessOption(id: distractor.id.toString(), label: distractor.backText),
        );
        index++;
      }
      final List<GuessOption> shuffledOptions = StudyEngineUtils.shuffledCopy(
        values: options,
        random: random,
      );
      return GuessUnit(
        unitId: item.id.toString(),
        prompt: item.frontText,
        correctOptionId: item.id.toString(),
        options: shuffledOptions,
      );
    }).toList(growable: false);
  }
}
