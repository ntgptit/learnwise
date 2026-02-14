import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../app/theme/semantic_colors.dart';
import '../../../../../common/styles/app_durations.dart';
import '../../../../../common/styles/app_opacities.dart';
import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../model/study_answer.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';

const String _matchSemanticsSeparator = ': ';
final Map<int, _MatchPairAttempt> _pendingWrongPairByState =
    <int, _MatchPairAttempt>{};

class MatchStudyModeView extends StatefulWidget {
  const MatchStudyModeView({
    required this.unit,
    required this.state,
    required this.controller,
    required this.l10n,
    super.key,
  });

  final MatchUnit unit;
  final StudySessionState state;
  final StudySessionController controller;
  final AppLocalizations l10n;

  @override
  State<MatchStudyModeView> createState() => _MatchStudyModeViewState();
}

class _MatchStudyModeViewState extends State<MatchStudyModeView> {
  late final ValueNotifier<Set<int>> _hiddenMatchedIdsNotifier;
  late final ValueNotifier<Set<int>> _animatingMatchedIdsNotifier;
  late final ValueNotifier<Set<int>> _errorFlashIdsNotifier;
  final Map<int, Timer> _hideTimers = <int, Timer>{};
  final Map<int, Timer> _errorTimers = <int, Timer>{};

  static const Duration _matchFeedbackDuration = AppDurations.animationHold;

  @override
  void initState() {
    super.initState();
    _hiddenMatchedIdsNotifier = ValueNotifier<Set<int>>(
      Set<int>.from(widget.unit.matchedIds),
    );
    _animatingMatchedIdsNotifier = ValueNotifier<Set<int>>(<int>{});
    _errorFlashIdsNotifier = ValueNotifier<Set<int>>(<int>{});
  }

  @override
  void didUpdateWidget(covariant MatchStudyModeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMatchedTransition(
      previousMatchedIds: oldWidget.unit.matchedIds,
      currentMatchedIds: widget.unit.matchedIds,
    );
    _syncWrongTransition(
      previousWrongCount: oldWidget.state.wrongCount,
      currentWrongCount: widget.state.wrongCount,
      previousUnit: oldWidget.unit,
    );
  }

  @override
  void dispose() {
    for (final Timer timer in _hideTimers.values) {
      timer.cancel();
    }
    _hideTimers.clear();
    for (final Timer timer in _errorTimers.values) {
      timer.cancel();
    }
    _errorTimers.clear();
    _hiddenMatchedIdsNotifier.dispose();
    _animatingMatchedIdsNotifier.dispose();
    _errorFlashIdsNotifier.dispose();
    _pendingWrongPairByState.remove(_stateIdentity);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _hiddenMatchedIdsNotifier,
        _animatingMatchedIdsNotifier,
        _errorFlashIdsNotifier,
      ]),
      builder: (context, child) {
        final Set<int> hiddenMatchedIds = _hiddenMatchedIdsNotifier.value;
        final Set<int> animatingMatchedIds = _animatingMatchedIdsNotifier.value;
        final Set<int> errorFlashIds = _errorFlashIdsNotifier.value;
        final List<MatchEntry> visibleLeftEntries = _resolveVisibleEntries(
          entries: widget.unit.leftEntries,
          hiddenMatchedIds: hiddenMatchedIds,
        );
        final List<MatchEntry> visibleRightEntries = _resolveVisibleEntries(
          entries: widget.unit.rightEntries,
          hiddenMatchedIds: hiddenMatchedIds,
        );
        final int rowCount = _resolveRowCount(
          leftCount: visibleLeftEntries.length,
          rightCount: visibleRightEntries.length,
        );
        if (rowCount <= 0) {
          return Center(
            child: Text(
              widget.l10n.flashcardsStudyMatchPrompt,
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
            final MatchEntry leftEntry = visibleLeftEntries[index];
            final MatchEntry rightEntry = visibleRightEntries[index];
            final bool isLeftSelected =
                widget.unit.selectedLeftId == leftEntry.id;
            final bool isRightSelected =
                widget.unit.selectedRightId == rightEntry.id;
            final bool isLeftMatched = widget.unit.matchedIds.contains(
              leftEntry.id,
            );
            final bool isRightMatched = widget.unit.matchedIds.contains(
              rightEntry.id,
            );
            final bool isLeftAnimatingSuccess = animatingMatchedIds.contains(
              leftEntry.id,
            );
            final bool isRightAnimatingSuccess = animatingMatchedIds.contains(
              rightEntry.id,
            );
            final bool isLeftErrorFlash = errorFlashIds.contains(leftEntry.id);
            final bool isRightErrorFlash = errorFlashIds.contains(
              rightEntry.id,
            );
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: _MatchBoardTile(
                      label: leftEntry.label,
                      semanticPrefix:
                          widget.l10n.flashcardsStudyMatchLeftColumnLabel,
                      isPromptTile: true,
                      isSelected: isLeftSelected,
                      isMatched: isLeftMatched,
                      showSuccessState: isLeftAnimatingSuccess,
                      showErrorState: isLeftErrorFlash,
                      onPressed: () => _onLeftPressed(leftEntry.id),
                    ),
                  ),
                  const SizedBox(
                    width: FlashcardStudySessionTokens.sectionSpacing,
                  ),
                  Expanded(
                    child: _MatchBoardTile(
                      label: rightEntry.label,
                      semanticPrefix:
                          widget.l10n.flashcardsStudyMatchRightColumnLabel,
                      isPromptTile: false,
                      isSelected: isRightSelected,
                      isMatched: isRightMatched,
                      showSuccessState: isRightAnimatingSuccess,
                      showErrorState: isRightErrorFlash,
                      onPressed: () => _onRightPressed(rightEntry.id),
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

  void _syncMatchedTransition({
    required Set<int> previousMatchedIds,
    required Set<int> currentMatchedIds,
  }) {
    final Set<int> newMatchedIds = currentMatchedIds.difference(
      previousMatchedIds,
    );
    if (newMatchedIds.isEmpty) {
      return;
    }
    _pendingWrongPairByState.remove(_stateIdentity);
    for (final int matchedId in newMatchedIds) {
      _startSuccessThenHide(matchedId);
    }
  }

  void _syncWrongTransition({
    required int previousWrongCount,
    required int currentWrongCount,
    required MatchUnit previousUnit,
  }) {
    if (currentWrongCount <= previousWrongCount) {
      return;
    }
    final _MatchPairAttempt? pendingAttempt = _pendingWrongPairByState.remove(
      _stateIdentity,
    );
    if (pendingAttempt != null) {
      _startErrorFlash(pendingAttempt.leftId);
      _startErrorFlash(pendingAttempt.rightId);
      return;
    }

    final int? fallbackLeftId = previousUnit.selectedLeftId;
    final int? fallbackRightId = previousUnit.selectedRightId;
    if (fallbackLeftId == null) {
      return;
    }
    if (fallbackRightId == null) {
      return;
    }
    _startErrorFlash(fallbackLeftId);
    _startErrorFlash(fallbackRightId);
  }

  void _startSuccessThenHide(int matchedId) {
    final Set<int> hiddenIds = _hiddenMatchedIdsNotifier.value;
    if (hiddenIds.contains(matchedId)) {
      return;
    }
    _startFeedbackAnimation(
      entryId: matchedId,
      notifier: _animatingMatchedIdsNotifier,
      timers: _hideTimers,
      onCompleted: () {
        final Set<int> nextHiddenIds = Set<int>.from(
          _hiddenMatchedIdsNotifier.value,
        );
        nextHiddenIds.add(matchedId);
        _hiddenMatchedIdsNotifier.value = nextHiddenIds;
      },
    );
  }

  void _startErrorFlash(int entryId) {
    if (_hiddenMatchedIdsNotifier.value.contains(entryId)) {
      return;
    }
    _startFeedbackAnimation(
      entryId: entryId,
      notifier: _errorFlashIdsNotifier,
      timers: _errorTimers,
    );
  }

  void _startFeedbackAnimation({
    required int entryId,
    required ValueNotifier<Set<int>> notifier,
    required Map<int, Timer> timers,
    VoidCallback? onCompleted,
  }) {
    final Set<int> activeIds = Set<int>.from(notifier.value);
    if (!activeIds.contains(entryId)) {
      activeIds.add(entryId);
      notifier.value = activeIds;
    }
    timers[entryId]?.cancel();
    timers[entryId] = Timer(_matchFeedbackDuration, () {
      if (!mounted) {
        return;
      }
      final Set<int> nextActiveIds = Set<int>.from(notifier.value);
      nextActiveIds.remove(entryId);
      notifier.value = nextActiveIds;
      onCompleted?.call();
      timers.remove(entryId);
    });
  }

  void _onLeftPressed(int leftId) {
    final int? selectedRightId = widget.unit.selectedRightId;
    if (selectedRightId != null) {
      _pendingWrongPairByState[_stateIdentity] = _MatchPairAttempt(
        leftId: leftId,
        rightId: selectedRightId,
      );
    }
    widget.controller.submitAnswer(MatchSelectLeftStudyAnswer(leftId: leftId));
  }

  void _onRightPressed(int rightId) {
    final int? selectedLeftId = widget.unit.selectedLeftId;
    if (selectedLeftId != null) {
      _pendingWrongPairByState[_stateIdentity] = _MatchPairAttempt(
        leftId: selectedLeftId,
        rightId: rightId,
      );
    }
    widget.controller.submitAnswer(
      MatchSelectRightStudyAnswer(rightId: rightId),
    );
  }

  int get _stateIdentity => identityHashCode(this);
}

class _MatchPairAttempt {
  const _MatchPairAttempt({required this.leftId, required this.rightId});

  final int leftId;
  final int rightId;
}

List<MatchEntry> _resolveVisibleEntries({
  required List<MatchEntry> entries,
  required Set<int> hiddenMatchedIds,
}) {
  return entries
      .where((entry) {
        return !hiddenMatchedIds.contains(entry.id);
      })
      .toList(growable: false);
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
    final BoxBorder? border = _resolveBorder(colorScheme);
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
        child: AnimatedContainer(
          duration: AppDurations.animationQuick,
          curve: AppMotionCurves.standard,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              FlashcardStudySessionTokens.matchCardRadius,
            ),
            border: border,
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
      ),
    );
  }

  BoxBorder? _resolveBorder(ColorScheme colorScheme) {
    if (!showSuccessState) {
      if (!showErrorState) {
        return null;
      }
      return Border.all(
        color: colorScheme.onErrorContainer,
        width: FlashcardStudySessionTokens.matchSuccessBorderWidth,
      );
    }
    return Border.all(
      color: colorScheme.onSuccessContainer,
      width: FlashcardStudySessionTokens.matchSuccessBorderWidth,
    );
  }

  Color _resolveBackgroundColor(ColorScheme colorScheme) {
    if (showSuccessState) {
      return colorScheme.successContainer;
    }
    if (showErrorState) {
      return colorScheme.errorContainer;
    }
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
      if (isSelected || isMatched) {
        return theme.textTheme.titleMedium?.copyWith(color: emphasizedColor);
      }
      return theme.textTheme.titleMedium?.copyWith(color: promptColor);
    }
    if (isMatched || isSelected) {
      return theme.textTheme.bodyMedium?.copyWith(color: emphasizedColor);
    }
    return theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
  }

  int _resolveMaxLines() {
    if (isPromptTile) {
      return FlashcardStudySessionTokens.matchPromptMaxLines;
    }
    return FlashcardStudySessionTokens.matchAnswerMaxLines + 1;
  }
}
