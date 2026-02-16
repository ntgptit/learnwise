import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/study/model/study_cycle_progress.dart';
import 'package:learnwise/features/study/model/study_mode.dart';
import 'package:learnwise/features/study/model/study_session_args.dart';

void main() {
  group('study cycle progress', () {
    test(
      'review completed with stale backend count still resolves next to match',
      () {
        final StudySessionArgs args = _buildArgs(mode: StudyMode.review);

        final int displayCount = resolveDisplayedCompletedModeCount(
          args: args,
          completedModeCount: 0,
          requiredModeCount: 5,
          isModeCompleted: true,
          isSessionCompleted: false,
          currentMode: StudyMode.review,
        );
        final StudyMode? nextMode = resolveNextCycleMode(
          args: args,
          currentMode: StudyMode.review,
          completedModeCount: 0,
          requiredModeCount: 5,
          isModeCompleted: true,
          isSessionCompleted: false,
        );

        expect(displayCount, 1);
        expect(nextMode, StudyMode.match);
      },
    );

    test('guess completed shows 3/5 and resolves next to recall', () {
      final StudySessionArgs args = _buildArgs(mode: StudyMode.review);

      final int displayCount = resolveDisplayedCompletedModeCount(
        args: args,
        completedModeCount: 2,
        requiredModeCount: 5,
        isModeCompleted: true,
        isSessionCompleted: false,
        currentMode: StudyMode.guess,
      );
      final StudyMode? nextMode = resolveNextCycleMode(
        args: args,
        currentMode: StudyMode.guess,
        completedModeCount: 2,
        requiredModeCount: 5,
        isModeCompleted: true,
        isSessionCompleted: false,
      );

      expect(displayCount, 3);
      expect(nextMode, StudyMode.recall);
    });

    test('session completed always clamps count and has no next mode', () {
      final StudySessionArgs args = _buildArgs(mode: StudyMode.review);

      final int displayCount = resolveDisplayedCompletedModeCount(
        args: args,
        completedModeCount: 3,
        requiredModeCount: 5,
        isModeCompleted: true,
        isSessionCompleted: true,
        currentMode: StudyMode.fill,
      );
      final StudyMode? nextMode = resolveNextCycleMode(
        args: args,
        currentMode: StudyMode.fill,
        completedModeCount: 3,
        requiredModeCount: 5,
        isModeCompleted: true,
        isSessionCompleted: true,
      );

      expect(displayCount, 5);
      expect(nextMode, isNull);
    });

    test('restarted match mode rewinds progress to previous mode in cycle', () {
      final StudySessionArgs args = _buildArgs(mode: StudyMode.review);

      final int displayCount = resolveDisplayedCompletedModeCount(
        args: args,
        completedModeCount: 4,
        requiredModeCount: 5,
        isModeCompleted: false,
        isSessionCompleted: false,
        currentMode: StudyMode.match,
      );
      final StudyMode? nextMode = resolveNextCycleMode(
        args: args,
        currentMode: StudyMode.match,
        completedModeCount: 4,
        requiredModeCount: 5,
        isModeCompleted: false,
        isSessionCompleted: false,
      );

      expect(displayCount, 1);
      expect(nextMode, StudyMode.match);
    });

    test('custom cycle starting from match resolves next mode correctly', () {
      final StudySessionArgs args = _buildArgs(mode: StudyMode.match);

      final int displayCount = resolveDisplayedCompletedModeCount(
        args: args,
        completedModeCount: 1,
        requiredModeCount: 5,
        isModeCompleted: true,
        isSessionCompleted: false,
        currentMode: StudyMode.guess,
      );
      final StudyMode? nextMode = resolveNextCycleMode(
        args: args,
        currentMode: StudyMode.guess,
        completedModeCount: 1,
        requiredModeCount: 5,
        isModeCompleted: true,
        isSessionCompleted: false,
      );

      expect(displayCount, 2);
      expect(nextMode, StudyMode.recall);
    });

    test('cycle index prefers current mode over stale args index', () {
      final StudySessionArgs args = _buildArgs(
        mode: StudyMode.review,
        cycleModeIndex: 0,
      );
      final List<StudyMode> cycleModes = resolveStudyCycleModes(args: args);

      final int modeIndex = resolveStudyCycleModeIndex(
        args: args,
        cycleModes: cycleModes,
        currentMode: StudyMode.recall,
      );

      expect(modeIndex, 3);
    });
  });
}

StudySessionArgs _buildArgs({required StudyMode mode, int cycleModeIndex = 0}) {
  return StudySessionArgs(
    deckId: 1,
    mode: mode,
    items: const [],
    title: 'Study',
    cycleModeIndex: cycleModeIndex,
  );
}
