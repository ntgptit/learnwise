part of '../study_session_screen.dart';

class _StudyCompletedCard extends StatelessWidget {
  const _StudyCompletedCard({
    required this.state,
    required this.displayedCompletedModeCount,
    required this.cycleModes,
    required this.l10n,
    required this.onClosePressed,
    this.onNextModePressed,
    this.nextModeLabel,
  });

  final StudySessionState state;
  final int displayedCompletedModeCount;
  final List<StudyMode> cycleModes;
  final AppLocalizations l10n;
  final VoidCallback onClosePressed;
  final VoidCallback? onNextModePressed;
  final String? nextModeLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        variant: AppCardVariant.filled,
        borderRadius: BorderRadius.circular(
          FlashcardStudySessionTokens.cardRadius,
        ),
        padding: const EdgeInsets.all(FlashcardStudySessionTokens.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.emoji_events_outlined),
            const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
            Text(
              l10n.flashcardsStudyCompletedTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
            _StudyCycleModeProgress(
              cycleModes: cycleModes,
              completedModeCount: displayedCompletedModeCount,
              l10n: l10n,
            ),
            const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
            if (onNextModePressed != null && nextModeLabel != null)
              _buildCompletedActionButtonContainer(
                child: FilledButton(
                  onPressed: onNextModePressed,
                  child: Text(nextModeLabel!),
                ),
              ),
            if (onNextModePressed != null && nextModeLabel != null)
              const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
            _buildCompletedActionButtonContainer(
              child: OutlinedButton(
                onPressed: onClosePressed,
                child: Text(l10n.flashcardsCloseTooltip),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedActionButtonContainer({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double resolvedWidth =
            FlashcardStudySessionTokens.completedActionButtonWidth;
        if (constraints.maxWidth < resolvedWidth) {
          resolvedWidth = constraints.maxWidth;
        }
        return Align(
          alignment: Alignment.center,
          child: SizedBox(width: resolvedWidth, child: child),
        );
      },
    );
  }
}
