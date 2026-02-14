import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../common/styles/app_durations.dart';
import '../engine/study_engine.dart';
import '../engine/study_engine_factory.dart';
import '../model/study_answer.dart';
import '../model/study_constants.dart';
import '../model/study_mode.dart';
import '../model/study_session_args.dart';
import '../model/study_unit.dart';

part 'study_session_viewmodel.g.dart';

class StudySessionState {
  const StudySessionState({
    required this.mode,
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

  factory StudySessionState.fromEngine({
    required StudyMode mode,
    required StudyEngine engine,
    required bool isFrontVisible,
    required int? playingFlashcardId,
    Set<int> matchHiddenIds = const <int>{},
    Set<String> matchSuccessFlashKeys = const <String>{},
    Set<String> matchErrorFlashKeys = const <String>{},
    bool isMatchInteractionLocked = false,
  }) {
    final int currentIndex = _resolveCurrentIndex(engine: engine);
    final int totalCount = engine.totalUnits;
    final bool isCompleted = engine.isCompleted;
    return StudySessionState(
      mode: mode,
      currentUnit: engine.currentUnit,
      currentIndex: currentIndex,
      totalCount: totalCount,
      progressPercent: _resolveProgressPercent(
        currentIndex: currentIndex,
        totalCount: totalCount,
        isCompleted: isCompleted,
      ),
      isFrontVisible: isFrontVisible,
      playingFlashcardId: playingFlashcardId,
      correctCount: engine.correctCount,
      wrongCount: engine.wrongCount,
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
      matchHiddenIds: Set<int>.unmodifiable(matchHiddenIds),
      matchSuccessFlashKeys: Set<String>.unmodifiable(matchSuccessFlashKeys),
      matchErrorFlashKeys: Set<String>.unmodifiable(matchErrorFlashKeys),
      isMatchInteractionLocked: isMatchInteractionLocked,
    );
  }

  StudySessionState copyWith({
    StudyMode? mode,
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
      matchHiddenIds: Set<int>.unmodifiable(matchHiddenIds ?? this.matchHiddenIds),
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

  static int _resolveCurrentIndex({required StudyEngine engine}) {
    final int totalCount = engine.totalUnits;
    if (totalCount <= StudyConstants.defaultIndex) {
      return StudyConstants.defaultIndex;
    }
    if (engine.isCompleted) {
      return totalCount - 1;
    }
    return engine.currentIndex.clamp(StudyConstants.defaultIndex, totalCount - 1);
  }

  static double _resolveProgressPercent({
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

  static bool _resolveCanGoPrevious({
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

  static bool _resolveCanGoNext({
    required int totalCount,
    required bool isCompleted,
  }) {
    if (totalCount <= StudyConstants.defaultIndex) {
      return false;
    }
    return !isCompleted;
  }
}

@Riverpod(keepAlive: true)
StudyEngineFactory studyEngineFactory(Ref ref) {
  return StudyEngineFactory();
}

@Riverpod(keepAlive: true)
class StudySessionController extends _$StudySessionController {
  late StudyEngine _engine;
  bool _isFrontVisible = true;
  int? _playingFlashcardId;
  Timer? _audioPlayingIndicatorTimer;
  Timer? _matchFeedbackTimer;
  int _matchFeedbackToken = StudyConstants.defaultIndex;
  Set<int> _matchHiddenIds = <int>{};
  Set<String> _matchSuccessFlashKeys = <String>{};
  Set<String> _matchErrorFlashKeys = <String>{};
  bool _isMatchInteractionLocked = false;

  @override
  StudySessionState build(StudySessionArgs args) {
    ref.onDispose(() {
      _audioPlayingIndicatorTimer?.cancel();
      _matchFeedbackTimer?.cancel();
    });
    final StudyEngineFactory factory = ref.read(studyEngineFactoryProvider);
    _engine = factory.create(
      StudyEngineRequest(
        mode: args.mode,
        items: args.items,
        initialIndex: args.initialIndex,
        random: Random(args.seed),
      ),
    );
    _isFrontVisible = true;
    _playingFlashcardId = null;
    _resetMatchPresentationState();
    return StudySessionState.fromEngine(
      mode: args.mode,
      engine: _engine,
      isFrontVisible: _isFrontVisible,
      playingFlashcardId: _playingFlashcardId,
      matchHiddenIds: _matchHiddenIds,
      matchSuccessFlashKeys: _matchSuccessFlashKeys,
      matchErrorFlashKeys: _matchErrorFlashKeys,
      isMatchInteractionLocked: _isMatchInteractionLocked,
    );
  }

  void submitAnswer(StudyAnswer answer) {
    if (_isMatchInteractionLocked && _isMatchAnswer(answer)) {
      return;
    }
    _engine.submitAnswer(answer);
    _handleMatchAttemptResult();
    _sync();
  }

  void next() {
    _engine.next();
    _isFrontVisible = true;
    _clearAudioPlayingIndicator();
    _sync();
  }

  void previous() {
    _engine.previous();
    _isFrontVisible = true;
    _clearAudioPlayingIndicator();
    _sync();
  }

  void goTo(int index) {
    _engine.goTo(index);
    _isFrontVisible = true;
    _clearAudioPlayingIndicator();
    _sync();
  }

  void submitFlip() {
    final StudyUnit? currentUnit = _engine.currentUnit;
    if (currentUnit is! ReviewUnit) {
      return;
    }
    _isFrontVisible = !_isFrontVisible;
    _sync();
  }

  void playCurrentAudio() {
    final StudyUnit? currentUnit = _engine.currentUnit;
    if (currentUnit is! ReviewUnit) {
      return;
    }
    _startAudioPlayingIndicator(currentUnit.flashcardId);
    _sync();
  }

  void playAudioFor(int flashcardId) {
    final StudyUnit? currentUnit = _engine.currentUnit;
    if (currentUnit is! ReviewUnit) {
      return;
    }
    _startAudioPlayingIndicator(flashcardId);
    _sync();
  }

  void clearAudioPlaying() {
    _clearAudioPlayingIndicator();
    _sync();
  }

  void restart() {
    ref.invalidateSelf();
  }

  void _sync() {
    state = StudySessionState.fromEngine(
      mode: _engine.mode,
      engine: _engine,
      isFrontVisible: _isFrontVisible,
      playingFlashcardId: _playingFlashcardId,
      matchHiddenIds: _matchHiddenIds,
      matchSuccessFlashKeys: _matchSuccessFlashKeys,
      matchErrorFlashKeys: _matchErrorFlashKeys,
      isMatchInteractionLocked: _isMatchInteractionLocked,
    );
  }

  void _handleMatchAttemptResult() {
    final StudyUnit? currentUnit = _engine.currentUnit;
    if (currentUnit is! MatchUnit) {
      return;
    }
    final MatchAttemptResult? lastAttemptResult = currentUnit.lastAttemptResult;
    if (lastAttemptResult == null) {
      return;
    }
    _isMatchInteractionLocked = true;
    _matchErrorFlashKeys = <String>{};
    _matchSuccessFlashKeys = <String>{};
    final Set<String> attemptFlashKeys = _buildAttemptFlashKeys(
      attemptResult: lastAttemptResult,
    );
    final Set<int> attemptPairIds = <int>{
      lastAttemptResult.leftId,
      lastAttemptResult.rightId,
    };
    if (lastAttemptResult.isCorrect) {
      _matchSuccessFlashKeys = attemptFlashKeys;
      _scheduleMatchFeedbackCompletion(
        onCompleted: () {
          final Set<int> nextHiddenIds = Set<int>.from(_matchHiddenIds);
          nextHiddenIds.addAll(attemptPairIds);
          _matchHiddenIds = nextHiddenIds;
          _matchSuccessFlashKeys = <String>{};
          _isMatchInteractionLocked = false;
          _sync();
        },
      );
      return;
    }
    _matchErrorFlashKeys = attemptFlashKeys;
    _scheduleMatchFeedbackCompletion(
      onCompleted: () {
        _matchErrorFlashKeys = <String>{};
        _isMatchInteractionLocked = false;
        _sync();
      },
    );
  }

  void _scheduleMatchFeedbackCompletion({
    required void Function() onCompleted,
  }) {
    _matchFeedbackTimer?.cancel();
    _matchFeedbackToken++;
    final int callbackToken = _matchFeedbackToken;
    _matchFeedbackTimer = Timer(AppDurations.animationHold, () {
      if (!ref.mounted) {
        return;
      }
      if (callbackToken != _matchFeedbackToken) {
        return;
      }
      onCompleted();
    });
  }

  void _resetMatchPresentationState() {
    _matchFeedbackTimer?.cancel();
    _matchFeedbackToken++;
    _matchHiddenIds = <int>{};
    _matchSuccessFlashKeys = <String>{};
    _matchErrorFlashKeys = <String>{};
    _isMatchInteractionLocked = false;
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

  Set<String> _buildAttemptFlashKeys({
    required MatchAttemptResult attemptResult,
  }) {
    return <String>{
      _buildMatchTileFlashKey(
        side: _MatchTileSide.left,
        pairId: attemptResult.leftId,
      ),
      _buildMatchTileFlashKey(
        side: _MatchTileSide.right,
        pairId: attemptResult.rightId,
      ),
    };
  }

  String _buildMatchTileFlashKey({
    required _MatchTileSide side,
    required int pairId,
  }) {
    final String sideLabel = side.name;
    return '$sideLabel:$pairId';
  }

  void _startAudioPlayingIndicator(int flashcardId) {
    _audioPlayingIndicatorTimer?.cancel();
    _playingFlashcardId = flashcardId;
    _audioPlayingIndicatorTimer = Timer(
      const Duration(milliseconds: StudyConstants.audioPlayingIndicatorDurationMs),
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
    _sync();
  }
}

enum _MatchTileSide {
  left,
  right,
}
