import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../model/study_unit.dart';

class RecallStudyModeView extends StatelessWidget {
  const RecallStudyModeView({
    required this.unit,
    required this.onMissedPressed,
    required this.onRememberedPressed,
    required this.l10n,
    super.key,
  });

  final RecallUnit unit;
  final VoidCallback onMissedPressed;
  final VoidCallback onRememberedPressed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: FlashcardStudySessionTokens.recallPromptFlex,
          child: _RecallCard(
            text: unit.prompt,
            textStyle: Theme.of(context).textTheme.headlineMedium,
            maxLines: FlashcardStudySessionTokens.recallPromptMaxLines,
          ),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.recallCardGap),
        Expanded(
          flex: FlashcardStudySessionTokens.recallAnswerFlex,
          child: Opacity(
            opacity: FlashcardStudySessionTokens.recallAnswerOpacity,
            child: _RecallCard(
              text: unit.answer,
              textStyle: Theme.of(context).textTheme.titleMedium,
              maxLines: FlashcardStudySessionTokens.recallAnswerMaxLines,
            ),
          ),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.recallCardGap),
        Padding(
          padding: const EdgeInsets.only(
            bottom: FlashcardStudySessionTokens.recallButtonBottomGap,
          ),
          child: Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: FlashcardStudySessionTokens.recallButtonWidthFactor,
              child: SizedBox(
                height: FlashcardStudySessionTokens.recallButtonHeight,
                child: FilledButton(
                  onPressed: onRememberedPressed,
                  onLongPress: onMissedPressed,
                  style: FilledButton.styleFrom(shape: const StadiumBorder()),
                  child: Text(l10n.flashcardsStudyRecallRememberedLabel),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecallCard extends StatelessWidget {
  const _RecallCard({
    required this.text,
    required this.textStyle,
    required this.maxLines,
  });

  final String text;
  final TextStyle? textStyle;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      elevation: FlashcardStudySessionTokens.cardElevation,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(
        FlashcardStudySessionTokens.cardRadius,
      ),
      padding: const EdgeInsets.all(FlashcardStudySessionTokens.cardPadding),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
      ),
    );
  }
}
