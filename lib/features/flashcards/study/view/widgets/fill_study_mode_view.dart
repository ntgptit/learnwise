import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../model/study_unit.dart';

class FillStudyModeView extends StatelessWidget {
  const FillStudyModeView({
    required this.unit,
    required this.onSubmitAnswer,
    required this.l10n,
    required this.fillController,
    super.key,
  });

  final FillUnit unit;
  final ValueChanged<String> onSubmitAnswer;
  final AppLocalizations l10n;
  final TextEditingController fillController;

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final double promptOpacity = _resolvePromptOpacity(isKeyboardVisible);
    final int promptFlex = _resolvePromptFlex(isKeyboardVisible);
    final int answerFlex = _resolveAnswerFlex(isKeyboardVisible);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: promptFlex,
          child: _FillPromptCard(unit: unit, opacity: promptOpacity),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.fillCardGap),
        Expanded(
          flex: answerFlex,
          child: _FillInputCard(
            fillController: fillController,
            onSubmitPressed: _submitCurrentAnswer,
          ),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.fillActionTopGap),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(
            bottom: FlashcardStudySessionTokens.fillActionBottomPadding,
          ),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: fillController,
            builder: (context, value, child) {
              final bool canSubmit = StringUtils.normalize(
                value.text,
              ).isNotEmpty;
              return Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height:
                          FlashcardStudySessionTokens.fillActionButtonHeight,
                      child: FilledButton(
                        onPressed: _onHelpPressed,
                        style: _resolveActionButtonStyle(context),
                        child: Text(l10n.flashcardsStudyFillHelpLabel),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: FlashcardStudySessionTokens.bottomActionGap,
                  ),
                  Expanded(
                    child: SizedBox(
                      height:
                          FlashcardStudySessionTokens.fillActionButtonHeight,
                      child: FilledButton(
                        onPressed: canSubmit ? _submitCurrentAnswer : null,
                        style: _resolveCheckButtonStyle(context),
                        child: Text(l10n.flashcardsStudyFillCheckLabel),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  int _resolvePromptFlex(bool isKeyboardVisible) {
    if (isKeyboardVisible) {
      return FlashcardStudySessionTokens.fillPromptFlexWhenKeyboardVisible;
    }
    return FlashcardStudySessionTokens.fillPromptFlex;
  }

  int _resolveAnswerFlex(bool isKeyboardVisible) {
    if (isKeyboardVisible) {
      return FlashcardStudySessionTokens.fillAnswerFlexWhenKeyboardVisible;
    }
    return FlashcardStudySessionTokens.fillAnswerFlex;
  }

  double _resolvePromptOpacity(bool isKeyboardVisible) {
    if (isKeyboardVisible) {
      return FlashcardStudySessionTokens.fillPromptCardFocusedOpacity;
    }
    return FlashcardStudySessionTokens.fillPromptCardDefaultOpacity;
  }

  void _onHelpPressed() {
    fillController.text = unit.expectedAnswer;
    fillController.selection = TextSelection.collapsed(
      offset: unit.expectedAnswer.length,
    );
  }

  void _submitCurrentAnswer() {
    final String normalizedAnswer = fillController.text.normalized;
    if (normalizedAnswer.isEmpty) {
      return;
    }
    onSubmitAnswer(normalizedAnswer);
    fillController.clear();
  }

  ButtonStyle _resolveActionButtonStyle(BuildContext context) {
    return FilledButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          FlashcardStudySessionTokens.fillActionButtonRadius,
        ),
      ),
    );
  }

  ButtonStyle _resolveCheckButtonStyle(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return FilledButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          FlashcardStudySessionTokens.fillActionButtonRadius,
        ),
      ),
      disabledForegroundColor: colorScheme.onSurface.withValues(
        alpha: FlashcardStudySessionTokens.fillCheckDisabledContentOpacity,
      ),
      disabledBackgroundColor: colorScheme.onSurface.withValues(
        alpha: FlashcardStudySessionTokens.fillCheckDisabledContainerOpacity,
      ),
    );
  }
}

class _FillPromptCard extends StatelessWidget {
  const _FillPromptCard({required this.unit, required this.opacity});

  final FillUnit unit;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      variant: AppCardVariant.elevated,
      elevation: FlashcardStudySessionTokens.cardElevation,
      backgroundColor: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(
        FlashcardStudySessionTokens.cardRadius,
      ),
      padding: const EdgeInsets.all(FlashcardStudySessionTokens.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Spacer(),
              Icon(
                Icons.edit_outlined,
                size: FlashcardStudySessionTokens.fillPromptIconSize,
                color: colorScheme.onSurfaceVariant.withValues(
                  alpha: FlashcardStudySessionTokens.fillPromptIconOpacity,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: FlashcardStudySessionTokens.reviewCardActionTopGap,
          ),
          Expanded(
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(
                milliseconds:
                    FlashcardStudySessionTokens.fillPromptOpacityAnimationMs,
              ),
              child: Center(
                child: Text(
                  unit.prompt,
                  textAlign: TextAlign.center,
                  maxLines: FlashcardStudySessionTokens.fillPromptMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FillInputCard extends StatelessWidget {
  const _FillInputCard({
    required this.fillController,
    required this.onSubmitPressed,
  });

  final TextEditingController fillController;
  final VoidCallback onSubmitPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      variant: AppCardVariant.elevated,
      elevation: FlashcardStudySessionTokens.cardElevation,
      backgroundColor: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(
        FlashcardStudySessionTokens.cardRadius,
      ),
      padding: const EdgeInsets.all(FlashcardStudySessionTokens.cardPadding),
      child: Center(
        child: AppTextField(
          controller: fillController,
          onSubmitted: (_) => onSubmitPressed(),
          maxLines: FlashcardStudySessionTokens.fillInputMaxLines,
          minLines: FlashcardStudySessionTokens.fillInputMaxLines,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          variant: InputFieldVariant.filled,
          fillColor: colorScheme.surfaceContainerHigh,
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(
              alpha: FlashcardStudySessionTokens.fillInputHintOpacity,
            ),
          ),
        ),
      ),
    );
  }
}
