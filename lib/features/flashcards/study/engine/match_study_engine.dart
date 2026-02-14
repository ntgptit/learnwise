import 'dart:math';

import '../../model/flashcard_models.dart';
import '../model/study_answer.dart';
import '../model/study_constants.dart';
import '../model/study_mode.dart';
import '../model/study_unit.dart';
import 'study_engine.dart';
import 'study_engine_utils.dart';

class MatchStudyEngine implements StudyEngine {
  MatchStudyEngine({
    required List<FlashcardItem> items,
    required Random random,
  }) : _unit = _buildUnit(items: items, random: random) {
    _targetMatchCount = _unit.leftEntries.length;
    if (_targetMatchCount <= StudyConstants.defaultIndex) {
      _isCompleted = true;
    }
  }

  MatchUnit _unit;
  int _targetMatchCount = StudyConstants.defaultIndex;
  int _correctCount = StudyConstants.defaultIndex;
  int _wrongCount = StudyConstants.defaultIndex;
  bool _isCompleted = false;

  @override
  StudyMode get mode => StudyMode.match;

  @override
  StudyUnit? get currentUnit {
    if (_isCompleted) {
      return null;
    }
    return _unit;
  }

  @override
  int get currentIndex => StudyConstants.defaultIndex;

  @override
  int get totalUnits => _targetMatchCount <= 0 ? 0 : 1;

  @override
  int get correctCount => _correctCount;

  @override
  int get wrongCount => _wrongCount;

  @override
  bool get isCompleted => _isCompleted;

  @override
  void submitAnswer(StudyAnswer answer) {
    if (_isCompleted) {
      return;
    }
    if (answer is MatchSelectLeftStudyAnswer) {
      _onLeftSelected(answer.leftId);
      return;
    }
    if (answer is MatchSelectRightStudyAnswer) {
      _onRightSelected(answer.rightId);
    }
  }

  @override
  void next() {}

  void _onLeftSelected(int leftId) {
    if (_unit.matchedIds.contains(leftId)) {
      return;
    }
    _unit = _unit.copyWith(selectedLeftId: leftId);
    _tryResolvePair();
  }

  void _onRightSelected(int rightId) {
    if (_unit.matchedIds.contains(rightId)) {
      return;
    }
    _unit = _unit.copyWith(selectedRightId: rightId);
    _tryResolvePair();
  }

  void _tryResolvePair() {
    final int? leftId = _unit.selectedLeftId;
    final int? rightId = _unit.selectedRightId;
    if (leftId == null) {
      return;
    }
    if (rightId == null) {
      return;
    }
    if (leftId == rightId) {
      final Set<int> nextMatchedIds = Set<int>.from(_unit.matchedIds);
      nextMatchedIds.add(leftId);
      _correctCount = nextMatchedIds.length;
      _unit = _unit.copyWith(
        matchedIds: nextMatchedIds,
        clearSelectedLeftId: true,
        clearSelectedRightId: true,
      );
      _isCompleted = nextMatchedIds.length >= _targetMatchCount;
      return;
    }
    _wrongCount++;
    _unit = _unit.copyWith(
      clearSelectedLeftId: true,
      clearSelectedRightId: true,
    );
  }

  static MatchUnit _buildUnit({
    required List<FlashcardItem> items,
    required Random random,
  }) {
    if (items.length < StudyConstants.minimumMatchPairCount) {
      return const MatchUnit(
        unitId: StudyConstants.matchBoardUnitId,
        leftEntries: <MatchEntry>[],
        rightEntries: <MatchEntry>[],
        matchedIds: <int>{},
        selectedLeftId: null,
        selectedRightId: null,
      );
    }
    final List<MatchEntry> leftEntries = items.map((item) {
      return MatchEntry(id: item.id, label: item.frontText);
    }).toList(growable: false);
    final List<MatchEntry> rightEntries = items.map((item) {
      return MatchEntry(id: item.id, label: item.backText);
    }).toList(growable: false);
    final List<MatchEntry> shuffledLeftEntries = StudyEngineUtils.shuffledCopy(
      values: leftEntries,
      random: random,
    );
    final List<MatchEntry> shuffledRightEntries = StudyEngineUtils.shuffledCopy(
      values: rightEntries,
      random: random,
    );
    return MatchUnit(
      unitId: StudyConstants.matchBoardUnitId,
      leftEntries: shuffledLeftEntries,
      rightEntries: shuffledRightEntries,
      matchedIds: const <int>{},
      selectedLeftId: null,
      selectedRightId: null,
    );
  }
}
