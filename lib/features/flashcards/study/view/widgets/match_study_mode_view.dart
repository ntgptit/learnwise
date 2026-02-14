import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../app/theme/semantic_colors.dart';
import '../../../../../common/styles/app_durations.dart';
import '../../../../../common/styles/app_opacities.dart';
import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';

const String _matchSemanticsSeparator = ': ';
const String _truncatedSemanticsSuffix = '...';

class MatchStudyModeView extends StatelessWidget {
  const MatchStudyModeView({
    required this.unit,
    required this.state,
    required this.onLeftPressed,
    required this.onRightPressed,
    required this.l10n,
    super.key,
  });

  final MatchUnit unit;
  final StudySessionState state;
  final ValueChanged<int> onLeftPressed;
  final ValueChanged<int> onRightPressed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final Set<int> hiddenMatchedIds = state.matchHiddenIds;
    final List<MatchEntry> visibleLeftEntries = _resolveVisibleEntries(
      entries: unit.leftEntries,
      hiddenMatchedIds: hiddenMatchedIds,
    );
    final List<MatchEntry> visibleRightEntries = _resolveVisibleEntries(
      entries: unit.rightEntries,
      hiddenMatchedIds: hiddenMatchedIds,
    );
    final int rowCount = _resolveRowCount(
      leftCount: visibleLeftEntries.length,
      rightCount: visibleRightEntries.length,
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
        return const SizedBox(height: FlashcardStudySessionTokens.matchRowSpacing);
      },
      itemBuilder: (context, index) {
        final MatchEntry leftEntry = visibleLeftEntries[index];
        final MatchEntry rightEntry = visibleRightEntries[index];
        final bool isLeftSelected = unit.selectedLeftId == leftEntry.id;
        final bool isRightSelected = unit.selectedRightId == rightEntry.id;
        final bool isLeftMatched = unit.matchedIds.contains(leftEntry.id);
        final bool isRightMatched = unit.matchedIds.contains(rightEntry.id);
        final bool isLeftAnimatingSuccess = state.matchSuccessFlashIds.contains(
          leftEntry.id,
        );
        final bool isRightAnimatingSuccess = state.matchSuccessFlashIds.contains(
          rightEntry.id,
        );
        final bool isLeftErrorFlash = state.matchErrorFlashIds.contains(leftEntry.id);
        final bool isRightErrorFlash = state.matchErrorFlashIds.contains(rightEntry.id);
        return SizedBox(
          height: FlashcardStudySessionTokens.matchRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _MatchBoardTile(
                  label: leftEntry.label,
                  semanticPrefix: l10n.flashcardsStudyMatchLeftColumnLabel,
                  isPromptTile: true,
                  isSelected: isLeftSelected,
                  isMatched: isLeftMatched,
                  showSuccessState: isLeftAnimatingSuccess,
                  showErrorState: isLeftErrorFlash,
                  onPressed: _resolveTapCallback(
                    isLocked: state.isMatchInteractionLocked,
                    isMatched: isLeftMatched,
                    onPressed: () => onLeftPressed(leftEntry.id),
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
                  showSuccessState: isRightAnimatingSuccess,
                  showErrorState: isRightErrorFlash,
                  onPressed: _resolveTapCallback(
                    isLocked: state.isMatchInteractionLocked,
                    isMatched: isRightMatched,
                    onPressed: () => onRightPressed(rightEntry.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  VoidCallback? _resolveTapCallback({
    required bool isLocked,
    required bool isMatched,
    required VoidCallback onPressed,
  }) {
    if (isLocked) {
      return null;
    }
    if (isMatched) {
      return null;
    }
    return onPressed;
  }
}

List<MatchEntry> _resolveVisibleEntries({
  required List<MatchEntry> entries,
  required Set<int> hiddenMatchedIds,
}) {
  return entries.where((entry) => !hiddenMatchedIds.contains(entry.id)).toList();
}

int _resolveRowCount({required int leftCount, required int rightCount}) {
  assert(
    leftCount == rightCount,
    'Match board columns must have the same item count.',
  );
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
    required this.showSuccessState,
    required this.showErrorState,
    required this.onPressed,
  });

  final String label;
  final String semanticPrefix;
  final bool isPromptTile;
  final bool isSelected;
  final bool isMatched;
  final bool showSuccessState;
  final bool showErrorState;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color backgroundColor = _resolveBackgroundColor(colorScheme);
    final TextStyle? labelStyle = _resolveLabelStyle(
      theme: theme,
      colorScheme: colorScheme,
    );
    final BoxBorder? border = _resolveBorder(colorScheme);
    return Semantics(
      button: onPressed != null,
      enabled: onPressed != null,
      label: _resolveSemanticsLabel(),
      child: AnimatedContainer(
        duration: AppDurations.animationQuick,
        curve: AppMotionCurves.standard,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            FlashcardStudySessionTokens.matchCardRadius,
          ),
          border: border,
        ),
        child: Opacity(
          opacity: _resolveOpacity(),
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
            onTap: onPressed,
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
      ),
    );
  }

  String _resolveSemanticsLabel() {
    final String rawLabel = '$semanticPrefix$_matchSemanticsSeparator$label';
    const int maxLength = FlashcardStudySessionTokens.matchSemanticsMaxLength;
    if (rawLabel.length <= maxLength) {
      return rawLabel;
    }
    final String shortenedLabel = rawLabel.substring(0, maxLength);
    return '$shortenedLabel$_truncatedSemanticsSuffix';
  }

  BoxBorder? _resolveBorder(ColorScheme colorScheme) {
    if (showSuccessState) {
      return Border.all(
        color: colorScheme.onSuccessContainer,
        width: FlashcardStudySessionTokens.matchSuccessBorderWidth,
      );
    }
    if (showErrorState) {
      return Border.all(
        color: colorScheme.onErrorContainer,
        width: FlashcardStudySessionTokens.matchSuccessBorderWidth,
      );
    }
    return null;
  }

  Color _resolveBackgroundColor(ColorScheme colorScheme) {
    if (showSuccessState) {
      return colorScheme.successContainer;
    }
    if (showErrorState) {
      return colorScheme.errorContainer;
    }
    if (isSelected) {
      return colorScheme.primary.withValues(alpha: AppOpacities.soft35);
    }
    if (isMatched) {
      return colorScheme.primaryContainer.withValues(alpha: AppOpacities.soft20);
    }
    return colorScheme.surfaceContainerHigh;
  }

  TextStyle? _resolveLabelStyle({
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    if (showSuccessState) {
      return theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSuccessContainer,
      );
    }
    if (showErrorState) {
      return theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onErrorContainer,
      );
    }
    if (isPromptTile) {
      final Color promptColor = colorScheme.onSurfaceVariant.withValues(
        alpha: AppOpacities.muted82,
      );
      if (isSelected) {
        return theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface);
      }
      if (isMatched) {
        return theme.textTheme.titleMedium?.copyWith(color: promptColor);
      }
      return theme.textTheme.titleMedium?.copyWith(color: promptColor);
    }
    final Color answerColor = colorScheme.onSurfaceVariant;
    if (isSelected) {
      return theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface);
    }
    if (isMatched) {
      return theme.textTheme.bodyMedium?.copyWith(color: answerColor);
    }
    return theme.textTheme.bodyMedium?.copyWith(color: answerColor);
  }

  double _resolveOpacity() {
    if (showSuccessState || showErrorState) {
      return 1;
    }
    if (isMatched) {
      return AppOpacities.muted70;
    }
    return 1;
  }

  int _resolveMaxLines() {
    if (isPromptTile) {
      return FlashcardStudySessionTokens.matchPromptMaxLines;
    }
    return FlashcardStudySessionTokens.matchAnswerMaxLines + 1;
  }
}
