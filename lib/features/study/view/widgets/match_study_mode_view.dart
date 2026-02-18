// quality-guard: allow-large-file - phase2 legacy backlog tracked for file modularization.
// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_durations.dart';
import '../../../../../common/styles/app_opacities.dart';
import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';
import 'study_feedback_tile_style.dart';

const String _matchSemanticsSeparator = ': ';
const String _truncatedSemanticsSuffix = '...';
const String _matchLeftTileFlashKeyPrefix = 'left:';
const String _matchRightTileFlashKeyPrefix = 'right:';

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
    final matchFeedback = state.matchInteractionFeedback;
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal),
        ),
      );
    }
    final int baselineRowCount = _resolveBaselineRowCount(
      totalLeftCount: unit.leftEntries.length,
      totalRightCount: unit.rightEntries.length,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final double rowHeight = _resolveAdaptiveRowHeight(
          viewportHeight: constraints.maxHeight,
          baselineRowCount: baselineRowCount,
        );
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
            final MatchEntry leftEntry = visibleLeftEntries[index];
            final MatchEntry rightEntry = visibleRightEntries[index];
            final bool isLeftSelected = unit.selectedLeftId == leftEntry.id;
            final bool isRightSelected = unit.selectedRightId == rightEntry.id;
            final bool isLeftMatched = unit.matchedIds.contains(leftEntry.id);
            final bool isRightMatched = unit.matchedIds.contains(rightEntry.id);
            final bool isLeftAnimatingSuccess = matchFeedback.successIds
                .contains(
                  _buildMatchTileFlashKey(
                    isLeftTile: true,
                    pairId: leftEntry.id,
                  ),
                );
            final bool isRightAnimatingSuccess = matchFeedback.successIds
                .contains(
                  _buildMatchTileFlashKey(
                    isLeftTile: false,
                    pairId: rightEntry.id,
                  ),
                );
            final bool isLeftErrorFlash = matchFeedback.errorIds.contains(
              _buildMatchTileFlashKey(isLeftTile: true, pairId: leftEntry.id),
            );
            final bool isRightErrorFlash = matchFeedback.errorIds.contains(
              _buildMatchTileFlashKey(isLeftTile: false, pairId: rightEntry.id),
            );
            return SizedBox(
              height: rowHeight,
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
                        isLocked: matchFeedback.isLocked,
                        isMatched: isLeftMatched,
                        onPressed: () => onLeftPressed(leftEntry.id),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: FlashcardStudySessionTokens.sectionSpacing,
                  ),
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
                        isLocked: matchFeedback.isLocked,
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

String _buildMatchTileFlashKey({
  required bool isLeftTile,
  required int pairId,
}) {
  final String prefix = isLeftTile
      ? _matchLeftTileFlashKeyPrefix
      : _matchRightTileFlashKeyPrefix;
  return '$prefix$pairId';
}

List<MatchEntry> _resolveVisibleEntries({
  required List<MatchEntry> entries,
  required Set<int> hiddenMatchedIds,
}) {
  return entries
      .where((entry) => !hiddenMatchedIds.contains(entry.id))
      .toList();
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

int _resolveBaselineRowCount({
  required int totalLeftCount,
  required int totalRightCount,
}) {
  final int totalRowCount = _resolveRowCount(
    leftCount: totalLeftCount,
    rightCount: totalRightCount,
  );
  if (totalRowCount <= FlashcardStudySessionTokens.matchVisiblePairCount) {
    return totalRowCount;
  }
  return FlashcardStudySessionTokens.matchVisiblePairCount;
}

double _resolveAdaptiveRowHeight({
  required double viewportHeight,
  required int baselineRowCount,
}) {
  if (baselineRowCount <= 0) {
    return FlashcardStudySessionTokens.matchRowHeight;
  }
  if (viewportHeight <= 0) {
    return FlashcardStudySessionTokens.matchRowHeight;
  }
  final double spacingHeight =
      FlashcardStudySessionTokens.matchRowSpacing * (baselineRowCount - 1);
  const double paddingHeight = FlashcardStudySessionTokens.reviewBodyBottomGap;
  final double availableHeight = viewportHeight - spacingHeight - paddingHeight;
  if (availableHeight <= 0) {
    return FlashcardStudySessionTokens.matchRowHeight;
  }
  final double adaptiveHeight = availableHeight / baselineRowCount;
  if (adaptiveHeight <= FlashcardStudySessionTokens.matchRowHeight) {
    return adaptiveHeight;
  }
  return FlashcardStudySessionTokens.matchRowHeight;
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
    return resolveStudyFeedbackBorder(
      colorScheme: colorScheme,
      showSuccessState: showSuccessState,
      showErrorState: showErrorState,
    );
  }

  Color _resolveBackgroundColor(ColorScheme colorScheme) {
    final Color fallbackColor = _resolveFallbackBackgroundColor(colorScheme);
    return resolveStudyFeedbackBackgroundColor(
      colorScheme: colorScheme,
      showSuccessState: showSuccessState,
      showErrorState: showErrorState,
      fallbackColor: fallbackColor,
    );
  }

  Color _resolveFallbackBackgroundColor(ColorScheme colorScheme) {
    if (isSelected) {
      return colorScheme.primary.withValues(alpha: AppOpacities.soft35);
    }
    if (isMatched) {
      return colorScheme.primaryContainer.withValues(
        alpha: AppOpacities.soft20,
      );
    }
    return colorScheme.surfaceContainerHigh;
  }

  TextStyle? _resolveLabelStyle({
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final TextStyle? fallbackStyle = _resolveFallbackLabelStyle(
      theme: theme,
      colorScheme: colorScheme,
    );
    return resolveStudyFeedbackTextStyle(
      colorScheme: colorScheme,
      showSuccessState: showSuccessState,
      showErrorState: showErrorState,
      fallbackStyle: fallbackStyle,
    );
  }

  TextStyle? _resolveFallbackLabelStyle({
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final double labelFontSize = _resolveLabelFontSize();
    final TextStyle? baseStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.normal,
      fontSize: labelFontSize,
    );
    final Color tileTextColor = colorScheme.onSurfaceVariant.withValues(
      alpha: AppOpacities.muted82,
    );
    if (isSelected) {
      return baseStyle?.copyWith(color: colorScheme.onSurface);
    }
    if (isMatched) {
      return baseStyle?.copyWith(color: tileTextColor);
    }
    return baseStyle?.copyWith(color: tileTextColor);
  }

  double _resolveLabelFontSize() {
    if (isPromptTile) {
      return FlashcardStudySessionTokens.matchPromptLabelFontSize;
    }
    return FlashcardStudySessionTokens.matchMeaningLabelFontSize;
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
