part of '../study_session_screen.dart';

class _StudyCycleModeProgress extends StatelessWidget {
  const _StudyCycleModeProgress({
    required this.cycleModes,
    required this.completedModeCount,
    required this.l10n,
  });

  final List<StudyMode> cycleModes;
  final int completedModeCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (cycleModes.isEmpty) {
      return const SizedBox.shrink();
    }
    final int normalizedCompletedCount = completedModeCount.clamp(
      0,
      cycleModes.length,
    );
    final int focusIndex = _resolveFocusIndex(
      completedModeCount: normalizedCompletedCount,
      totalModeCount: cycleModes.length,
    );
    final List<Widget> children = <Widget>[];
    int index = 0;
    while (index < cycleModes.length) {
      if (index > StudyConstants.defaultIndex) {
        children.add(
          const SizedBox(
            width: FlashcardStudySessionTokens.cycleProgressItemGap,
          ),
        );
      }
      final StudyMode mode = cycleModes[index];
      children.add(
        Expanded(
          child: _buildModeTile(
            context: context,
            mode: mode,
            index: index,
            completedModeCount: normalizedCompletedCount,
            focusIndex: focusIndex,
          ),
        ),
      );
      index++;
    }
    return Row(children: children);
  }

  int _resolveFocusIndex({
    required int completedModeCount,
    required int totalModeCount,
  }) {
    if (completedModeCount >= totalModeCount) {
      return totalModeCount - 1;
    }
    return completedModeCount;
  }

  Widget _buildModeTile({
    required BuildContext context,
    required StudyMode mode,
    required int index,
    required int completedModeCount,
    required int focusIndex,
  }) {
    final bool isCompleted = index < completedModeCount;
    final bool isCurrent = !isCompleted && index == focusIndex;
    final _CycleModeTileStyle style = _resolveTileStyle(
      context: context,
      isCompleted: isCompleted,
      isCurrent: isCurrent,
    );
    final StudyModeContentBuilder? modeContentBuilder =
        _resolveModeContentBuilder(mode);
    final IconData modeIcon =
        modeContentBuilder?.resolveModeIcon() ?? Icons.edit_note_rounded;
    final IconData statusIcon = _resolveStatusIcon(
      isCompleted: isCompleted,
      isCurrent: isCurrent,
    );
    final String modeLabel =
        modeContentBuilder?.resolveModeLabel(l10n) ?? mode.name;
    return Semantics(
      label: modeLabel,
      child: Tooltip(
        message: modeLabel,
        child: Container(
          height: FlashcardStudySessionTokens.cycleProgressItemHeight,
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(
              FlashcardStudySessionTokens.cycleProgressItemRadius,
            ),
            border: Border.all(color: style.borderColor),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                modeIcon,
                size: FlashcardStudySessionTokens.cycleProgressIconSize,
                color: style.foregroundColor,
              ),
              const SizedBox(width: FlashcardStudySessionTokens.modeTileGap),
              Icon(
                statusIcon,
                size: FlashcardStudySessionTokens.cycleProgressStatusIconSize,
                color: style.statusColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _CycleModeTileStyle _resolveTileStyle({
    required BuildContext context,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (isCompleted) {
      return _CycleModeTileStyle(
        backgroundColor: colorScheme.successContainer,
        borderColor: colorScheme.successContainer,
        foregroundColor: colorScheme.onSuccessContainer,
        statusColor: colorScheme.onSuccessContainer,
      );
    }
    if (isCurrent) {
      return _CycleModeTileStyle(
        backgroundColor: colorScheme.secondaryContainer,
        borderColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondaryContainer,
        statusColor: colorScheme.secondary,
      );
    }
    return _CycleModeTileStyle(
      backgroundColor: colorScheme.surfaceContainerHighest,
      borderColor: colorScheme.outlineVariant,
      foregroundColor: colorScheme.onSurfaceVariant,
      statusColor: colorScheme.onSurfaceVariant,
    );
  }

  IconData _resolveStatusIcon({
    required bool isCompleted,
    required bool isCurrent,
  }) {
    if (isCompleted) {
      return Icons.check_rounded;
    }
    if (isCurrent) {
      return Icons.circle_rounded;
    }
    return Icons.circle_outlined;
  }
}

class _CycleModeTileStyle {
  const _CycleModeTileStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.statusColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final Color statusColor;
}
