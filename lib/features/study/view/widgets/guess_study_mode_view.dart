// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../model/study_constants.dart';
import '../../model/study_interaction_feedback_state.dart';
import '../../model/study_unit.dart';
import 'study_feedback_tile_style.dart';

const String _guessOptionKeyPrefix = 'guess_option_';

class GuessStudyModeView extends StatelessWidget {
  const GuessStudyModeView({
    required this.unit,
    required this.feedbackState,
    required this.onOptionSelected,
    super.key,
  });

  final GuessUnit unit;
  final StudyInteractionFeedbackState<String> feedbackState;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    final List<_GuessOptionSlot> optionSlots = _buildFixedOptionSlots(
      unit.options,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: FlashcardStudySessionTokens.guessPromptFlex,
          child: _GuessPromptCard(prompt: unit.prompt),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
        Expanded(
          flex: FlashcardStudySessionTokens.guessOptionsFlex,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildOptionWidgets(optionSlots),
          ),
        ),
      ],
    );
  }

  List<_GuessOptionSlot> _buildFixedOptionSlots(List<GuessOption> options) {
    final List<_GuessOptionSlot> slots = <_GuessOptionSlot>[];
    int index = StudyConstants.defaultIndex;
    while (index < FlashcardStudySessionTokens.guessOptionCount) {
      if (index < options.length) {
        final GuessOption option = options[index];
        slots.add(_GuessOptionSlot.enabled(id: option.id, label: option.label));
        index++;
        continue;
      }
      slots.add(const _GuessOptionSlot.disabled());
      index++;
    }
    return List<_GuessOptionSlot>.unmodifiable(slots);
  }

  List<Widget> _buildOptionWidgets(List<_GuessOptionSlot> optionSlots) {
    final List<Widget> widgets = <Widget>[];
    int index = StudyConstants.defaultIndex;
    while (index < optionSlots.length) {
      if (index > StudyConstants.defaultIndex) {
        widgets.add(
          const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
        );
      }
      final _GuessOptionSlot optionSlot = optionSlots[index];
      widgets.add(
        Expanded(
          child: _GuessOptionCard(
            key: ValueKey<String>('$_guessOptionKeyPrefix$index'),
            label: optionSlot.label,
            semanticLabel: optionSlot.label,
            enabled: optionSlot.enabled,
            showSuccessState: feedbackState.successIds.contains(optionSlot.id),
            showErrorState: feedbackState.errorIds.contains(optionSlot.id),
            isInteractionLocked: feedbackState.isLocked,
            onPressed: () => onOptionSelected(optionSlot.id),
          ),
        ),
      );
      index++;
    }
    return widgets;
  }
}

class _GuessPromptCard extends StatelessWidget {
  const _GuessPromptCard({required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      elevation: FlashcardStudySessionTokens.cardElevation,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(
        FlashcardStudySessionTokens.cardRadius,
      ),
      padding: const EdgeInsets.all(
        FlashcardStudySessionTokens.matchCardPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _GuessPromptActionIcon(iconData: Icons.edit_outlined),
          const SizedBox(
            height: FlashcardStudySessionTokens.reviewCardActionTopGap,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal:
                      FlashcardStudySessionTokens.guessPromptHorizontalPadding,
                ),
                child: Semantics(
                  label: prompt,
                  child: ExcludeSemantics(
                    child: Text(
                      prompt,
                      textAlign: TextAlign.center,
                      maxLines: FlashcardStudySessionTokens.guessPromptMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: FlashcardStudySessionTokens.reviewCardActionTopGap,
          ),
          const _GuessPromptActionIcon(iconData: Icons.volume_up_outlined),
        ],
      ),
    );
  }
}

class _GuessPromptActionIcon extends StatelessWidget {
  const _GuessPromptActionIcon({required this.iconData});

  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FlashcardStudySessionTokens.guessPromptActionOuterPadding,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(
              FlashcardStudySessionTokens.guessPromptActionRadius,
            ),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              FlashcardStudySessionTokens.guessPromptActionInnerPadding,
            ),
            child: Icon(iconData, size: FlashcardStudySessionTokens.iconSize),
          ),
        ),
      ),
    );
  }
}

class _GuessOptionCard extends StatelessWidget {
  const _GuessOptionCard({
    required this.label,
    required this.semanticLabel,
    required this.enabled,
    required this.showSuccessState,
    required this.showErrorState,
    required this.isInteractionLocked,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final bool enabled;
  final bool showSuccessState;
  final bool showErrorState;
  final bool isInteractionLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color backgroundColor = _resolveBackgroundColor(colorScheme);
    final BoxBorder? border = _resolveBorder(colorScheme);
    final VoidCallback? tapHandler = _resolveTapHandler();
    return AppCard(
      variant: AppCardVariant.elevated,
      elevation: FlashcardStudySessionTokens.cardElevation,
      backgroundColor: backgroundColor,
      border: border,
      borderRadius: BorderRadius.circular(
        FlashcardStudySessionTokens.matchCardRadius,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: FlashcardStudySessionTokens.matchCardPadding,
        vertical: FlashcardStudySessionTokens.guessOptionVerticalPadding,
      ),
      onTap: tapHandler,
      child: _buildOptionText(context),
    );
  }

  Widget _buildOptionText(BuildContext context) {
    Widget text = Text(
      label,
      textAlign: TextAlign.center,
      maxLines: FlashcardStudySessionTokens.guessOptionMaxLines,
      overflow: TextOverflow.ellipsis,
      style: _resolveTextStyle(context),
    );
    if (enabled && !isInteractionLocked) {
      text = Semantics(
        label: semanticLabel,
        button: true,
        child: ExcludeSemantics(child: text),
      );
    }
    return Center(child: text);
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
    if (enabled) {
      return colorScheme.surfaceContainerHigh;
    }
    return colorScheme.surfaceContainer;
  }

  BoxBorder? _resolveBorder(ColorScheme colorScheme) {
    return resolveStudyFeedbackBorder(
      colorScheme: colorScheme,
      showSuccessState: showSuccessState,
      showErrorState: showErrorState,
    );
  }

  TextStyle? _resolveTextStyle(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextStyle? fallbackStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.normal,
    );
    return resolveStudyFeedbackTextStyle(
      colorScheme: colorScheme,
      showSuccessState: showSuccessState,
      showErrorState: showErrorState,
      fallbackStyle: fallbackStyle,
    );
  }

  VoidCallback? _resolveTapHandler() {
    if (!enabled) {
      return null;
    }
    if (isInteractionLocked) {
      return null;
    }
    return onPressed;
  }
}

class _GuessOptionSlot {
  const _GuessOptionSlot.enabled({required this.id, required this.label})
    : enabled = true;

  const _GuessOptionSlot.disabled() : id = '', label = '', enabled = false;

  final String id;
  final String label;
  final bool enabled;
}
