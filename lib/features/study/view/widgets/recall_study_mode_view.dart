import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../model/study_constants.dart';
import '../../model/study_unit.dart';

class RecallStudyModeView extends StatefulWidget {
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
  State<RecallStudyModeView> createState() => _RecallStudyModeViewState();
}

class _RecallStudyModeViewState extends State<RecallStudyModeView> {
  late final ValueNotifier<int> _remainingSecondsNotifier;
  late final ValueNotifier<bool> _isAnswerRevealedNotifier;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _remainingSecondsNotifier = ValueNotifier<int>(
      StudyConstants.recallRevealCountdownSeconds,
    );
    _isAnswerRevealedNotifier = ValueNotifier<bool>(false);
    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant RecallStudyModeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unit.unitId == widget.unit.unitId) {
      return;
    }
    _resetCountdownForNextUnit();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _remainingSecondsNotifier.dispose();
    _isAnswerRevealedNotifier.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(milliseconds: StudyConstants.secondDurationInMs),
      _onCountdownTick,
    );
  }

  void _onCountdownTick(Timer timer) {
    if (_isAnswerRevealedNotifier.value) {
      timer.cancel();
      return;
    }
    final int remainingSeconds = _remainingSecondsNotifier.value;
    if (remainingSeconds <= 1) {
      _remainingSecondsNotifier.value = 0;
      _revealAnswer();
      return;
    }
    _remainingSecondsNotifier.value = remainingSeconds - 1;
  }

  void _resetCountdownForNextUnit() {
    _countdownTimer?.cancel();
    _remainingSecondsNotifier.value =
        StudyConstants.recallRevealCountdownSeconds;
    _isAnswerRevealedNotifier.value = false;
    _startCountdown();
  }

  void _revealAnswer() {
    if (_isAnswerRevealedNotifier.value) {
      return;
    }
    _isAnswerRevealedNotifier.value = true;
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isAnswerRevealedNotifier,
      builder: (context, isAnswerRevealed, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: FlashcardStudySessionTokens.recallPromptFlex,
              child: _RecallCard(
                text: widget.unit.prompt,
                textStyle: Theme.of(context).textTheme.headlineMedium,
                maxLines: FlashcardStudySessionTokens.recallPromptMaxLines,
                opacity: 1,
              ),
            ),
            const SizedBox(height: FlashcardStudySessionTokens.recallCardGap),
            Expanded(
              flex: FlashcardStudySessionTokens.recallAnswerFlex,
              child: _RecallCard(
                text: _resolveAnswerText(isAnswerRevealed: isAnswerRevealed),
                textStyle: Theme.of(context).textTheme.titleMedium,
                maxLines: FlashcardStudySessionTokens.recallAnswerMaxLines,
                opacity: _resolveAnswerOpacity(
                  isAnswerRevealed: isAnswerRevealed,
                ),
              ),
            ),
            const SizedBox(height: FlashcardStudySessionTokens.recallCardGap),
            Padding(
              padding: const EdgeInsets.only(
                bottom: FlashcardStudySessionTokens.recallButtonBottomGap,
              ),
              child: _buildBottomActions(isAnswerRevealed: isAnswerRevealed),
            ),
          ],
        );
      },
    );
  }

  String _resolveAnswerText({required bool isAnswerRevealed}) {
    if (isAnswerRevealed) {
      return widget.unit.answer;
    }
    return '';
  }

  double _resolveAnswerOpacity({required bool isAnswerRevealed}) {
    if (isAnswerRevealed) {
      return 1;
    }
    return FlashcardStudySessionTokens.recallAnswerOpacity;
  }

  Widget _buildBottomActions({required bool isAnswerRevealed}) {
    if (isAnswerRevealed) {
      return _buildRecallResultActions();
    }
    return _buildShowButton();
  }

  Widget _buildShowButton() {
    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: FlashcardStudySessionTokens.recallButtonWidthFactor,
        child: SizedBox(
          height: FlashcardStudySessionTokens.recallButtonHeight,
          child: FilledButton(
            onPressed: _revealAnswer,
            style: FilledButton.styleFrom(shape: const StadiumBorder()),
            child: ValueListenableBuilder<int>(
              valueListenable: _remainingSecondsNotifier,
              builder: (context, remainingSeconds, child) {
                return Text(
                  widget.l10n.flashcardsStudyRecallShowCountdownLabel(
                    remainingSeconds,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecallResultActions() {
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
                  onPressed: widget.onMissedPressed,
                  child: Text(widget.l10n.flashcardsStudyRecallMissedLabel),
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
                  onPressed: widget.onRememberedPressed,
                  style: FilledButton.styleFrom(shape: const StadiumBorder()),
                  child: Text(widget.l10n.flashcardsStudyRecallRememberedLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      child: AppCard(
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
            style: resolvedTextStyle,
          ),
        ),
      ),
    );
  }
}
