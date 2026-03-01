// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
part of '../study_session_screen.dart';

class _StudySessionBody extends ConsumerWidget {
  const _StudySessionBody({
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
    final bool isEmpty = ref.watch(
      provider.select((value) => value.totalCount <= 0),
    );
    final bool isCompleted = ref.watch(
      provider.select((value) => value.isCompleted),
    );
    final StudyMode mode = ref.watch(provider.select((value) => value.mode));
    final StudyModeContentBuilder? modeContentBuilder =
        _resolveModeContentBuilder(mode);
    final double headerToContentGap =
        modeContentBuilder?.resolveHeaderToContentGap() ??
        FlashcardStudySessionTokens.sectionSpacing;

    if (isEmpty && !isCompleted) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isEmpty) {
      return LwEmptyState(
        title: l10n.flashcardsEmptyTitle,
        subtitle: l10n.flashcardsEmptyDescription,
        icon: Icons.style_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _StudyProgressHeader(
          provider: provider,
          studyArgs: studyArgs,
          l10n: l10n,
        ),
        SizedBox(height: headerToContentGap),
        Expanded(
          child: _StudyUnitBody(
            provider: provider,
            l10n: l10n,
            fillController: fillController,
            studyArgs: studyArgs,
            onNextModePressed: onNextModePressed,
            onClosePressed: onClosePressed,
          ),
        ),
      ],
    );
  }
}
