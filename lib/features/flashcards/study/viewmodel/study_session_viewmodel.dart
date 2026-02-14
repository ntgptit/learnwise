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
    required this.currentStep,
    required this.totalSteps,
    required this.correctCount,
    required this.wrongCount,
    required this.isCompleted,
  });

  final StudyMode mode;
  final StudyUnit? currentUnit;
  final int currentStep;
  final int totalSteps;
  final int correctCount;
  final int wrongCount;
  final bool isCompleted;

  factory StudySessionState.fromEngine({
    required StudyMode mode,
    required StudyEngine engine,
  }) {
    return StudySessionState(
      mode: mode,
      currentUnit: engine.currentUnit,
      currentStep: _resolveCurrentStep(engine: engine),
      totalSteps: engine.totalUnits,
      correctCount: engine.correctCount,
      wrongCount: engine.wrongCount,
      isCompleted: engine.isCompleted,
    );
  }

  static int _resolveCurrentStep({required StudyEngine engine}) {
    final int totalSteps = engine.totalUnits;
    if (totalSteps <= StudyConstants.defaultIndex) {
      return StudyConstants.defaultIndex;
    }
    if (engine.isCompleted) {
      return totalSteps;
    }
    final int step = engine.currentIndex + 1;
    return step.clamp(1, totalSteps);
  }
}

@Riverpod(keepAlive: true)
StudyEngineFactory studyEngineFactory(Ref ref) {
  return StudyEngineFactory();
}

@Riverpod(keepAlive: true)
class StudySessionController extends _$StudySessionController {
  late StudyEngine _engine;

  @override
  StudySessionState build(StudySessionArgs args) {
    final StudyEngineFactory factory = ref.read(studyEngineFactoryProvider);
    _engine = factory.create(
      StudyEngineRequest(
        mode: args.mode,
        items: args.items,
        initialIndex: args.initialIndex,
        random: Random(args.seed),
      ),
    );
    return StudySessionState.fromEngine(mode: args.mode, engine: _engine);
  }

  void submitAnswer(StudyAnswer answer) {
    _engine.submitAnswer(answer);
    _sync();
  }

  void next() {
    _engine.next();
    _sync();
  }

  void restart() {
    ref.invalidateSelf();
  }

  void _sync() {
    state = StudySessionState.fromEngine(mode: _engine.mode, engine: _engine);
  }
}
