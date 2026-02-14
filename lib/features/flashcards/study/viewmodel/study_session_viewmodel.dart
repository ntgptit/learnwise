import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  factory StudySessionState.fromEngine({
    required StudyMode mode,
    required StudyEngine engine,
    required bool isFrontVisible,
    required int? playingFlashcardId,
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

  @override
  StudySessionState build(StudySessionArgs args) {
    ref.onDispose(() {
      _audioPlayingIndicatorTimer?.cancel();
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
    return StudySessionState.fromEngine(
      mode: args.mode,
      engine: _engine,
      isFrontVisible: _isFrontVisible,
      playingFlashcardId: _playingFlashcardId,
    );
  }

  void submitAnswer(StudyAnswer answer) {
    _engine.submitAnswer(answer);
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

  void submitFlip() {
    if (_engine.mode != StudyMode.review) {
      return;
    }
    _isFrontVisible = !_isFrontVisible;
    _sync();
  }

  void playCurrentAudio() {
    if (_engine.mode != StudyMode.review) {
      return;
    }
    final StudyUnit? currentUnit = _engine.currentUnit;
    if (currentUnit is! ReviewUnit) {
      return;
    }
    _startAudioPlayingIndicator(currentUnit.flashcardId);
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
    );
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
