import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';

class ReviewStudyModeView extends StatelessWidget {
  const ReviewStudyModeView({
    required this.unit,
    required this.state,
    required this.controller,
    required this.l10n,
    super.key,
  });

  final ReviewUnit unit;
  final StudySessionState state;
  final StudySessionController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final String? normalizedNote = StringUtils.normalizeNullable(unit.note);
    final bool isPlayingAudio = state.playingFlashcardId == unit.flashcardId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: FlashcardStudySessionTokens.reviewCardMinHeight,
          ),
          child: _ReviewCardFace(
            termText: unit.frontText,
            meaningText: unit.backText,
            note: normalizedNote,
            isPlayingAudio: isPlayingAudio,
            onAudioPressed: controller.playCurrentAudio,
          ),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: state.canGoPrevious ? controller.previous : null,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(l10n.flashcardsPreviousTooltip),
              ),
            ),
            const SizedBox(width: FlashcardStudySessionTokens.bottomActionGap),
            Expanded(
              child: FilledButton.icon(
                onPressed: state.canGoNext ? controller.next : null,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(l10n.flashcardsNextTooltip),
              ),
            ),
          ],
        ),
        const SizedBox(height: FlashcardStudySessionTokens.reviewBodyBottomGap),
      ],
    );
  }
}

class _ReviewCardFace extends StatelessWidget {
  const _ReviewCardFace({
    required this.termText,
    required this.meaningText,
    required this.note,
    required this.isPlayingAudio,
    required this.onAudioPressed,
  });

  final String termText;
  final String meaningText;
  final String? note;
  final bool isPlayingAudio;
  final VoidCallback onAudioPressed;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Spacer(),
              IconButton(
                isSelected: isPlayingAudio,
                onPressed: onAudioPressed,
                tooltip: AppLocalizations.of(
                  context,
                )!.flashcardsPlayAudioTooltip,
                iconSize: FlashcardStudySessionTokens.iconSize,
                constraints: const BoxConstraints(
                  minWidth:
                      FlashcardStudySessionTokens.reviewAppBarIconTapTarget,
                  minHeight:
                      FlashcardStudySessionTokens.reviewAppBarIconTapTarget,
                ),
                icon: const Icon(Icons.volume_up_outlined),
                selectedIcon: const Icon(Icons.graphic_eq_rounded),
              ),
            ],
          ),
          const SizedBox(
            height: FlashcardStudySessionTokens.reviewCardActionTopGap,
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    termText,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(
                    height: FlashcardStudySessionTokens.sectionSpacing,
                  ),
                  Text(
                    meaningText,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (note != null) ...<Widget>[
                    const SizedBox(
                      height: FlashcardStudySessionTokens.answerSpacing,
                    ),
                    Text(
                      note!,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
