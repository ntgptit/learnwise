// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
part of '../study_session_screen.dart';

class _StudyCompletedCard extends StatelessWidget {
  const _StudyCompletedCard({
    required this.l10n,
    required this.onClosePressed,
    this.onNextModePressed,
    this.nextModeLabel,
  });

  final AppLocalizations l10n;
  final VoidCallback onClosePressed;
  final VoidCallback? onNextModePressed;
  final String? nextModeLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: LwCard(
        variant: AppCardVariant.filled,
        borderRadius: BorderRadius.circular(
          FlashcardStudySessionTokens.cardRadius,
        ),
        padding: const EdgeInsets.all(FlashcardStudySessionTokens.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: FlashcardStudySessionTokens.cycleProgressItemHeight,
              height: FlashcardStudySessionTokens.cycleProgressItemHeight,
              alignment: Alignment.center,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(
                    FlashcardStudySessionTokens.cycleProgressItemRadius,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    FlashcardStudySessionTokens.answerSpacing,
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
            Text(
              l10n.flashcardsStudyCompletedTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
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
