import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/string_utils.dart';
import '../model/study_answer.dart';
import '../model/study_constants.dart';
import '../model/study_mode.dart';
import '../model/study_session_args.dart';
import '../model/study_session_models.dart';
import '../model/study_unit.dart';
import '../repository/study_session_repository.dart';
import '../repository/study_session_repository_provider.dart';

part 'study_session_viewmodel.g.dart';

class StudySessionState {
  const StudySessionState({
    required this.mode,
    required this.reviewUnits,
    required this.currentUnit,
    required this.currentIndex,
    required this.totalCount,
    required this.progressPercent,
    required this.isFrontVisible,
    required this.playingFlashcardId,
    required this.correctCount,
    required this.wrongCount,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.isCompleted,
    required this.matchHiddenIds,
    required this.matchSuccessFlashKeys,
    required this.matchErrorFlashKeys,
    required this.isMatchInteractionLocked,
  });

  final StudyMode mode;
  final List<ReviewUnit> reviewUnits;
  final StudyUnit? currentUnit;
  final int currentIndex;
  final int totalCount;
  final double progressPercent;
  final bool isFrontVisible;
  final int? playingFlashcardId;
  final int correctCount;
  final int wrongCount;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool isCompleted;
  final Set<int> matchHiddenIds;
  final Set<String> matchSuccessFlashKeys;
  final Set<String> matchErrorFlashKeys;
  final bool isMatchInteractionLocked;

  factory StudySessionState.initial({
    required StudyMode mode,
    required List<ReviewUnit> reviewUnits,
    required StudyUnit? currentUnit,
    required int currentIndex,
    required int totalCount,
  }) {
    return StudySessionState(
      mode: mode,
      reviewUnits: List<ReviewUnit>.unmodifiable(reviewUnits),
      currentUnit: currentUnit,
      currentIndex: currentIndex,
      totalCount: totalCount,
      progressPercent: _resolveProgressPercent(
        currentIndex: currentIndex,
        totalCount: totalCount,
        isCompleted: false,
      ),
      isFrontVisible: true,
      playingFlashcardId: null,
      correctCount: 0,
      wrongCount: 0,
      canGoPrevious: currentIndex > StudyConstants.defaultIndex,
      canGoNext: totalCount > StudyConstants.defaultIndex,
      isCompleted: false,
      matchHiddenIds: const <int>{},
      matchSuccessFlashKeys: const <String>{},
      matchErrorFlashKeys: const <String>{},
      isMatchInteractionLocked: false,
    );
  }

  StudySessionState copyWith({
    StudyMode? mode,
    List<ReviewUnit>? reviewUnits,
    StudyUnit? currentUnit,
    bool clearCurrentUnit = false,
    int? currentIndex,
    int? totalCount,
    double? progressPercent,
    bool? isFrontVisible,
    int? playingFlashcardId,
    bool clearPlayingFlashcardId = false,
    int? correctCount,
    int? wrongCount,
    bool? canGoPrevious,
    bool? canGoNext,
    bool? isCompleted,
    Set<int>? matchHiddenIds,
    Set<String>? matchSuccessFlashKeys,
    Set<String>? matchErrorFlashKeys,
    bool? isMatchInteractionLocked,
  }) {
    final StudyUnit? nextCurrentUnit = clearCurrentUnit
        ? null
        : (currentUnit ?? this.currentUnit);
    final int? nextPlayingFlashcardId = clearPlayingFlashcardId
        ? null
        : (playingFlashcardId ?? this.playingFlashcardId);
    return StudySessionState(
      mode: mode ?? this.mode,
      reviewUnits: List<ReviewUnit>.unmodifiable(
        reviewUnits ?? this.reviewUnits,
      ),
      currentUnit: nextCurrentUnit,
      currentIndex: currentIndex ?? this.currentIndex,
      totalCount: totalCount ?? this.totalCount,
      progressPercent: progressPercent ?? this.progressPercent,
      isFrontVisible: isFrontVisible ?? this.isFrontVisible,
      playingFlashcardId: nextPlayingFlashcardId,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      canGoPrevious: canGoPrevious ?? this.canGoPrevious,
      canGoNext: canGoNext ?? this.canGoNext,
      isCompleted: isCompleted ?? this.isCompleted,
      matchHiddenIds: Set<int>.unmodifiable(
        matchHiddenIds ?? this.matchHiddenIds,
      ),
      matchSuccessFlashKeys: Set<String>.unmodifiable(
        matchSuccessFlashKeys ?? this.matchSuccessFlashKeys,
      ),
      matchErrorFlashKeys: Set<String>.unmodifiable(
        matchErrorFlashKeys ?? this.matchErrorFlashKeys,
      ),
      isMatchInteractionLocked:
          isMatchInteractionLocked ?? this.isMatchInteractionLocked,
    );
  }

  int get currentStep {
    if (totalCount <= StudyConstants.defaultIndex) {
      return StudyConstants.defaultIndex;
    }
    if (isCompleted) {
      return totalCount;
    }
    return (currentIndex + 1).clamp(1, totalCount);
  }

  int get totalSteps => totalCount;
}

@Riverpod(keepAlive: true)
class StudySessionController extends _$StudySessionController {
  late StudySessionRepository _repository;
  late StudySessionArgs _args;
  int? _sessionId;
  StudySessionResponseModel? _lastResponse;
  List<StudyUnit> _linearUnits = const <StudyUnit>[];
  bool _isLinearCompleted = false;
  bool _isFrontVisible = true;
  int? _playingFlashcardId;
  Timer? _audioPlayingIndicatorTimer;
  Timer? _localMatchFeedbackTimer;
  int _clientSequence = StudyConstants.defaultClientSequence;
  Set<int> _submittedAnswerIndexes = <int>{};
  int _localCorrectCount = StudyConstants.defaultIndex;
  int _localWrongCount = StudyConstants.defaultIndex;

  @override
  StudySessionState build(StudySessionArgs args) {
    _repository = ref.read(studySessionRepositoryProvider);
    _args = args;
    _resetControllerState();
    ref.onDispose(() {
      _audioPlayingIndicatorTimer?.cancel();
      _localMatchFeedbackTimer?.cancel();
    });
    final StudySessionState bootstrapState = _buildBootstrapState(args);
    unawaited(_startSessionFromBackend());
    return bootstrapState;
  }

  void submitAnswer(StudyAnswer answer) {
    if (_isMatchAnswer(answer)) {
      _submitMatchAnswer(answer);
      return;
    }
    _submitLinearAnswer(answer);
  }

  void next() {
    if (!_isLinearMode(state.mode)) {
      return;
    }
    if (state.totalCount <= StudyConstants.defaultIndex) {
      return;
    }
    if (state.isCompleted) {
      return;
    }
    if (state.currentIndex >= state.totalCount - 1) {
      _isLinearCompleted = true;
      _clearAudioPlayingIndicator();
      _syncFromSnapshot();
      return;
    }
    _isFrontVisible = true;
    _isLinearCompleted = false;
    _clearAudioPlayingIndicator();
    if (_sessionId == null) {
      _moveLinearLocallyTo(state.currentIndex + 1);
      return;
    }
    _sendLinearEvent(
      StudySessionEventType.reviewNext,
      targetIndex: state.currentIndex + 1,
    );
  }

  void previous() {
    if (!_isLinearMode(state.mode)) {
      return;
    }
    if (state.totalCount <= StudyConstants.defaultIndex) {
      return;
    }
    if (state.isCompleted) {
      _isLinearCompleted = false;
      _syncFromSnapshot();
      return;
    }
    final int previousIndex = (state.currentIndex - 1).clamp(
      StudyConstants.defaultIndex,
      state.totalCount - 1,
    );
    _isFrontVisible = true;
    _isLinearCompleted = false;
    _clearAudioPlayingIndicator();
    if (_sessionId == null) {
      _moveLinearLocallyTo(previousIndex);
      return;
    }
    _sendLinearEvent(
      StudySessionEventType.reviewPrevious,
      targetIndex: previousIndex,
    );
  }

  void goTo(int index) {
    if (!_isLinearMode(state.mode)) {
      return;
    }
    if (state.totalCount <= StudyConstants.defaultIndex) {
      return;
    }
    final int targetIndex = index.clamp(
      StudyConstants.defaultIndex,
      state.totalCount - 1,
    );
    if (targetIndex == state.currentIndex && !state.isCompleted) {
      return;
    }
    _isFrontVisible = true;
    _isLinearCompleted = false;
    _clearAudioPlayingIndicator();
    if (_sessionId == null) {
      _moveLinearLocallyTo(targetIndex);
      return;
    }
    _sendLinearEvent(
      StudySessionEventType.reviewGotoIndex,
      targetIndex: targetIndex,
    );
  }

  void _moveLinearLocallyTo(int targetIndex) {
    final int totalCount = state.totalCount;
    if (totalCount <= StudyConstants.defaultIndex) {
      _syncLocalLinearState();
      return;
    }
    final int clampedIndex = targetIndex.clamp(
      StudyConstants.defaultIndex,
      totalCount - 1,
    );
    _isLinearCompleted = false;
    final StudyUnit? currentUnit = _resolveCurrentLinearUnit(
      units: _linearUnits,
      currentIndex: clampedIndex,
      isCompleted: false,
    );
    state = state.copyWith(
      currentUnit: currentUnit,
      currentIndex: clampedIndex,
      totalCount: totalCount,
      progressPercent: _resolveProgressPercent(
        currentIndex: clampedIndex,
        totalCount: totalCount,
        isCompleted: false,
      ),
      isFrontVisible: _isFrontVisible,
      playingFlashcardId: _playingFlashcardId,
      correctCount: _localCorrectCount,
      wrongCount: _localWrongCount,
      canGoPrevious: _resolveCanGoPrevious(
        currentIndex: clampedIndex,
        totalCount: totalCount,
        isCompleted: false,
      ),
      canGoNext: _resolveCanGoNext(totalCount: totalCount, isCompleted: false),
      isCompleted: false,
    );
  }

  void submitFlip() {
    final StudyUnit? currentUnit = state.currentUnit;
    if (currentUnit is! ReviewUnit) {
      return;
    }
    _isFrontVisible = !_isFrontVisible;
    state = state.copyWith(isFrontVisible: _isFrontVisible);
  }

  void playCurrentAudio() {
    final StudyUnit? currentUnit = state.currentUnit;
    if (currentUnit is! ReviewUnit) {
      return;
    }
    _startAudioPlayingIndicator(currentUnit.flashcardId);
    state = state.copyWith(playingFlashcardId: _playingFlashcardId);
  }

  void playAudioFor(int flashcardId) {
    _startAudioPlayingIndicator(flashcardId);
    state = state.copyWith(playingFlashcardId: _playingFlashcardId);
  }

  void clearAudioPlaying() {
    _clearAudioPlayingIndicator();
    state = state.copyWith(clearPlayingFlashcardId: true);
  }

  void restart() {
    ref.invalidateSelf();
  }

  Future<void> _startSessionFromBackend() async {
    if (_args.deckId <= StudyConstants.defaultIndex) {
      return;
    }
    try {
      final StudySessionResponseModel response = await _repository.startSession(
        deckId: _args.deckId,
        request: StudySessionStartRequest(mode: _args.mode, seed: _args.seed),
      );
      if (!ref.mounted) {
        return;
      }
      _sessionId = response.sessionId;
      _lastResponse = response;
      _syncFromSnapshot();
    } catch (_) {}
  }

  void _sendLinearEvent(StudySessionEventType eventType, {int? targetIndex}) {
    final int? sessionId = _sessionId;
    if (sessionId == null) {
      return;
    }
    unawaited(
      _submitEvent(
        sessionId: sessionId,
        eventType: eventType,
        targetIndex: targetIndex,
      ),
    );
  }

  void _submitMatchAnswer(StudyAnswer answer) {
    if (state.isMatchInteractionLocked) {
      return;
    }
    final int? sessionId = _sessionId;
    if (sessionId == null) {
      _submitLocalMatchAnswer(answer);
      return;
    }
    StudySessionEventType? eventType;
    int? targetTileId;
    if (answer is MatchSelectLeftStudyAnswer) {
      eventType = StudySessionEventType.matchSelectLeft;
      targetTileId = answer.leftId;
    }
    if (answer is MatchSelectRightStudyAnswer) {
      eventType = StudySessionEventType.matchSelectRight;
      targetTileId = answer.rightId;
    }
    if (eventType == null) {
      return;
    }
    if (targetTileId == null) {
      return;
    }
    unawaited(
      _submitEvent(
        sessionId: sessionId,
        eventType: eventType,
        targetTileId: targetTileId,
      ),
    );
  }

  void _submitLocalMatchAnswer(StudyAnswer answer) {
    final StudyUnit? currentUnit = state.currentUnit;
    if (currentUnit is! MatchUnit) {
      return;
    }
    MatchUnit nextUnit = currentUnit;
    if (answer is MatchSelectLeftStudyAnswer) {
      if (currentUnit.matchedIds.contains(answer.leftId)) {
        return;
      }
      nextUnit = currentUnit.copyWith(
        selectedLeftId: answer.leftId,
        clearLastAttemptResult: true,
      );
    }
    if (answer is MatchSelectRightStudyAnswer) {
      if (currentUnit.matchedIds.contains(answer.rightId)) {
        return;
      }
      nextUnit = currentUnit.copyWith(
        selectedRightId: answer.rightId,
        clearLastAttemptResult: true,
      );
    }
    final int? leftId = nextUnit.selectedLeftId;
    final int? rightId = nextUnit.selectedRightId;
    if (leftId == null) {
      state = state.copyWith(currentUnit: nextUnit);
      return;
    }
    if (rightId == null) {
      state = state.copyWith(currentUnit: nextUnit);
      return;
    }
    if (leftId == rightId) {
      final Set<int> matchedIds = Set<int>.from(nextUnit.matchedIds)
        ..add(leftId);
      _localCorrectCount = matchedIds.length;
      final MatchUnit successUnit = nextUnit.copyWith(
        matchedIds: matchedIds,
        clearSelectedLeftId: true,
        clearSelectedRightId: true,
        lastAttemptResult: MatchAttemptResult(
          leftId: leftId,
          rightId: rightId,
          type: MatchAttemptResultType.correct,
        ),
      );
      final Set<int> hiddenIds = Set<int>.from(state.matchHiddenIds)
        ..add(leftId);
      _startLocalMatchFeedback(
        updatedUnit: successUnit,
        hiddenIds: hiddenIds,
        successFlashKeys: <String>{
          _buildMatchTileFlashKey(isLeftTile: true, tileId: leftId),
          _buildMatchTileFlashKey(isLeftTile: false, tileId: rightId),
        },
        errorFlashKeys: const <String>{},
      );
      return;
    }
    _localWrongCount++;
    final MatchUnit errorUnit = nextUnit.copyWith(
      clearSelectedLeftId: true,
      clearSelectedRightId: true,
      lastAttemptResult: MatchAttemptResult(
        leftId: leftId,
        rightId: rightId,
        type: MatchAttemptResultType.wrong,
      ),
    );
    _startLocalMatchFeedback(
      updatedUnit: errorUnit,
      hiddenIds: state.matchHiddenIds,
      successFlashKeys: const <String>{},
      errorFlashKeys: <String>{
        _buildMatchTileFlashKey(isLeftTile: true, tileId: leftId),
        _buildMatchTileFlashKey(isLeftTile: false, tileId: rightId),
      },
    );
  }

  void _startLocalMatchFeedback({
    required MatchUnit updatedUnit,
    required Set<int> hiddenIds,
    required Set<String> successFlashKeys,
    required Set<String> errorFlashKeys,
  }) {
    _localMatchFeedbackTimer?.cancel();
    final int totalCount = updatedUnit.leftEntries.length;
    final int currentIndex = updatedUnit.matchedIds.length;
    final bool isCompleted = totalCount > 0 && currentIndex >= totalCount;
    state = state.copyWith(
      currentUnit: updatedUnit,
      currentIndex: currentIndex,
      totalCount: totalCount,
      progressPercent: _resolveProgressPercent(
        currentIndex: currentIndex,
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      correctCount: _localCorrectCount,
      wrongCount: _localWrongCount,
      canGoPrevious: _resolveCanGoPrevious(
        currentIndex: currentIndex,
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      canGoNext: _resolveCanGoNext(
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      isCompleted: isCompleted,
      matchHiddenIds: hiddenIds,
      matchSuccessFlashKeys: successFlashKeys,
      matchErrorFlashKeys: errorFlashKeys,
      isMatchInteractionLocked: true,
    );
    _localMatchFeedbackTimer = Timer(
      const Duration(milliseconds: StudyConstants.localMatchFeedbackDurationMs),
      () {
        if (!ref.mounted) {
          return;
        }
        final int latestTotalCount = updatedUnit.leftEntries.length;
        final int latestCurrentIndex = updatedUnit.matchedIds.length;
        final bool latestCompleted =
            latestTotalCount > 0 && latestCurrentIndex >= latestTotalCount;
        state = state.copyWith(
          matchHiddenIds: hiddenIds,
          matchSuccessFlashKeys: const <String>{},
          matchErrorFlashKeys: const <String>{},
          isMatchInteractionLocked: false,
          currentUnit: updatedUnit,
          currentIndex: latestCurrentIndex,
          totalCount: latestTotalCount,
          progressPercent: _resolveProgressPercent(
            currentIndex: latestCurrentIndex,
            totalCount: latestTotalCount,
            isCompleted: latestCompleted,
          ),
          canGoPrevious: _resolveCanGoPrevious(
            currentIndex: latestCurrentIndex,
            totalCount: latestTotalCount,
            isCompleted: latestCompleted,
          ),
          canGoNext: _resolveCanGoNext(
            totalCount: latestTotalCount,
            isCompleted: latestCompleted,
          ),
          isCompleted: latestCompleted,
          correctCount: _localCorrectCount,
          wrongCount: _localWrongCount,
        );
      },
    );
  }

  Future<void> _submitEvent({
    required int sessionId,
    required StudySessionEventType eventType,
    int? targetTileId,
    int? targetIndex,
  }) async {
    final StudySessionEventRequest request = StudySessionEventRequest(
      clientEventId: _buildClientEventId(eventType),
      clientSequence: _clientSequence,
      eventType: eventType,
      targetTileId: targetTileId,
      targetIndex: targetIndex,
    );
    _clientSequence++;
    try {
      final StudySessionResponseModel response = await _repository.submitEvent(
        sessionId: sessionId,
        request: request,
      );
      if (!ref.mounted) {
        return;
      }
      _lastResponse = response;
      _syncFromSnapshot();
    } catch (_) {}
  }

  void _submitLinearAnswer(StudyAnswer answer) {
    if (state.isCompleted) {
      return;
    }
    final int currentIndex = state.currentIndex;
    if (_submittedAnswerIndexes.contains(currentIndex)) {
      return;
    }
    final bool? isCorrect = _resolveLinearAnswerResult(answer: answer);
    if (isCorrect == null) {
      return;
    }
    _submittedAnswerIndexes = Set<int>.from(_submittedAnswerIndexes)
      ..add(currentIndex);
    if (isCorrect) {
      _localCorrectCount++;
    }
    if (!isCorrect) {
      _localWrongCount++;
    }
    state = state.copyWith(
      correctCount: _localCorrectCount,
      wrongCount: _localWrongCount,
    );
  }

  bool? _resolveLinearAnswerResult({required StudyAnswer answer}) {
    final StudyUnit? currentUnit = state.currentUnit;
    if (currentUnit is GuessUnit && answer is GuessStudyAnswer) {
      return answer.optionId == currentUnit.correctOptionId;
    }
    if (currentUnit is RecallUnit && answer is RecallStudyAnswer) {
      return answer.isRemembered;
    }
    if (currentUnit is FillUnit && answer is FillStudyAnswer) {
      return _isFillAnswerCorrect(
        actual: answer.text,
        expected: currentUnit.expectedAnswer,
      );
    }
    return null;
  }

  bool _isFillAnswerCorrect({
    required String actual,
    required String expected,
  }) {
    final String normalizedActual = StringUtils.normalize(actual).toLowerCase();
    final String normalizedExpected = StringUtils.normalize(
      expected,
    ).toLowerCase();
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

  bool _isMatchAnswer(StudyAnswer answer) {
    if (answer is MatchSelectLeftStudyAnswer) {
      return true;
    }
    if (answer is MatchSelectRightStudyAnswer) {
      return true;
    }
    return false;
  }

  void _syncFromSnapshot() {
    final StudySessionResponseModel? snapshot = _lastResponse;
    if (snapshot == null) {
      _syncLocalLinearState();
      return;
    }
    state = _mapResponseToState(snapshot);
  }

  void _syncLocalLinearState() {
    if (!_isLinearMode(state.mode)) {
      return;
    }
    final int totalCount = state.totalCount;
    if (totalCount <= StudyConstants.defaultIndex) {
      state = state.copyWith(
        clearCurrentUnit: true,
        totalCount: StudyConstants.defaultIndex,
        currentIndex: StudyConstants.defaultIndex,
        progressPercent: 0,
        isFrontVisible: _isFrontVisible,
        playingFlashcardId: _playingFlashcardId,
        correctCount: _localCorrectCount,
        wrongCount: _localWrongCount,
        canGoPrevious: false,
        canGoNext: false,
        isCompleted: true,
      );
      return;
    }
    final int currentIndex = state.currentIndex.clamp(
      StudyConstants.defaultIndex,
      totalCount - 1,
    );
    final bool isCompleted = _isLinearCompleted;
    final StudyUnit? currentUnit = _resolveCurrentLinearUnit(
      units: _linearUnits,
      currentIndex: currentIndex,
      isCompleted: isCompleted,
    );
    state = state.copyWith(
      currentUnit: currentUnit,
      clearCurrentUnit: isCompleted,
      currentIndex: currentIndex,
      totalCount: totalCount,
      progressPercent: _resolveProgressPercent(
        currentIndex: currentIndex,
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      isFrontVisible: _isFrontVisible,
      playingFlashcardId: _playingFlashcardId,
      correctCount: _localCorrectCount,
      wrongCount: _localWrongCount,
      canGoPrevious: _resolveCanGoPrevious(
        currentIndex: currentIndex,
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      canGoNext: _resolveCanGoNext(
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      isCompleted: isCompleted,
    );
  }

  StudySessionState _mapResponseToState(StudySessionResponseModel response) {
    if (_isLinearMode(response.mode)) {
      return _buildLinearState(response);
    }
    return _buildMatchState(response);
  }

  StudySessionState _buildLinearState(StudySessionResponseModel response) {
    final List<ReviewUnit> reviewUnits = _buildReviewUnitsFromResponse(
      response,
    );
    final List<StudyUnit> units = _buildLinearUnits(
      mode: response.mode,
      reviewUnits: reviewUnits,
    );
    _linearUnits = units;
    final int totalCount = units.length;
    final int currentIndex = _resolveCurrentIndex(
      responseIndex: response.currentIndex,
      totalCount: totalCount,
    );
    final bool isCompleted = _resolveLinearCompleted(response: response);
    final StudyUnit? currentUnit = _resolveCurrentLinearUnit(
      units: units,
      currentIndex: currentIndex,
      isCompleted: isCompleted,
    );
    final int correctCount = _resolveLinearCorrectCount(response);
    final int wrongCount = _resolveLinearWrongCount(response);
    return StudySessionState(
      mode: response.mode,
      reviewUnits: List<ReviewUnit>.unmodifiable(reviewUnits),
      currentUnit: currentUnit,
      currentIndex: currentIndex,
      totalCount: totalCount,
      progressPercent: _resolveProgressPercent(
        currentIndex: currentIndex,
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      isFrontVisible: _isFrontVisible,
      playingFlashcardId: _playingFlashcardId,
      correctCount: correctCount,
      wrongCount: wrongCount,
      canGoPrevious: _resolveCanGoPrevious(
        currentIndex: currentIndex,
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      canGoNext: _resolveCanGoNext(
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      isCompleted: isCompleted,
      matchHiddenIds: const <int>{},
      matchSuccessFlashKeys: const <String>{},
      matchErrorFlashKeys: const <String>{},
      isMatchInteractionLocked: false,
    );
  }

  StudySessionState _buildMatchState(StudySessionResponseModel response) {
    final List<StudyMatchTileModel> leftTiles = response.leftTiles;
    final List<StudyMatchTileModel> rightTiles = response.rightTiles;
    final List<MatchEntry> leftEntries = _buildMatchEntries(leftTiles);
    final List<MatchEntry> rightEntries = _buildMatchEntries(rightTiles);
    final Set<int> matchedIds = _buildMatchedIds(
      leftTiles: leftTiles,
      rightTiles: rightTiles,
    );
    final int? selectedLeftId = _resolveSelectedTileId(leftTiles);
    final int? selectedRightId = _resolveSelectedTileId(rightTiles);
    final MatchAttemptResult? lastAttemptResult = _resolveMatchAttemptResult(
      response.lastAttemptResult,
    );
    final MatchUnit matchUnit = MatchUnit(
      unitId: StudyConstants.matchBoardUnitId,
      leftEntries: leftEntries,
      rightEntries: rightEntries,
      matchedIds: matchedIds,
      selectedLeftId: selectedLeftId,
      selectedRightId: selectedRightId,
      lastAttemptResult: lastAttemptResult,
    );
    final Set<int> hiddenIds = _buildHiddenIds(
      leftTiles: leftTiles,
      rightTiles: rightTiles,
    );
    final Set<String> successFlashKeys = _buildMatchFlashKeys(
      leftTiles: leftTiles,
      rightTiles: rightTiles,
      selectByTile: (tile) => tile.successFlash,
    );
    final Set<String> errorFlashKeys = _buildMatchFlashKeys(
      leftTiles: leftTiles,
      rightTiles: rightTiles,
      selectByTile: (tile) => tile.errorFlash,
    );
    final bool isInteractionLocked = _resolveMatchInteractionLocked(response);
    return StudySessionState(
      mode: response.mode,
      reviewUnits: const <ReviewUnit>[],
      currentUnit: matchUnit,
      currentIndex: _resolveCurrentIndex(
        responseIndex: response.currentIndex,
        totalCount: response.totalUnits,
      ),
      totalCount: response.totalUnits,
      progressPercent: _resolveProgressPercent(
        currentIndex: response.currentIndex,
        totalCount: response.totalUnits,
        isCompleted: response.completed,
      ),
      isFrontVisible: _isFrontVisible,
      playingFlashcardId: _playingFlashcardId,
      correctCount: response.correctCount,
      wrongCount: response.wrongCount,
      canGoPrevious: _resolveCanGoPrevious(
        currentIndex: response.currentIndex,
        totalCount: response.totalUnits,
        isCompleted: response.completed,
      ),
      canGoNext: _resolveCanGoNext(
        totalCount: response.totalUnits,
        isCompleted: response.completed,
      ),
      isCompleted: response.completed,
      matchHiddenIds: hiddenIds,
      matchSuccessFlashKeys: successFlashKeys,
      matchErrorFlashKeys: errorFlashKeys,
      isMatchInteractionLocked: isInteractionLocked,
    );
  }

  bool _resolveMatchInteractionLocked(StudySessionResponseModel response) {
    final StudyAttemptResultModel? lastAttempt = response.lastAttemptResult;
    if (lastAttempt == null) {
      return false;
    }
    return lastAttempt.interactionLocked;
  }

  int _resolveLinearCorrectCount(StudySessionResponseModel response) {
    if (response.correctCount > StudyConstants.defaultIndex) {
      return response.correctCount;
    }
    return _localCorrectCount;
  }

  int _resolveLinearWrongCount(StudySessionResponseModel response) {
    if (response.wrongCount > StudyConstants.defaultIndex) {
      return response.wrongCount;
    }
    return _localWrongCount;
  }

  bool _resolveLinearCompleted({required StudySessionResponseModel response}) {
    if (response.completed) {
      return true;
    }
    if (_isLinearCompleted) {
      return true;
    }
    return false;
  }

  StudyUnit? _resolveCurrentLinearUnit({
    required List<StudyUnit> units,
    required int currentIndex,
    required bool isCompleted,
  }) {
    if (isCompleted) {
      return null;
    }
    if (units.isEmpty) {
      return null;
    }
    return units[currentIndex];
  }

  List<ReviewUnit> _buildReviewUnitsFromResponse(
    StudySessionResponseModel response,
  ) {
    return response.reviewItems
        .map((item) {
          return ReviewUnit(
            unitId: item.sessionItemId.toString(),
            flashcardId: item.flashcardId,
            frontText: item.frontText,
            backText: item.backText,
            note: '',
          );
        })
        .toList(growable: false);
  }

  List<StudyUnit> _buildLinearUnits({
    required StudyMode mode,
    required List<ReviewUnit> reviewUnits,
  }) {
    if (mode == StudyMode.review) {
      return reviewUnits;
    }
    if (mode == StudyMode.guess) {
      return _buildGuessUnits(reviewUnits);
    }
    if (mode == StudyMode.recall) {
      return reviewUnits
          .map((unit) {
            return RecallUnit(
              unitId: unit.unitId,
              prompt: unit.frontText,
              answer: unit.backText,
            );
          })
          .toList(growable: false);
    }
    if (mode == StudyMode.fill) {
      return reviewUnits
          .map((unit) {
            return FillUnit(
              unitId: unit.unitId,
              prompt: unit.frontText,
              expectedAnswer: unit.backText,
            );
          })
          .toList(growable: false);
    }
    return reviewUnits;
  }

  List<StudyUnit> _buildGuessUnits(List<ReviewUnit> reviewUnits) {
    return reviewUnits
        .map((unit) {
          final List<ReviewUnit> distractorPool = reviewUnits
              .where((candidate) {
                return candidate.flashcardId != unit.flashcardId;
              })
              .toList(growable: false);
          final List<ReviewUnit> shuffledPool = _shuffledCopy(
            values: distractorPool,
            seed: _args.seed + unit.flashcardId,
          );
          const int maxDistractorCount =
              StudyConstants.defaultGuessOptionCount - 1;
          final int distractorCount = min(
            maxDistractorCount,
            shuffledPool.length,
          );
          final List<GuessOption> options = <GuessOption>[
            GuessOption(id: unit.flashcardId.toString(), label: unit.backText),
          ];
          for (
            int index = StudyConstants.defaultIndex;
            index < distractorCount;
          ) {
            final ReviewUnit distractor = shuffledPool[index];
            options.add(
              GuessOption(
                id: distractor.flashcardId.toString(),
                label: distractor.backText,
              ),
            );
            index++;
          }
          final List<GuessOption> shuffledOptions = _shuffledCopy(
            values: options,
            seed: _args.seed + unit.flashcardId + reviewUnits.length,
          );
          return GuessUnit(
            unitId: unit.unitId,
            prompt: unit.frontText,
            correctOptionId: unit.flashcardId.toString(),
            options: shuffledOptions,
          );
        })
        .toList(growable: false);
  }

  List<T> _shuffledCopy<T>({required List<T> values, required int seed}) {
    final List<T> copy = List<T>.from(values);
    copy.shuffle(Random(seed));
    return copy;
  }

  List<MatchEntry> _buildMatchEntries(List<StudyMatchTileModel> tiles) {
    final List<StudyMatchTileModel> sortedTiles =
        List<StudyMatchTileModel>.from(
          tiles,
        )..sort((first, second) => first.tileOrder.compareTo(second.tileOrder));
    return sortedTiles
        .map((tile) {
          return MatchEntry(id: tile.tileId, label: tile.label);
        })
        .toList(growable: false);
  }

  Set<int> _buildMatchedIds({
    required List<StudyMatchTileModel> leftTiles,
    required List<StudyMatchTileModel> rightTiles,
  }) {
    final Set<int> matchedIds = <int>{};
    for (final StudyMatchTileModel tile in leftTiles) {
      if (tile.matched) {
        matchedIds.add(tile.tileId);
      }
    }
    for (final StudyMatchTileModel tile in rightTiles) {
      if (tile.matched) {
        matchedIds.add(tile.tileId);
      }
    }
    return Set<int>.unmodifiable(matchedIds);
  }

  Set<int> _buildHiddenIds({
    required List<StudyMatchTileModel> leftTiles,
    required List<StudyMatchTileModel> rightTiles,
  }) {
    final Set<int> hiddenIds = <int>{};
    for (final StudyMatchTileModel tile in leftTiles) {
      if (tile.hidden) {
        hiddenIds.add(tile.tileId);
      }
    }
    for (final StudyMatchTileModel tile in rightTiles) {
      if (tile.hidden) {
        hiddenIds.add(tile.tileId);
      }
    }
    return Set<int>.unmodifiable(hiddenIds);
  }

  Set<String> _buildMatchFlashKeys({
    required List<StudyMatchTileModel> leftTiles,
    required List<StudyMatchTileModel> rightTiles,
    required bool Function(StudyMatchTileModel tile) selectByTile,
  }) {
    final Set<String> keys = <String>{};
    for (final StudyMatchTileModel tile in leftTiles) {
      if (selectByTile(tile)) {
        keys.add(
          _buildMatchTileFlashKey(isLeftTile: true, tileId: tile.tileId),
        );
      }
    }
    for (final StudyMatchTileModel tile in rightTiles) {
      if (selectByTile(tile)) {
        keys.add(
          _buildMatchTileFlashKey(isLeftTile: false, tileId: tile.tileId),
        );
      }
    }
    return Set<String>.unmodifiable(keys);
  }

  String _buildMatchTileFlashKey({
    required bool isLeftTile,
    required int tileId,
  }) {
    final String prefix = isLeftTile
        ? StudyConstants.matchTileFlashPrefixLeft
        : StudyConstants.matchTileFlashPrefixRight;
    return '$prefix$tileId';
  }

  int? _resolveSelectedTileId(List<StudyMatchTileModel> tiles) {
    for (final StudyMatchTileModel tile in tiles) {
      if (tile.selected) {
        return tile.tileId;
      }
    }
    return null;
  }

  MatchAttemptResult? _resolveMatchAttemptResult(
    StudyAttemptResultModel? attempt,
  ) {
    if (attempt == null) {
      return null;
    }
    final int? leftId = attempt.leftTileId;
    final int? rightId = attempt.rightTileId;
    if (leftId == null) {
      return null;
    }
    if (rightId == null) {
      return null;
    }
    if (attempt.isSuccess) {
      return MatchAttemptResult(
        leftId: leftId,
        rightId: rightId,
        type: MatchAttemptResultType.correct,
      );
    }
    if (attempt.isError) {
      return MatchAttemptResult(
        leftId: leftId,
        rightId: rightId,
        type: MatchAttemptResultType.wrong,
      );
    }
    return null;
  }

  String _buildClientEventId(StudySessionEventType eventType) {
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    return '${StudyConstants.defaultClientEventPrefix}.${eventType.apiValue}.$timestamp.$_clientSequence';
  }

  StudySessionState _buildBootstrapState(StudySessionArgs args) {
    final List<ReviewUnit> reviewUnits = args.items
        .map((item) {
          return ReviewUnit(
            unitId: item.id.toString(),
            flashcardId: item.id,
            frontText: item.frontText,
            backText: item.backText,
            note: item.note,
          );
        })
        .toList(growable: false);
    final List<StudyUnit> bootstrapUnits = _buildLinearUnits(
      mode: args.mode,
      reviewUnits: reviewUnits,
    );
    _linearUnits = bootstrapUnits;
    final int totalCount = bootstrapUnits.length;
    final int currentIndex = _resolveCurrentIndex(
      responseIndex: args.initialIndex,
      totalCount: totalCount,
    );
    final StudyUnit? currentUnit = _resolveCurrentLinearUnit(
      units: bootstrapUnits,
      currentIndex: currentIndex,
      isCompleted: false,
    );
    if (args.mode == StudyMode.match) {
      final MatchUnit matchUnit = _buildBootstrapMatchUnit(args);
      return StudySessionState.initial(
        mode: args.mode,
        reviewUnits: const <ReviewUnit>[],
        currentUnit: matchUnit,
        currentIndex: StudyConstants.defaultIndex,
        totalCount: matchUnit.leftEntries.length,
      );
    }
    final StudySessionState bootstrapState = StudySessionState.initial(
      mode: args.mode,
      reviewUnits: reviewUnits,
      currentUnit: currentUnit,
      currentIndex: currentIndex,
      totalCount: totalCount,
    );
    if (totalCount > StudyConstants.defaultIndex) {
      return bootstrapState;
    }
    return bootstrapState.copyWith(
      clearCurrentUnit: true,
      isCompleted: true,
      canGoNext: false,
      canGoPrevious: false,
    );
  }

  MatchUnit _buildBootstrapMatchUnit(StudySessionArgs args) {
    if (args.items.length < StudyConstants.minimumMatchPairCount) {
      return const MatchUnit(
        unitId: StudyConstants.matchBoardUnitId,
        leftEntries: <MatchEntry>[],
        rightEntries: <MatchEntry>[],
        matchedIds: <int>{},
        selectedLeftId: null,
        selectedRightId: null,
        lastAttemptResult: null,
      );
    }
    final List<MatchEntry> leftEntries = args.items
        .map((item) {
          return MatchEntry(id: item.id, label: item.frontText);
        })
        .toList(growable: false);
    final List<MatchEntry> rightEntries = args.items
        .map((item) {
          return MatchEntry(id: item.id, label: item.backText);
        })
        .toList(growable: false);
    final List<MatchEntry> shuffledLeft = _shuffledCopy(
      values: leftEntries,
      seed: args.seed + 1,
    );
    final List<MatchEntry> shuffledRight = _shuffledCopy(
      values: rightEntries,
      seed: args.seed + 2,
    );
    return MatchUnit(
      unitId: StudyConstants.matchBoardUnitId,
      leftEntries: shuffledLeft,
      rightEntries: shuffledRight,
      matchedIds: const <int>{},
      selectedLeftId: null,
      selectedRightId: null,
      lastAttemptResult: null,
    );
  }

  int _resolveCurrentIndex({
    required int responseIndex,
    required int totalCount,
  }) {
    if (totalCount <= StudyConstants.defaultIndex) {
      return StudyConstants.defaultIndex;
    }
    return responseIndex.clamp(StudyConstants.defaultIndex, totalCount - 1);
  }

  void _startAudioPlayingIndicator(int flashcardId) {
    _audioPlayingIndicatorTimer?.cancel();
    _playingFlashcardId = flashcardId;
    _audioPlayingIndicatorTimer = Timer(
      const Duration(
        milliseconds: StudyConstants.audioPlayingIndicatorDurationMs,
      ),
      _onAudioPlayingIndicatorExpired,
    );
  }

  void _clearAudioPlayingIndicator() {
    if (_playingFlashcardId == null) {
      return;
    }
    _playingFlashcardId = null;
  }

  void _onAudioPlayingIndicatorExpired() {
    _clearAudioPlayingIndicator();
    state = state.copyWith(clearPlayingFlashcardId: true);
  }

  void _resetControllerState() {
    _sessionId = null;
    _lastResponse = null;
    _linearUnits = const <StudyUnit>[];
    _isLinearCompleted = false;
    _isFrontVisible = true;
    _playingFlashcardId = null;
    _audioPlayingIndicatorTimer?.cancel();
    _localMatchFeedbackTimer?.cancel();
    _clientSequence = StudyConstants.defaultClientSequence;
    _submittedAnswerIndexes = <int>{};
    _localCorrectCount = StudyConstants.defaultIndex;
    _localWrongCount = StudyConstants.defaultIndex;
  }
}

bool _isLinearMode(StudyMode mode) {
  if (mode == StudyMode.match) {
    return false;
  }
  return true;
}

double _resolveProgressPercent({
  required int currentIndex,
  required int totalCount,
  required bool isCompleted,
}) {
  if (totalCount <= StudyConstants.defaultIndex) {
    return 0;
  }
  if (isCompleted) {
    return 1;
  }
  return currentIndex / totalCount;
}

bool _resolveCanGoPrevious({
  required int currentIndex,
  required int totalCount,
  required bool isCompleted,
}) {
  if (totalCount <= StudyConstants.defaultIndex) {
    return false;
  }
  if (isCompleted) {
    return true;
  }
  return currentIndex > StudyConstants.defaultIndex;
}

bool _resolveCanGoNext({required int totalCount, required bool isCompleted}) {
  if (totalCount <= StudyConstants.defaultIndex) {
    return false;
  }
  return !isCompleted;
}
