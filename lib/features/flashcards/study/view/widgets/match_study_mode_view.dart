import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_opacities.dart';
import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../model/study_answer.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';

const String _matchSemanticsSeparator = ': ';

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
    final int rowCount = _resolveRowCount(
      leftCount: unit.leftEntries.length,
      rightCount: unit.rightEntries.length,
    );
    if (rowCount <= 0) {
      return Center(
        child: Text(
          l10n.flashcardsStudyMatchPrompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    return ListView.separated(
      itemCount: rowCount,
      padding: const EdgeInsets.only(
        bottom: FlashcardStudySessionTokens.reviewBodyBottomGap,
      ),
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: FlashcardStudySessionTokens.matchRowSpacing,
        );
      },
      itemBuilder: (context, index) {
        final MatchEntry leftEntry = unit.leftEntries[index];
        final MatchEntry rightEntry = unit.rightEntries[index];
        final bool isLeftSelected = unit.selectedLeftId == leftEntry.id;
        final bool isRightSelected = unit.selectedRightId == rightEntry.id;
        final bool isLeftMatched = unit.matchedIds.contains(leftEntry.id);
        final bool isRightMatched = unit.matchedIds.contains(rightEntry.id);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _MatchBoardTile(
                label: leftEntry.label,
                semanticPrefix: l10n.flashcardsStudyMatchLeftColumnLabel,
                isPromptTile: true,
                isSelected: isLeftSelected,
                isMatched: isLeftMatched,
                onPressed: () => controller.submitAnswer(
                  MatchSelectLeftStudyAnswer(leftId: leftEntry.id),
                ),
              ),
            ),
            const SizedBox(width: FlashcardStudySessionTokens.sectionSpacing),
            Expanded(
              child: _MatchBoardTile(
                label: rightEntry.label,
                semanticPrefix: l10n.flashcardsStudyMatchRightColumnLabel,
                isPromptTile: false,
                isSelected: isRightSelected,
                isMatched: isRightMatched,
                onPressed: () => controller.submitAnswer(
                  MatchSelectRightStudyAnswer(rightId: rightEntry.id),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

int _resolveRowCount({required int leftCount, required int rightCount}) {
  if (leftCount <= rightCount) {
    return leftCount;
  }
  return rightCount;
}

class _MatchBoardTile extends StatelessWidget {
  const _MatchBoardTile({
    required this.label,
    required this.semanticPrefix,
    required this.isPromptTile,
    required this.isSelected,
    required this.isMatched,
    required this.onPressed,
  });

  final String label;
  final String semanticPrefix;
  final bool isPromptTile;
  final bool isSelected;
  final bool isMatched;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color backgroundColor = _resolveBackgroundColor(colorScheme);
    final TextStyle? labelStyle = _resolveLabelStyle(
      theme: theme,
      colorScheme: colorScheme,
    );
    final String semanticsLabel =
        '$semanticPrefix$_matchSemanticsSeparator$label';
    return Semantics(
      button: !isMatched,
      enabled: !isMatched,
      label: semanticsLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: FlashcardStudySessionTokens.matchCardMinHeight,
        ),
        child: AppCard(
          variant: AppCardVariant.elevated,
          elevation: FlashcardStudySessionTokens.cardElevation,
          borderRadius: BorderRadius.circular(
            FlashcardStudySessionTokens.matchCardRadius,
          ),
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.all(
            FlashcardStudySessionTokens.matchCardPadding,
          ),
          onTap: isMatched ? null : onPressed,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: _resolveMaxLines(),
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveBackgroundColor(ColorScheme colorScheme) {
    if (isMatched) {
      return colorScheme.primaryContainer.withValues(
        alpha: AppOpacities.soft35,
      );
    }
    if (isSelected) {
      return colorScheme.primary.withValues(alpha: AppOpacities.soft20);
    }
    return colorScheme.surfaceContainerHigh;
  }

  TextStyle? _resolveLabelStyle({
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final Color emphasizedColor = colorScheme.onSurface;
    if (isPromptTile) {
      final Color promptColor = colorScheme.onSurfaceVariant.withValues(
        alpha: AppOpacities.muted82,
      );
      if (isSelected || isMatched) {
        return theme.textTheme.bodyMedium?.copyWith(color: emphasizedColor);
      }
      return theme.textTheme.bodyMedium?.copyWith(color: promptColor);
    }
    if (isMatched) {
      return theme.textTheme.headlineSmall?.copyWith(color: emphasizedColor);
    }
    if (isSelected) {
      return theme.textTheme.headlineSmall?.copyWith(color: emphasizedColor);
    }
    return theme.textTheme.headlineSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
  }

  int _resolveMaxLines() {
    if (isPromptTile) {
      return FlashcardStudySessionTokens.matchPromptMaxLines;
    }
    return FlashcardStudySessionTokens.matchAnswerMaxLines;
  }
}
