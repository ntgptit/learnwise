// quality-guard: allow-large-file - phase2 legacy backlog tracked for file modularization.
// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../model/study_constants.dart';
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
  final ValueNotifier<String?> _helpAnswerNotifier = ValueNotifier<String?>(
    null,
  );
  final ValueNotifier<_FillWrongAnswerFeedback?> _wrongAnswerNotifier =
      ValueNotifier<_FillWrongAnswerFeedback?>(null);
  final FocusNode _fillInputFocusNode = FocusNode(debugLabel: 'fill_input');

  @override
  void didUpdateWidget(covariant FillStudyModeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unit.unitId == widget.unit.unitId) {
      return;
    }
    _helpAnswerNotifier.value = null;
    _wrongAnswerNotifier.value = null;
  }

  @override
  void dispose() {
    _helpAnswerNotifier.dispose();
    _wrongAnswerNotifier.dispose();
    _fillInputFocusNode.dispose();
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
            fillInputFocusNode: _fillInputFocusNode,
            onSubmitPressed: _submitCurrentAnswer,
            helpAnswerListenable: _helpAnswerNotifier,
            wrongAnswerListenable: _wrongAnswerNotifier,
          ),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.fillActionTopGap),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(
            bottom: FlashcardStudySessionTokens.fillActionBottomPadding,
          ),
          child: ValueListenableBuilder<_FillWrongAnswerFeedback?>(
            valueListenable: _wrongAnswerNotifier,
            builder: (context, wrongAnswerFeedback, child) {
              final bool isAwaitingConfirm = wrongAnswerFeedback != null;
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.fillController,
                builder: (context, value, child) {
                  final bool canSubmit = StringUtils.normalize(
                    value.text,
                  ).isNotEmpty;
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: FlashcardStudySessionTokens
                              .fillActionButtonHeight,
                          child: FilledButton(
                            onPressed: _resolveHelpButtonHandler(
                              isAwaitingConfirm: isAwaitingConfirm,
                            ),
                            style: _resolveActionButtonStyle(context),
                            child: Text(
                              widget.l10n.flashcardsStudyFillHelpLabel,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: FlashcardStudySessionTokens.bottomActionGap,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: FlashcardStudySessionTokens
                              .fillActionButtonHeight,
                          child: FilledButton(
                            onPressed: _resolveCheckButtonHandler(
                              canSubmit: canSubmit,
                              isAwaitingConfirm: isAwaitingConfirm,
                            ),
                            style: _resolveCheckButtonStyle(context),
                            child: Text(
                              _resolveCheckButtonLabel(
                                isAwaitingConfirm: isAwaitingConfirm,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
    _wrongAnswerNotifier.value = null;
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
    final bool isCorrect = _isFillAnswerCorrect(
      actual: normalizedAnswer,
      expected: widget.unit.expectedAnswer,
    );
    if (isCorrect) {
      _helpAnswerNotifier.value = null;
      _wrongAnswerNotifier.value = null;
      widget.onSubmitAnswer(normalizedAnswer);
      return;
    }
    _helpAnswerNotifier.value = null;
    _wrongAnswerNotifier.value = _FillWrongAnswerFeedback(
      actualText: normalizedAnswer,
      expectedText: StringUtils.normalize(widget.unit.expectedAnswer),
    );
    widget.onSubmitAnswer(normalizedAnswer);
  }

  void _confirmIncorrectAndAdvance() {
    final _FillWrongAnswerFeedback? feedback = _wrongAnswerNotifier.value;
    if (feedback == null) {
      return;
    }
    _wrongAnswerNotifier.value = null;
    _helpAnswerNotifier.value = null;
    widget.fillController.clear();
    _fillInputFocusNode.requestFocus();
  }

  bool _isFillAnswerCorrect({
    required String actual,
    required String expected,
  }) {
    final String normalizedActual = StringUtils.normalizeLower(actual);
    final String normalizedExpected = StringUtils.normalizeLower(expected);
    if (normalizedActual.isEmpty) {
      return false;
    }
    return normalizedActual == normalizedExpected;
  }

  VoidCallback? _resolveHelpButtonHandler({required bool isAwaitingConfirm}) {
    if (isAwaitingConfirm) {
      return null;
    }
    return _onHelpPressed;
  }

  VoidCallback? _resolveCheckButtonHandler({
    required bool canSubmit,
    required bool isAwaitingConfirm,
  }) {
    if (isAwaitingConfirm) {
      return _confirmIncorrectAndAdvance;
    }
    if (!canSubmit) {
      return null;
    }
    return _submitCurrentAnswer;
  }

  String _resolveCheckButtonLabel({required bool isAwaitingConfirm}) {
    if (isAwaitingConfirm) {
      return widget.l10n.flashcardsStudyFillContinueLabel;
    }
    return widget.l10n.flashcardsStudyFillCheckLabel;
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
                    fontWeight: FontWeight.normal,
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
    required this.fillInputFocusNode,
    required this.onSubmitPressed,
    required this.helpAnswerListenable,
    required this.wrongAnswerListenable,
  });

  final TextEditingController fillController;
  final FocusNode fillInputFocusNode;
  final VoidCallback onSubmitPressed;
  final ValueNotifier<String?> helpAnswerListenable;
  final ValueNotifier<_FillWrongAnswerFeedback?> wrongAnswerListenable;

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
          return ValueListenableBuilder<_FillWrongAnswerFeedback?>(
            valueListenable: wrongAnswerListenable,
            builder: (context, wrongAnswerFeedback, child) {
              if (wrongAnswerFeedback != null) {
                return Center(
                  child: _FillWrongAnswerHighlightedText(
                    feedback: wrongAnswerFeedback,
                  ),
                );
              }
              if (helpAnswer != null) {
                return Center(
                  child: Text(
                    helpAnswer,
                    textAlign: TextAlign.center,
                    maxLines: FlashcardStudySessionTokens.fillPromptMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                );
              }
              return Center(
                child: AppTextField(
                  controller: fillController,
                  focusNode: fillInputFocusNode,
                  onSubmitted: (_) => onSubmitPressed(),
                  maxLines: FlashcardStudySessionTokens.fillInputMaxLines,
                  minLines: FlashcardStudySessionTokens.fillInputMaxLines,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  hint: AppLocalizations.of(
                    context,
                  )!.flashcardsStudyFillInputHint,
                  variant: InputFieldVariant.filled,
                  fillColor: colorScheme.surfaceContainerHigh,
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.normal,
                  ),
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(
                      alpha: FlashcardStudySessionTokens.fillInputHintOpacity,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FillWrongAnswerHighlightedText extends StatelessWidget {
  const _FillWrongAnswerHighlightedText({required this.feedback});

  final _FillWrongAnswerFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextStyle baseStyle =
        theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.normal,
        ) ??
        TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.normal);
    final TextStyle errorStyle = baseStyle.copyWith(color: colorScheme.error);
    final TextStyle missingStyle = errorStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: colorScheme.error,
    );
    final List<InlineSpan> spans = _buildHighlightedSpans(
      actual: feedback.actualText,
      expected: feedback.expectedText,
      baseStyle: baseStyle,
      errorStyle: errorStyle,
      missingStyle: missingStyle,
    );
    return Semantics(
      label: feedback.expectedText,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(children: spans),
          textAlign: TextAlign.center,
          maxLines: FlashcardStudySessionTokens.fillPromptMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  List<InlineSpan> _buildHighlightedSpans({
    required String actual,
    required String expected,
    required TextStyle baseStyle,
    required TextStyle errorStyle,
    required TextStyle missingStyle,
  }) {
    final String normalizedActual = StringUtils.normalize(actual);
    final String normalizedExpected = StringUtils.normalize(expected);
    final String actualLower = StringUtils.toLower(normalizedActual);
    final String expectedLower = StringUtils.toLower(normalizedExpected);

    int minLength = actualLower.length;
    if (expectedLower.length < minLength) {
      minLength = expectedLower.length;
    }

    int mismatchIndex = minLength;
    int index = StudyConstants.defaultIndex;
    while (index < minLength) {
      if (actualLower[index] != expectedLower[index]) {
        mismatchIndex = index;
        break;
      }
      index++;
    }

    if (actualLower.length == expectedLower.length &&
        mismatchIndex == minLength) {
      return <InlineSpan>[TextSpan(text: normalizedActual, style: baseStyle)];
    }

    final List<InlineSpan> spans = <InlineSpan>[];
    final String correctPrefix = StringUtils.slice(
      normalizedActual,
      start: StudyConstants.defaultIndex,
      end: mismatchIndex,
    );
    if (correctPrefix.isNotEmpty) {
      spans.add(TextSpan(text: correctPrefix, style: baseStyle));
    }

    final String wrongSuffix = StringUtils.slice(
      normalizedActual,
      start: mismatchIndex,
    );
    if (wrongSuffix.isNotEmpty) {
      spans.add(TextSpan(text: wrongSuffix, style: errorStyle));
    }

    if (normalizedExpected.length > normalizedActual.length) {
      final String missingSuffix = StringUtils.slice(
        normalizedExpected,
        start: normalizedActual.length,
      );
      if (missingSuffix.isNotEmpty) {
        spans.add(TextSpan(text: missingSuffix, style: missingStyle));
      }
    }
    return spans;
  }
}

class _FillWrongAnswerFeedback {
  const _FillWrongAnswerFeedback({
    required this.actualText,
    required this.expectedText,
  });

  final String actualText;
  final String expectedText;
}
