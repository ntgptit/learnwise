part of '../study_session_screen.dart';

class _StudyProgressHeader extends ConsumerWidget {
  const _StudyProgressHeader({
    required this.provider,
    required this.studyArgs,
    required this.l10n,
  });

  final StudySessionControllerProvider provider;
  final StudySessionArgs studyArgs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StudyMode mode = ref.watch(provider.select((value) => value.mode));
    final double progressPercent = ref.watch(
      provider.select((value) => value.progressPercent),
    );
    final int completedModeCount = ref.watch(
      provider.select((value) => value.completedModeCount),
    );
    final int requiredModeCount = ref.watch(
      provider.select((value) => value.requiredModeCount),
    );
    final bool isModeCompleted = ref.watch(
      provider.select((value) => value.isCompleted),
    );
    final bool isSessionCompleted = ref.watch(
      provider.select((value) => value.isSessionCompleted),
    );
    final int displayedCompletedModeCount = resolveDisplayedCompletedModeCount(
      args: studyArgs,
      completedModeCount: completedModeCount,
      requiredModeCount: requiredModeCount,
      isModeCompleted: isModeCompleted,
      isSessionCompleted: isSessionCompleted,
      currentMode: mode,
    );
    final StudyModeContentBuilder? modeContentBuilder =
        _resolveModeContentBuilder(mode);
    final double progressToModeGap =
        modeContentBuilder?.resolveProgressToModeGap() ??
        FlashcardStudySessionTokens.answerSpacing;
    final List<StudyMode> cycleModes = resolveStudyCycleModes(args: studyArgs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildCompactProgressHeader(
          context: context,
          progressPercent: progressPercent,
        ),
        SizedBox(height: progressToModeGap),
        _StudyCycleModeProgress(
          cycleModes: cycleModes,
          completedModeCount: displayedCompletedModeCount,
          l10n: l10n,
        ),
      ],
    );
  }

  Widget _buildCompactProgressHeader({
    required BuildContext context,
    required double progressPercent,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String progressLabel = '${(progressPercent * 100).round()}%';
    return Row(
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              FlashcardStudySessionTokens.progressRadius,
            ),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: FlashcardStudySessionTokens.progressHeight,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(width: FlashcardStudySessionTokens.bottomActionGap),
        Text(
          progressLabel,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: colorScheme.primary),
        ),
      ],
    );
  }
}
