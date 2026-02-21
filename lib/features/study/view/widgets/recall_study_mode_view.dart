// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/styles/app_opacities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../model/study_constants.dart';
import '../../model/study_unit.dart';

class RecallStudyModeView extends HookWidget {
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
    final ValueNotifier<int> remainingSecondsNotifier = useState<int>(
      StudyConstants.recallRevealCountdownSeconds,
    );
    final ValueNotifier<bool> isAnswerRevealedNotifier = useState<bool>(false);
    final ObjectRef<Timer?> countdownTimerRef = useRef<Timer?>(null);

    void revealAnswer() {
      if (isAnswerRevealedNotifier.value) {
        return;
      }
      isAnswerRevealedNotifier.value = true;
      countdownTimerRef.value?.cancel();
      countdownTimerRef.value = null;
    }

    void onCountdownTick(Timer timer) {
      if (isAnswerRevealedNotifier.value) {
        timer.cancel();
        return;
      }
      final int remainingSeconds = remainingSecondsNotifier.value;
      if (remainingSeconds <= 1) {
        remainingSecondsNotifier.value = 0;
        revealAnswer();
        return;
      }
      remainingSecondsNotifier.value = remainingSeconds - 1;
    }

    void startCountdown() {
      countdownTimerRef.value?.cancel();
      countdownTimerRef.value = Timer.periodic(
        const Duration(milliseconds: StudyConstants.secondDurationInMs),
        onCountdownTick,
      );
    }

    useEffect(() {
      remainingSecondsNotifier.value =
          StudyConstants.recallRevealCountdownSeconds;
      isAnswerRevealedNotifier.value = false;
      startCountdown();
      return () {
        countdownTimerRef.value?.cancel();
        countdownTimerRef.value = null;
      };
    }, <Object>[unit.unitId]);

    return ValueListenableBuilder<bool>(
      valueListenable: isAnswerRevealedNotifier,
      builder: (context, isAnswerRevealed, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: FlashcardStudySessionTokens.recallPromptFlex,
              child: _RecallCard(
                text: unit.prompt,
                textStyle: Theme.of(context).textTheme.headlineMedium,
                maxLines: FlashcardStudySessionTokens.recallPromptMaxLines,
                opacity: 1,
              ),
            ),
            const SizedBox(height: FlashcardStudySessionTokens.recallCardGap),
            Expanded(
              flex: FlashcardStudySessionTokens.recallAnswerFlex,
              child: _RecallCard(
                text: _resolveRecallAnswerText(
                  answer: unit.answer,
                  isAnswerRevealed: isAnswerRevealed,
                ),
                textStyle: Theme.of(context).textTheme.titleMedium,
                maxLines: FlashcardStudySessionTokens.recallAnswerMaxLines,
                opacity: _resolveRecallAnswerOpacity(
                  isAnswerRevealed: isAnswerRevealed,
                ),
              ),
            ),
            const SizedBox(height: FlashcardStudySessionTokens.recallCardGap),
            Padding(
              padding: const EdgeInsets.only(
                bottom: FlashcardStudySessionTokens.recallButtonBottomGap,
              ),
              child: isAnswerRevealed
                  ? _buildRecallResultActions(
                      l10n: l10n,
                      onMissedPressed: onMissedPressed,
                      onRememberedPressed: onRememberedPressed,
                    )
                  : _buildRecallShowButton(
                      l10n: l10n,
                      remainingSecondsNotifier: remainingSecondsNotifier,
                      onRevealPressed: revealAnswer,
                    ),
            ),
          ],
        );
      },
    );
  }
}

String _resolveRecallAnswerText({
  required String answer,
  required bool isAnswerRevealed,
}) {
  if (isAnswerRevealed) {
    return answer;
  }
  return '';
}

double _resolveRecallAnswerOpacity({required bool isAnswerRevealed}) {
  if (isAnswerRevealed) {
    return 1;
  }
  return AppOpacities.muted55;
}

Widget _buildRecallShowButton({
  required AppLocalizations l10n,
  required ValueNotifier<int> remainingSecondsNotifier,
  required VoidCallback onRevealPressed,
}) {
  return Align(
    alignment: Alignment.center,
    child: FractionallySizedBox(
      widthFactor: FlashcardStudySessionTokens.recallButtonWidthFactor,
      child: SizedBox(
        height: FlashcardStudySessionTokens.recallButtonHeight,
        child: FilledButton(
          onPressed: onRevealPressed,
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
          child: ValueListenableBuilder<int>(
            valueListenable: remainingSecondsNotifier,
            builder: (context, remainingSeconds, child) {
              return Text(
                l10n.flashcardsStudyRecallShowCountdownLabel(remainingSeconds),
              );
            },
          ),
        ),
      ),
    ),
  );
}

Widget _buildRecallResultActions({
  required AppLocalizations l10n,
  required VoidCallback onMissedPressed,
  required VoidCallback onRememberedPressed,
}) {
  return Align(
    alignment: Alignment.center,
    child: FractionallySizedBox(
      widthFactor: FlashcardStudySessionTokens.recallActionButtonsWidthFactor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: SizedBox(
              height: FlashcardStudySessionTokens.recallButtonHeight,
              child: OutlinedButton(
                onPressed: onMissedPressed,
                child: Text(l10n.flashcardsStudyRecallMissedLabel),
              ),
            ),
          ),
          const SizedBox(
            width: FlashcardStudySessionTokens.recallActionButtonsGap,
          ),
          Expanded(
            child: SizedBox(
              height: FlashcardStudySessionTokens.recallButtonHeight,
              child: FilledButton(
                onPressed: onRememberedPressed,
                style: FilledButton.styleFrom(shape: const StadiumBorder()),
                child: Text(l10n.flashcardsStudyRecallRememberedLabel),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RecallCard extends StatelessWidget {
  const _RecallCard({
    required this.text,
    required this.textStyle,
    required this.maxLines,
    required this.opacity,
  });

  final String text;
  final TextStyle? textStyle;
  final int maxLines;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final TextStyle? resolvedTextStyle = textStyle?.copyWith(
      fontWeight: FontWeight.normal,
    );
    return Opacity(
      opacity: opacity,
      child: LwCard(
        variant: AppCardVariant.elevated,
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
            style: resolvedTextStyle,
          ),
        ),
      ),
    );
  }
}
