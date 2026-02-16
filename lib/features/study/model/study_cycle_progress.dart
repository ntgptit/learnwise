import 'study_mode.dart';
import 'study_session_args.dart';

List<StudyMode> resolveStudyCycleModes({required StudySessionArgs args}) {
  if (args.cycleModes.isNotEmpty) {
    return args.cycleModes;
  }
  return buildStudyModeCycle(startMode: args.mode);
}

int resolveStudyCycleModeIndex({
  required StudySessionArgs args,
  required List<StudyMode> cycleModes,
  required StudyMode currentMode,
}) {
  final int modeIndex = cycleModes.indexOf(currentMode);
  if (modeIndex >= 0) {
    return modeIndex;
  }
  final int rawIndex = args.cycleModeIndex;
  if (rawIndex >= 0 && rawIndex < cycleModes.length) {
    return rawIndex;
  }
  final int argsModeIndex = cycleModes.indexOf(args.mode);
  if (argsModeIndex >= 0) {
    return argsModeIndex;
  }
  return 0;
}

int resolveDisplayedCompletedModeCount({
  required StudySessionArgs args,
  required int completedModeCount,
  required int requiredModeCount,
  required bool isModeCompleted,
  required bool isSessionCompleted,
  required StudyMode currentMode,
}) {
  if (isSessionCompleted) {
    return requiredModeCount;
  }
  final List<StudyMode> cycleModes = resolveStudyCycleModes(args: args);
  final int currentIndex = resolveStudyCycleModeIndex(
    args: args,
    cycleModes: cycleModes,
    currentMode: currentMode,
  );
  int minimumCompletedCount = currentIndex;
  if (isModeCompleted) {
    minimumCompletedCount = currentIndex + 1;
  }
  int maximumCompletedCount = currentIndex;
  if (isModeCompleted) {
    maximumCompletedCount = currentIndex + 1;
  }
  int displayCount = completedModeCount;
  if (displayCount < minimumCompletedCount) {
    displayCount = minimumCompletedCount;
  }
  if (displayCount > maximumCompletedCount) {
    displayCount = maximumCompletedCount;
  }
  if (displayCount < 0) {
    return 0;
  }
  if (displayCount > requiredModeCount) {
    return requiredModeCount;
  }
  return displayCount;
}

StudyMode? resolveNextCycleMode({
  required StudySessionArgs args,
  required StudyMode currentMode,
  required int completedModeCount,
  required int requiredModeCount,
  required bool isModeCompleted,
  required bool isSessionCompleted,
}) {
  if (isSessionCompleted) {
    return null;
  }
  final List<StudyMode> cycleModes = resolveStudyCycleModes(args: args);
  final int effectiveCompletedCount = resolveDisplayedCompletedModeCount(
    args: args,
    completedModeCount: completedModeCount,
    requiredModeCount: requiredModeCount,
    isModeCompleted: isModeCompleted,
    isSessionCompleted: isSessionCompleted,
    currentMode: currentMode,
  );
  if (effectiveCompletedCount < 0) {
    return null;
  }
  if (effectiveCompletedCount >= cycleModes.length) {
    return null;
  }
  return cycleModes[effectiveCompletedCount];
}
