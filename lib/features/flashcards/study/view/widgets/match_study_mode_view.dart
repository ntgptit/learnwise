import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../model/study_answer.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';

class MatchStudyModeView extends StatelessWidget {
  const MatchStudyModeView({
    required this.unit,
    required this.controller,
    required this.l10n,
    super.key,
  });

  final MatchUnit unit;
  final StudySessionController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.flashcardsStudyMatchPrompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _MatchColumn(
                title: l10n.flashcardsStudyMatchLeftColumnLabel,
                entries: unit.leftEntries,
                selectedId: unit.selectedLeftId,
                matchedIds: unit.matchedIds,
                onPressed: (entryId) {
                  controller.submitAnswer(
                    MatchSelectLeftStudyAnswer(leftId: entryId),
                  );
                },
              ),
            ),
            const SizedBox(width: FlashcardStudySessionTokens.sectionSpacing),
            Expanded(
              child: _MatchColumn(
                title: l10n.flashcardsStudyMatchRightColumnLabel,
                entries: unit.rightEntries,
                selectedId: unit.selectedRightId,
                matchedIds: unit.matchedIds,
                onPressed: (entryId) {
                  controller.submitAnswer(
                    MatchSelectRightStudyAnswer(rightId: entryId),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MatchColumn extends StatelessWidget {
  const _MatchColumn({
    required this.title,
    required this.entries,
    required this.selectedId,
    required this.matchedIds,
    required this.onPressed,
  });

  final String title;
  final List<MatchEntry> entries;
  final int? selectedId;
  final Set<int> matchedIds;
  final ValueChanged<int> onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
        ...entries.map((entry) {
          final bool isMatched = matchedIds.contains(entry.id);
          final bool isSelected = selectedId == entry.id;
          return Padding(
            padding: const EdgeInsets.only(
              bottom: FlashcardStudySessionTokens.modeTileGap,
            ),
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: _resolveMatchButtonBackground(
                  colorScheme: colorScheme,
                  isMatched: isMatched,
                  isSelected: isSelected,
                ),
              ),
              onPressed: isMatched ? null : () => onPressed(entry.id),
              child: Text(
                entry.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }),
      ],
    );
  }

  Color? _resolveMatchButtonBackground({
    required ColorScheme colorScheme,
    required bool isMatched,
    required bool isSelected,
  }) {
    if (isMatched) {
      return colorScheme.primaryContainer;
    }
    if (isSelected) {
      return colorScheme.secondaryContainer;
    }
    return null;
  }
}
