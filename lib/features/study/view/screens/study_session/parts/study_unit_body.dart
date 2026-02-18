// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
part of '../study_session_screen.dart';

class _StudyUnitBody extends ConsumerWidget {
  const _StudyUnitBody({
    required this.provider,
    required this.l10n,
    required this.fillController,
    required this.studyArgs,
    required this.onNextModePressed,
    required this.onClosePressed,
  });

  final StudySessionControllerProvider provider;
  final AppLocalizations l10n;
  final TextEditingController fillController;
  final StudySessionArgs studyArgs;
  final ValueChanged<StudyMode> onNextModePressed;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StudySessionState state = ref.watch(provider);
    final StudySessionController controller = ref.read(provider.notifier);
    final int displayedCompletedModeCount = resolveDisplayedCompletedModeCount(
      args: studyArgs,
      completedModeCount: state.completedModeCount,
      requiredModeCount: state.requiredModeCount,
      isModeCompleted: state.isCompleted,
      isSessionCompleted: state.isSessionCompleted,
      currentMode: state.mode,
    );
    if (state.isCompleted) {
      final List<StudyMode> cycleModes = resolveStudyCycleModes(
        args: studyArgs,
      );
      final StudyMode? nextMode = resolveNextCycleMode(
        args: studyArgs,
        currentMode: state.mode,
        completedModeCount: state.completedModeCount,
        requiredModeCount: state.requiredModeCount,
        isModeCompleted: state.isCompleted,
        isSessionCompleted: state.isSessionCompleted,
      );
      final String? nextModeLabel = _resolveNextModeLabel(
        l10n: l10n,
        nextMode: nextMode,
      );
      return _StudyCompletedCard(
        state: state,
        displayedCompletedModeCount: displayedCompletedModeCount,
        cycleModes: cycleModes,
        l10n: l10n,
        onNextModePressed: nextMode == null
            ? null
            : () => onNextModePressed(nextMode),
        nextModeLabel: nextModeLabel,
        onClosePressed: onClosePressed,
      );
    }
    final StudyUnit? currentUnit = state.currentUnit;
    if (currentUnit == null) {
      return const SizedBox.shrink();
    }
    final Widget unitContent = _buildUnitContent(
      currentUnit: currentUnit,
      state: state,
      controller: controller,
    );
    final StudyModeContentBuilder? modeContentBuilder =
        _resolveModeContentBuilder(state.mode);
    return _buildUnitContentLayout(
      context: context,
      unitContent: unitContent,
      modeContentBuilder: modeContentBuilder,
    );
  }

  Widget _buildUnitContent({
    required StudyUnit currentUnit,
    required StudySessionState state,
    required StudySessionController controller,
  }) {
    final StudyModeContentBuilder? builder = _resolveModeContentBuilder(
      state.mode,
    );
    if (builder == null) {
      return const SizedBox.shrink();
    }
    final ModeContentBuildContext buildContext = ModeContentBuildContext(
      currentUnit: currentUnit,
      state: state,
      controller: controller,
      l10n: l10n,
      fillController: fillController,
    );
    return builder.buildContent(buildContext);
  }

  Widget _buildUnitContentLayout({
    required BuildContext context,
    required Widget unitContent,
    required StudyModeContentBuilder? modeContentBuilder,
  }) {
    if (modeContentBuilder == null) {
      return _buildCardContentLayout(context, unitContent);
    }
    return modeContentBuilder.buildContentLayout(context, unitContent);
  }

  Widget _buildCardContentLayout(BuildContext context, Widget unitContent) {
    final Widget content = AppCard(
      variant: AppCardVariant.elevated,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(
        FlashcardStudySessionTokens.cardRadius,
      ),
      padding: const EdgeInsets.all(FlashcardStudySessionTokens.cardPadding),
      child: unitContent,
    );
    return SingleChildScrollView(child: content);
  }

  String? _resolveNextModeLabel({
    required AppLocalizations l10n,
    required StudyMode? nextMode,
  }) {
    if (nextMode == null) {
      return null;
    }
    final StudyModeContentBuilder? modeContentBuilder =
        _resolveModeContentBuilder(nextMode);
    final String modeLabel =
        modeContentBuilder?.resolveModeLabel(l10n) ?? nextMode.name;
    return l10n.flashcardsStudyNextModeLabel(modeLabel);
  }
}
