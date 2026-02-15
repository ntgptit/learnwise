import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../model/study_unit.dart';

class FillStudyModeView extends StatefulWidget {
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
  State<FillStudyModeView> createState() => _FillStudyModeViewState();
}

class _FillStudyModeViewState extends State<FillStudyModeView> {
  late final ValueNotifier<String?> _helpAnswerNotifier;

  @override
  void initState() {
    super.initState();
    _helpAnswerNotifier = ValueNotifier<String?>(null);
  }

  @override
  void didUpdateWidget(covariant FillStudyModeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unit.unitId == widget.unit.unitId) {
      return;
    }
    _helpAnswerNotifier.value = null;
  }

  @override
  void dispose() {
    _helpAnswerNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final double promptOpacity = _resolvePromptOpacity(isKeyboardVisible);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: _FillPromptCard(unit: widget.unit, opacity: promptOpacity),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.fillCardGap),
        Expanded(
          flex: 1,
          child: _FillInputCard(
            fillController: widget.fillController,
            onSubmitPressed: _submitCurrentAnswer,
            helpAnswerListenable: _helpAnswerNotifier,
          ),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.fillActionTopGap),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(
            bottom: FlashcardStudySessionTokens.fillActionBottomPadding,
          ),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.fillController,
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
                        child: Text(widget.l10n.flashcardsStudyFillHelpLabel),
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
                        child: Text(widget.l10n.flashcardsStudyFillCheckLabel),
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

  double _resolvePromptOpacity(bool isKeyboardVisible) {
    if (isKeyboardVisible) {
      return FlashcardStudySessionTokens.fillPromptCardFocusedOpacity;
    }
    return FlashcardStudySessionTokens.fillPromptCardDefaultOpacity;
  }

  void _onHelpPressed() {
    _helpAnswerNotifier.value = widget.unit.expectedAnswer;
    widget.fillController.text = widget.unit.expectedAnswer;
    widget.fillController.selection = TextSelection.collapsed(
      offset: widget.unit.expectedAnswer.length,
    );
  }

  void _submitCurrentAnswer() {
    final String normalizedAnswer = widget.fillController.text.normalized;
    if (normalizedAnswer.isEmpty) {
      return;
    }
    widget.onSubmitAnswer(normalizedAnswer);
    widget.fillController.clear();
    _helpAnswerNotifier.value = null;
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
    required this.helpAnswerListenable,
  });

  final TextEditingController fillController;
  final VoidCallback onSubmitPressed;
  final ValueNotifier<String?> helpAnswerListenable;

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
      child: ValueListenableBuilder<String?>(
        valueListenable: helpAnswerListenable,
        builder: (context, helpAnswer, child) {
          if (helpAnswer != null) {
            return Center(
              child: Text(
                helpAnswer,
                textAlign: TextAlign.center,
                maxLines: FlashcardStudySessionTokens.fillPromptMaxLines,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            );
          }
          return Center(
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
          );
        },
      ),
    );
  }
}
