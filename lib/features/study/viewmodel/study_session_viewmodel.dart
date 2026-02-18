// quality-guard: allow-large-file
// quality-guard: allow-large-class
// quality-guard: allow-long-function
import 'dart:async';
import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/string_utils.dart';
import '../model/study_answer.dart';
import '../model/study_constants.dart';
import '../model/study_mode.dart';
import '../model/study_interaction_feedback_state.dart';
import '../model/study_session_args.dart';
import '../model/study_session_models.dart';
import '../model/study_unit.dart';
import '../repository/study_session_repository.dart';
import '../repository/study_session_repository_provider.dart';

part 'study_session_viewmodel.g.dart';
part 'study_session_viewmodel.freezed.dart';

@freezed
sealed class StudySessionCompletion with _$StudySessionCompletion {
  const StudySessionCompletion._();

  const factory StudySessionCompletion({
    required int completedModeCount,
    required int requiredModeCount,
    required bool isSessionCompleted,
  }) = _StudySessionCompletion;
}

@freezed
sealed class StudySessionMeta with _$StudySessionMeta {
  const StudySessionMeta._();

  const factory StudySessionMeta({
    required StudyMode mode,
    required List<ReviewUnit> reviewUnits,
    required StudyUnit? currentUnit,
    required StudySessionCompletion completion,
  }) = _StudySessionMeta;

  StudySessionMeta patch({
    StudyMode? mode,
    List<ReviewUnit>? reviewUnits,
    StudyUnit? currentUnit,
    bool clearCurrentUnit = false,
    StudySessionCompletion? completion,
  }) {
    final StudyUnit? nextCurrentUnit = clearCurrentUnit
        ? null
        : (currentUnit ?? this.currentUnit);
    return copyWith(
      mode: mode ?? this.mode,
      reviewUnits: reviewUnits ?? this.reviewUnits,
      currentUnit: nextCurrentUnit,
      completion: completion ?? this.completion,
    );
  }
}

@freezed
sealed class StudySessionProgress with _$StudySessionProgress {
  const StudySessionProgress._();

  const factory StudySessionProgress({
    required int currentIndex,
    required int totalCount,
    required double progressPercent,
    required bool isCompleted,
  }) = _StudySessionProgress;
}

@freezed
sealed class StudySessionNavigation with _$StudySessionNavigation {
  const StudySessionNavigation._();

  const factory StudySessionNavigation({
    required bool canGoPrevious,
    required bool canGoNext,
  }) = _StudySessionNavigation;
}

@freezed
sealed class StudySessionStatistics with _$StudySessionStatistics {
  const StudySessionStatistics._();

  const factory StudySessionStatistics({
    required int correctCount,
    required int wrongCount,
  }) = _StudySessionStatistics;
}

@freezed
sealed class StudySessionRuntime with _$StudySessionRuntime {
  const StudySessionRuntime._();

  const factory StudySessionRuntime({
    required StudySessionProgress progress,
    required StudySessionNavigation navigation,
    required StudySessionStatistics statistics,
    required bool isFrontVisible,
    required int? playingFlashcardId,
  }) = _StudySessionRuntime;

  StudySessionRuntime patch({
    StudySessionProgress? progress,
    StudySessionNavigation? navigation,
    StudySessionStatistics? statistics,
    bool? isFrontVisible,
    int? playingFlashcardId,
    bool clearPlayingFlashcardId = false,
  }) {
    final int? nextPlayingFlashcardId = clearPlayingFlashcardId
        ? null
        : (playingFlashcardId ?? this.playingFlashcardId);
    return copyWith(
      progress: progress ?? this.progress,
      navigation: navigation ?? this.navigation,
      statistics: statistics ?? this.statistics,
      isFrontVisible: isFrontVisible ?? this.isFrontVisible,
      playingFlashcardId: nextPlayingFlashcardId,
    );
  }
}

@freezed
sealed class StudySessionGuessInteraction with _$StudySessionGuessInteraction {
  const StudySessionGuessInteraction._();

  const factory StudySessionGuessInteraction({
    required Set<String> successOptionIds,
    required Set<String> errorOptionIds,
    required bool isLocked,
  }) = _StudySessionGuessInteraction;
}

@freezed
sealed class StudySessionMatchInteraction with _$StudySessionMatchInteraction {
  const StudySessionMatchInteraction._();

  const factory StudySessionMatchInteraction({
    required Set<int> hiddenIds,
    required Set<String> successFlashKeys,
    required Set<String> errorFlashKeys,
    required bool isLocked,
  }) = _StudySessionMatchInteraction;
}

@freezed
sealed class StudySessionInteractions with _$StudySessionInteractions {
  const StudySessionInteractions._();

  const factory StudySessionInteractions({
    required StudySessionGuessInteraction guess,
    required StudySessionMatchInteraction match,
  }) = _StudySessionInteractions;
}

@Freezed(copyWith: false)
sealed class StudySessionState with _$StudySessionState {
  const StudySessionState._();

  const factory StudySessionState({
    required StudySessionMeta meta,
    required StudySessionRuntime runtime,
    required StudySessionInteractions interactions,
  }) = _StudySessionState;

  StudyMode get mode => meta.mode;
  List<ReviewUnit> get reviewUnits => meta.reviewUnits;
  StudyUnit? get currentUnit => meta.currentUnit;

  int get currentIndex => runtime.progress.currentIndex;
  int get totalCount => runtime.progress.totalCount;
  double get progressPercent => runtime.progress.progressPercent;
  bool get isCompleted => runtime.progress.isCompleted;

  bool get canGoPrevious => runtime.navigation.canGoPrevious;
  bool get canGoNext => runtime.navigation.canGoNext;

  int get correctCount => runtime.statistics.correctCount;
  int get wrongCount => runtime.statistics.wrongCount;
  bool get isFrontVisible => runtime.isFrontVisible;
  int? get playingFlashcardId => runtime.playingFlashcardId;

  int get completedModeCount => meta.completion.completedModeCount;
  int get requiredModeCount => meta.completion.requiredModeCount;
  bool get isSessionCompleted => meta.completion.isSessionCompleted;

  Set<int> get matchHiddenIds => interactions.match.hiddenIds;
  Set<String> get matchSuccessFlashKeys => interactions.match.successFlashKeys;
  Set<String> get matchErrorFlashKeys => interactions.match.errorFlashKeys;
  bool get isMatchInteractionLocked => interactions.match.isLocked;

  Set<String> get guessSuccessOptionIds => interactions.guess.successOptionIds;
  Set<String> get guessErrorOptionIds => interactions.guess.errorOptionIds;
  bool get isGuessInteractionLocked => interactions.guess.isLocked;

  StudyInteractionFeedbackState<String> get matchInteractionFeedback {
    return StudyInteractionFeedbackState<String>(
      successIds: matchSuccessFlashKeys,
      errorIds: matchErrorFlashKeys,
      isLocked: isMatchInteractionLocked,
    );
  }

  StudyInteractionFeedbackState<String> get guessInteractionFeedback {
    return StudyInteractionFeedbackState<String>(
      successIds: guessSuccessOptionIds,
      errorIds: guessErrorOptionIds,
      isLocked: isGuessInteractionLocked,
    );
  }

  factory StudySessionState.initial({
    required StudyMode mode,
    required List<ReviewUnit> reviewUnits,
    required StudyUnit? currentUnit,
    required int currentIndex,
    required int totalCount,
  }) {
    return StudySessionState(
      meta: StudySessionMeta(
        mode: mode,
        reviewUnits: List<ReviewUnit>.unmodifiable(reviewUnits),
        currentUnit: currentUnit,
        completion: const StudySessionCompletion(
          completedModeCount: StudyConstants.defaultIndex,
          requiredModeCount: StudyConstants.requiredStudyModeCount,
          isSessionCompleted: false,
        ),
      ),
      runtime: StudySessionRuntime(
        progress: StudySessionProgress(
          currentIndex: currentIndex,
          totalCount: totalCount,
          progressPercent: _resolveProgressPercent(
            currentIndex: currentIndex,
            totalCount: totalCount,
            isCompleted: false,
          ),
          isCompleted: false,
        ),
        navigation: StudySessionNavigation(
          canGoPrevious: currentIndex > StudyConstants.defaultIndex,
          canGoNext: totalCount > StudyConstants.defaultIndex,
        ),
        statistics: const StudySessionStatistics(
          correctCount: 0,
          wrongCount: 0,
        ),
        isFrontVisible: true,
        playingFlashcardId: null,
      ),
      interactions: StudySessionInteractions(
        guess: StudySessionGuessInteraction(
          successOptionIds: const <String>{},
          errorOptionIds: const <String>{},
          isLocked: false,
        ),
        match: StudySessionMatchInteraction(
          hiddenIds: const <int>{},
          successFlashKeys: const <String>{},
          errorFlashKeys: const <String>{},
          isLocked: false,
        ),
      ),
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
    int? completedModeCount,
    int? requiredModeCount,
    bool? isSessionCompleted,
    Set<int>? matchHiddenIds,
    Set<String>? matchSuccessFlashKeys,
    Set<String>? matchErrorFlashKeys,
    bool? isMatchInteractionLocked,
    Set<String>? guessSuccessOptionIds,
    Set<String>? guessErrorOptionIds,
    bool? isGuessInteractionLocked,
  }) {
    final StudySessionCompletion nextCompletion = meta.completion.copyWith(
      completedModeCount:
          completedModeCount ?? meta.completion.completedModeCount,
      requiredModeCount: requiredModeCount ?? meta.completion.requiredModeCount,
      isSessionCompleted:
          isSessionCompleted ?? meta.completion.isSessionCompleted,
    );
    final StudySessionMeta nextMeta = meta.patch(
      mode: mode,
      reviewUnits: reviewUnits,
      currentUnit: currentUnit,
      clearCurrentUnit: clearCurrentUnit,
      completion: nextCompletion,
    );

    final StudySessionProgress nextProgress = runtime.progress.copyWith(
      currentIndex: currentIndex ?? runtime.progress.currentIndex,
      totalCount: totalCount ?? runtime.progress.totalCount,
      progressPercent: progressPercent ?? runtime.progress.progressPercent,
      isCompleted: isCompleted ?? runtime.progress.isCompleted,
    );
    final StudySessionNavigation nextNavigation = runtime.navigation.copyWith(
      canGoPrevious: canGoPrevious ?? runtime.navigation.canGoPrevious,
      canGoNext: canGoNext ?? runtime.navigation.canGoNext,
    );
    final StudySessionStatistics nextStatistics = runtime.statistics.copyWith(
      correctCount: correctCount ?? runtime.statistics.correctCount,
      wrongCount: wrongCount ?? runtime.statistics.wrongCount,
    );
    final StudySessionRuntime nextRuntime = runtime.patch(
      progress: nextProgress,
      navigation: nextNavigation,
      statistics: nextStatistics,
      isFrontVisible: isFrontVisible,
      playingFlashcardId: playingFlashcardId,
      clearPlayingFlashcardId: clearPlayingFlashcardId,
    );

    final StudySessionGuessInteraction nextGuess = interactions.guess.copyWith(
      successOptionIds:
          guessSuccessOptionIds ?? interactions.guess.successOptionIds,
      errorOptionIds: guessErrorOptionIds ?? interactions.guess.errorOptionIds,
      isLocked: isGuessInteractionLocked ?? interactions.guess.isLocked,
    );
    final StudySessionMatchInteraction nextMatch = interactions.match.copyWith(
      hiddenIds: matchHiddenIds ?? interactions.match.hiddenIds,
      successFlashKeys:
          matchSuccessFlashKeys ?? interactions.match.successFlashKeys,
      errorFlashKeys: matchErrorFlashKeys ?? interactions.match.errorFlashKeys,
      isLocked: isMatchInteractionLocked ?? interactions.match.isLocked,
    );
    final StudySessionInteractions nextInteractions = interactions.copyWith(
      guess: nextGuess,
      match: nextMatch,
    );

    return StudySessionState(
      meta: nextMeta,
      runtime: nextRuntime,
      interactions: nextInteractions,
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
  Timer? _localGuessFeedbackTimer;
  Timer? _localMatchFeedbackTimer;
  Timer? _remoteMatchFeedbackReleaseTimer;
  int? _remoteMatchFeedbackUntilEpochMs;
  Future<void>? _modeCompletionFuture;
  bool _isMatchModeCompletionSynced = false;
  int _clientSequence = StudyConstants.defaultClientSequence;
  Set<int> _submittedAnswerIndexes = <int>{};
  int _localCorrectCount = StudyConstants.defaultIndex;
  int _localWrongCount = StudyConstants.defaultIndex;
  bool _hasLocalRecallProgress = false;
  List<RecallUnit> _recallWaitingUnits = <RecallUnit>[];
  Set<String> _guessSuccessOptionIds = <String>{};
  Set<String> _guessErrorOptionIds = <String>{};
  bool _isGuessInteractionLocked = false;

  @override
  StudySessionState build(StudySessionArgs args) {
    _repository = ref.read(studySessionRepositoryProvider);
    _args = args;
    _resetControllerState();
    ref.onDispose(() {
      _audioPlayingIndicatorTimer?.cancel();
      _localGuessFeedbackTimer?.cancel();
      _localMatchFeedbackTimer?.cancel();
      _remoteMatchFeedbackReleaseTimer?.cancel();
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

  void submitGuessOption(String optionId) {
    final StudyUnit? currentUnit = state.currentUnit;
    if (currentUnit is! GuessUnit) {
      return;
    }
    if (state.isCompleted) {
      return;
    }
    if (_isGuessInteractionLocked) {
      return;
    }
    final bool isCorrect = optionId == currentUnit.correctOptionId;
    submitAnswer(GuessStudyAnswer(optionId: optionId));
    _startLocalGuessFeedback(
      selectedOptionId: optionId,
      correctOptionId: currentUnit.correctOptionId,
      isCorrect: isCorrect,
    );
  }

  void submitRecallEvaluation({required bool isRemembered}) {
    if (state.mode != StudyMode.recall) {
      return;
    }
    final StudyUnit? currentUnit = state.currentUnit;
    if (currentUnit is! RecallUnit) {
      return;
    }
    if (state.isCompleted) {
      return;
    }
    _hasLocalRecallProgress = true;
    submitAnswer(RecallStudyAnswer(isRemembered: isRemembered));
    if (!isRemembered) {
      _enqueueRecallUnitForRetry(currentUnit);
    }
    _advanceRecallFlow();
  }

  void submitFillAnswer(String answer) {
    if (state.mode != StudyMode.fill) {
      return;
    }
    if (state.isCompleted) {
      return;
    }
    final StudyUnit? currentUnit = state.currentUnit;
    if (currentUnit is! FillUnit) {
      return;
    }
    final bool isCorrect = _isFillAnswerCorrect(
      actual: answer,
      expected: currentUnit.expectedAnswer,
    );
    submitAnswer(FillStudyAnswer(text: answer));
    if (!isCorrect) {
      return;
    }
    next();
  }

  void _enqueueRecallUnitForRetry(RecallUnit unit) {
    final List<RecallUnit> nextWaitingUnits = List<RecallUnit>.from(
      _recallWaitingUnits,
    )..add(unit);
    _recallWaitingUnits = List<RecallUnit>.unmodifiable(nextWaitingUnits);
  }

  void _appendRecallWaitingUnitsToLinearUnits() {
    if (_recallWaitingUnits.isEmpty) {
      return;
    }
    final List<StudyUnit> nextUnits = List<StudyUnit>.from(_linearUnits)
      ..addAll(_recallWaitingUnits);
    _linearUnits = List<StudyUnit>.unmodifiable(nextUnits);
    _recallWaitingUnits = const <RecallUnit>[];
  }

  void _advanceRecallFlow() {
    final int currentTotalCount = _linearUnits.length;
    if (currentTotalCount <= StudyConstants.defaultIndex) {
      _isLinearCompleted = true;
      _clearAudioPlayingIndicator();
      _syncLocalLinearState();
      return;
    }
    final int nextIndex = state.currentIndex + 1;
    if (nextIndex >= currentTotalCount) {
      if (_recallWaitingUnits.isEmpty) {
        _isLinearCompleted = true;
        _clearAudioPlayingIndicator();
        _syncLocalLinearState();
        unawaited(completeCurrentMode());
        return;
      }
      _appendRecallWaitingUnitsToLinearUnits();
    }
    final int nextTotalCount = _linearUnits.length;
    if (nextIndex >= nextTotalCount) {
      _isLinearCompleted = true;
      _clearAudioPlayingIndicator();
      _syncLocalLinearState();
      unawaited(completeCurrentMode());
      return;
    }
    _isFrontVisible = true;
    _isLinearCompleted = false;
    _clearAudioPlayingIndicator();
    _moveLinearLocallyTo(nextIndex);
  }

  void _startLocalGuessFeedback({
    required String selectedOptionId,
    required String correctOptionId,
    required bool isCorrect,
  }) {
    _localGuessFeedbackTimer?.cancel();
    _isGuessInteractionLocked = true;
    final Set<String> successOptionIds = _resolveGuessFeedbackSuccessOptionIds(
      selectedOptionId: selectedOptionId,
      isCorrect: isCorrect,
    );
    final Set<String> errorOptionIds = _resolveGuessFeedbackErrorOptionIds(
      selectedOptionId: selectedOptionId,
      isCorrect: isCorrect,
    );
    _guessSuccessOptionIds = successOptionIds;
    _guessErrorOptionIds = errorOptionIds;
    state = state.copyWith(
      guessSuccessOptionIds: successOptionIds,
      guessErrorOptionIds: errorOptionIds,
      isGuessInteractionLocked: true,
    );
    _localGuessFeedbackTimer = Timer(
      const Duration(milliseconds: StudyConstants.localGuessFeedbackDurationMs),
      () => _releaseGuessFeedback(isCorrect: isCorrect),
    );
  }

  Set<String> _resolveGuessFeedbackSuccessOptionIds({
    required String selectedOptionId,
    required bool isCorrect,
  }) {
    if (isCorrect) {
      return <String>{selectedOptionId};
    }
    return <String>{};
  }

  Set<String> _resolveGuessFeedbackErrorOptionIds({
    required String selectedOptionId,
    required bool isCorrect,
  }) {
    if (isCorrect) {
      return <String>{};
    }
    return <String>{selectedOptionId};
  }

  void _releaseGuessFeedback({required bool isCorrect}) {
    if (!ref.mounted) {
      return;
    }
    _clearGuessFeedbackState();
    if (!isCorrect) {
      return;
    }
    next();
  }

  void _clearGuessFeedbackState() {
    _resetGuessFeedbackLocalState();
    state = state.copyWith(
      guessSuccessOptionIds: const <String>{},
      guessErrorOptionIds: const <String>{},
      isGuessInteractionLocked: false,
    );
  }

  void _resetGuessFeedbackLocalState() {
    _localGuessFeedbackTimer?.cancel();
    _localGuessFeedbackTimer = null;
    _isGuessInteractionLocked = false;
    _guessSuccessOptionIds = <String>{};
    _guessErrorOptionIds = <String>{};
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
      unawaited(completeCurrentMode());
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
    final int totalCount = _linearUnits.length;
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

  Future<void> completeCurrentMode() async {
    final Future<void>? pendingCompletion = _modeCompletionFuture;
    if (pendingCompletion != null) {
      await pendingCompletion;
      return;
    }
    final Future<void> completionTask = _completeCurrentModeInternal();
    _modeCompletionFuture = completionTask;
    try {
      await completionTask;
    } finally {
      _modeCompletionFuture = null;
    }
  }

  Future<void> _completeCurrentModeInternal() async {
    final int? sessionId = _sessionId;
    if (sessionId == null) {
      return;
    }
    try {
      final StudySessionResponseModel response = await _repository
          .completeSession(sessionId: sessionId);
      if (!ref.mounted) {
        return;
      }
      _lastResponse = response;
      _syncFromSnapshot();
    } catch (_) {}
  }

  Future<void> _startSessionFromBackend() async {
    if (_args.deckId <= StudyConstants.defaultIndex) {
      return;
    }
    try {
      final StudySessionResponseModel response = await _repository.startSession(
        deckId: _args.deckId,
        request: StudySessionStartRequest(
          mode: _args.mode,
          seed: _args.seed,
          forceReset: _args.forceReset,
        ),
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
    final bool shouldDelayProgressUpdate = successFlashKeys.isNotEmpty;
    final int displayCurrentIndex = _resolveMatchDisplayCurrentIndex(
      currentIndex: currentIndex,
      shouldDelayProgressUpdate: shouldDelayProgressUpdate,
    );
    final bool isCompleted =
        totalCount > 0 && displayCurrentIndex >= totalCount;
    state = state.copyWith(
      currentUnit: updatedUnit,
      currentIndex: displayCurrentIndex,
      totalCount: totalCount,
      progressPercent: _resolveProgressPercent(
        currentIndex: displayCurrentIndex,
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      correctCount: _localCorrectCount,
      wrongCount: _localWrongCount,
      canGoPrevious: _resolveCanGoPrevious(
        currentIndex: displayCurrentIndex,
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
    final String normalizedActual = StringUtils.normalizeLower(actual);
    final String normalizedExpected = StringUtils.normalizeLower(expected);
    if (normalizedActual.isEmpty) {
      return false;
    }
    return normalizedActual == normalizedExpected;
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
    if (_shouldSkipRecallSnapshotSync(snapshot)) {
      return;
    }
    _syncMatchFeedbackRelease(snapshot);
    _syncMatchModeCompletion(snapshot);
    state = _mapResponseToState(snapshot);
  }

  bool _shouldSkipRecallSnapshotSync(StudySessionResponseModel snapshot) {
    if (snapshot.mode != StudyMode.recall) {
      return false;
    }
    if (!_hasLocalRecallProgress) {
      return false;
    }
    if (snapshot.completed) {
      return false;
    }
    return true;
  }

  void _syncMatchFeedbackRelease(StudySessionResponseModel snapshot) {
    if (snapshot.mode != StudyMode.match) {
      _clearRemoteMatchFeedbackReleaseTimer();
      return;
    }
    final StudyAttemptResultModel? lastAttempt = snapshot.lastAttemptResult;
    if (lastAttempt == null) {
      _clearRemoteMatchFeedbackReleaseTimer();
      return;
    }
    if (!lastAttempt.interactionLocked) {
      _clearRemoteMatchFeedbackReleaseTimer();
      return;
    }
    final DateTime? feedbackUntil = lastAttempt.feedbackUntil;
    if (feedbackUntil == null) {
      _scheduleRemoteMatchFeedbackRelease(
        dueEpochMs:
            DateTime.now().millisecondsSinceEpoch +
            StudyConstants.matchFeedbackUnlockFallbackMs,
      );
      return;
    }
    _scheduleRemoteMatchFeedbackRelease(
      dueEpochMs:
          feedbackUntil.millisecondsSinceEpoch +
          StudyConstants.matchFeedbackUnlockSkewMs,
    );
  }

  void _scheduleRemoteMatchFeedbackRelease({required int dueEpochMs}) {
    final Timer? existingTimer = _remoteMatchFeedbackReleaseTimer;
    final bool hasSameSchedule =
        _remoteMatchFeedbackUntilEpochMs == dueEpochMs &&
        existingTimer != null &&
        existingTimer.isActive;
    if (hasSameSchedule) {
      return;
    }
    _remoteMatchFeedbackReleaseTimer?.cancel();
    _remoteMatchFeedbackUntilEpochMs = dueEpochMs;
    final int nowEpochMs = DateTime.now().millisecondsSinceEpoch;
    final int delayMs = max(1, dueEpochMs - nowEpochMs);
    _remoteMatchFeedbackReleaseTimer = Timer(
      Duration(milliseconds: delayMs),
      _refreshSessionAfterMatchFeedbackRelease,
    );
  }

  Future<void> _refreshSessionAfterMatchFeedbackRelease() async {
    _remoteMatchFeedbackReleaseTimer = null;
    _remoteMatchFeedbackUntilEpochMs = null;
    final int? sessionId = _sessionId;
    if (sessionId == null) {
      return;
    }
    try {
      final StudySessionResponseModel response = await _repository.getSession(
        sessionId: sessionId,
      );
      if (!ref.mounted) {
        return;
      }
      _lastResponse = response;
      _syncFromSnapshot();
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      _scheduleRemoteMatchFeedbackRelease(
        dueEpochMs:
            DateTime.now().millisecondsSinceEpoch +
            StudyConstants.matchFeedbackUnlockFallbackMs,
      );
    }
  }

  void _clearRemoteMatchFeedbackReleaseTimer() {
    _remoteMatchFeedbackReleaseTimer?.cancel();
    _remoteMatchFeedbackReleaseTimer = null;
    _remoteMatchFeedbackUntilEpochMs = null;
  }

  void _syncMatchModeCompletion(StudySessionResponseModel snapshot) {
    if (snapshot.mode != StudyMode.match) {
      _isMatchModeCompletionSynced = false;
      return;
    }
    if (!snapshot.completed) {
      _isMatchModeCompletionSynced = false;
      return;
    }
    if (snapshot.sessionCompleted) {
      return;
    }
    if (_isMatchModeCompletionSynced) {
      return;
    }
    _isMatchModeCompletionSynced = true;
    unawaited(completeCurrentMode());
  }

  void _syncLocalLinearState() {
    if (!_isLinearMode(state.mode)) {
      return;
    }
    final int totalCount = _linearUnits.length;
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
        guessSuccessOptionIds: _resolveGuessSuccessOptionIds(mode: state.mode),
        guessErrorOptionIds: _resolveGuessErrorOptionIds(mode: state.mode),
        isGuessInteractionLocked: _resolveGuessInteractionLocked(
          mode: state.mode,
        ),
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
      guessSuccessOptionIds: _resolveGuessSuccessOptionIds(mode: state.mode),
      guessErrorOptionIds: _resolveGuessErrorOptionIds(mode: state.mode),
      isGuessInteractionLocked: _resolveGuessInteractionLocked(
        mode: state.mode,
      ),
    );
  }

  StudySessionState _mapResponseToState(StudySessionResponseModel response) {
    if (response.mode != StudyMode.guess) {
      _resetGuessFeedbackLocalState();
    }
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
    final Set<String> guessSuccessOptionIds = _resolveGuessSuccessOptionIds(
      mode: response.mode,
    );
    final Set<String> guessErrorOptionIds = _resolveGuessErrorOptionIds(
      mode: response.mode,
    );
    final bool isGuessInteractionLocked = _resolveGuessInteractionLocked(
      mode: response.mode,
    );
    return StudySessionState(
      meta: StudySessionMeta(
        mode: response.mode,
        reviewUnits: List<ReviewUnit>.unmodifiable(reviewUnits),
        currentUnit: currentUnit,
        completion: StudySessionCompletion(
          completedModeCount: response.completedModeCount,
          requiredModeCount: response.requiredModeCount,
          isSessionCompleted: response.sessionCompleted,
        ),
      ),
      runtime: StudySessionRuntime(
        progress: StudySessionProgress(
          currentIndex: currentIndex,
          totalCount: totalCount,
          progressPercent: _resolveProgressPercent(
            currentIndex: currentIndex,
            totalCount: totalCount,
            isCompleted: isCompleted,
          ),
          isCompleted: isCompleted,
        ),
        navigation: StudySessionNavigation(
          canGoPrevious: _resolveCanGoPrevious(
            currentIndex: currentIndex,
            totalCount: totalCount,
            isCompleted: isCompleted,
          ),
          canGoNext: _resolveCanGoNext(
            totalCount: totalCount,
            isCompleted: isCompleted,
          ),
        ),
        statistics: StudySessionStatistics(
          correctCount: correctCount,
          wrongCount: wrongCount,
        ),
        isFrontVisible: _isFrontVisible,
        playingFlashcardId: _playingFlashcardId,
      ),
      interactions: StudySessionInteractions(
        guess: StudySessionGuessInteraction(
          successOptionIds: guessSuccessOptionIds,
          errorOptionIds: guessErrorOptionIds,
          isLocked: isGuessInteractionLocked,
        ),
        match: StudySessionMatchInteraction(
          hiddenIds: const <int>{},
          successFlashKeys: const <String>{},
          errorFlashKeys: const <String>{},
          isLocked: false,
        ),
      ),
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
    final bool shouldDelayProgressUpdate =
        isInteractionLocked && successFlashKeys.isNotEmpty;
    final int displayCurrentIndex = _resolveMatchDisplayCurrentIndex(
      currentIndex: response.currentIndex,
      shouldDelayProgressUpdate: shouldDelayProgressUpdate,
    );
    final bool isCompleted = response.completed && !shouldDelayProgressUpdate;
    return StudySessionState(
      meta: StudySessionMeta(
        mode: response.mode,
        reviewUnits: const <ReviewUnit>[],
        currentUnit: matchUnit,
        completion: StudySessionCompletion(
          completedModeCount: response.completedModeCount,
          requiredModeCount: response.requiredModeCount,
          isSessionCompleted: response.sessionCompleted,
        ),
      ),
      runtime: StudySessionRuntime(
        progress: StudySessionProgress(
          currentIndex: _resolveCurrentIndex(
            responseIndex: displayCurrentIndex,
            totalCount: response.totalUnits,
          ),
          totalCount: response.totalUnits,
          progressPercent: _resolveProgressPercent(
            currentIndex: displayCurrentIndex,
            totalCount: response.totalUnits,
            isCompleted: isCompleted,
          ),
          isCompleted: isCompleted,
        ),
        navigation: StudySessionNavigation(
          canGoPrevious: _resolveCanGoPrevious(
            currentIndex: displayCurrentIndex,
            totalCount: response.totalUnits,
            isCompleted: isCompleted,
          ),
          canGoNext: _resolveCanGoNext(
            totalCount: response.totalUnits,
            isCompleted: isCompleted,
          ),
        ),
        statistics: StudySessionStatistics(
          correctCount: response.correctCount,
          wrongCount: response.wrongCount,
        ),
        isFrontVisible: _isFrontVisible,
        playingFlashcardId: _playingFlashcardId,
      ),
      interactions: StudySessionInteractions(
        guess: StudySessionGuessInteraction(
          successOptionIds: const <String>{},
          errorOptionIds: const <String>{},
          isLocked: false,
        ),
        match: StudySessionMatchInteraction(
          hiddenIds: hiddenIds,
          successFlashKeys: successFlashKeys,
          errorFlashKeys: errorFlashKeys,
          isLocked: isInteractionLocked,
        ),
      ),
    );
  }

  int _resolveMatchDisplayCurrentIndex({
    required int currentIndex,
    required bool shouldDelayProgressUpdate,
  }) {
    if (!shouldDelayProgressUpdate) {
      return currentIndex;
    }
    return max(StudyConstants.defaultIndex, currentIndex - 1);
  }

  Set<String> _resolveGuessSuccessOptionIds({required StudyMode mode}) {
    if (mode != StudyMode.guess) {
      return const <String>{};
    }
    return Set<String>.unmodifiable(_guessSuccessOptionIds);
  }

  Set<String> _resolveGuessErrorOptionIds({required StudyMode mode}) {
    if (mode != StudyMode.guess) {
      return const <String>{};
    }
    return Set<String>.unmodifiable(_guessErrorOptionIds);
  }

  bool _resolveGuessInteractionLocked({required StudyMode mode}) {
    if (mode != StudyMode.guess) {
      return false;
    }
    return _isGuessInteractionLocked;
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
              prompt: unit.backText,
              expectedAnswer: unit.frontText,
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
    if (args.deckId > StudyConstants.defaultIndex) {
      return _buildBackendBootstrapState(args);
    }
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

  StudySessionState _buildBackendBootstrapState(StudySessionArgs args) {
    _linearUnits = const <StudyUnit>[];
    return StudySessionState.initial(
      mode: args.mode,
      reviewUnits: const <ReviewUnit>[],
      currentUnit: null,
      currentIndex: StudyConstants.defaultIndex,
      totalCount: StudyConstants.defaultIndex,
    ).copyWith(
      clearCurrentUnit: true,
      isCompleted: false,
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
    _resetGuessFeedbackLocalState();
    _localMatchFeedbackTimer?.cancel();
    _clearRemoteMatchFeedbackReleaseTimer();
    _modeCompletionFuture = null;
    _isMatchModeCompletionSynced = false;
    _clientSequence = StudyConstants.defaultClientSequence;
    _submittedAnswerIndexes = <int>{};
    _localCorrectCount = StudyConstants.defaultIndex;
    _localWrongCount = StudyConstants.defaultIndex;
    _hasLocalRecallProgress = false;
    _recallWaitingUnits = <RecallUnit>[];
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
