import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';

const String _reviewMeaningNoteSeparator = ' / ';

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
    final String meaningDisplayText = _resolveMeaningDisplayText(
      meaningText: unit.backText,
      note: normalizedNote,
    );
    final String topCardText = _resolveTopCardText(
      isFrontVisible: state.isFrontVisible,
      termText: unit.frontText,
      meaningDisplayText: meaningDisplayText,
    );
    final String bottomCardText = _resolveBottomCardText(
      isFrontVisible: state.isFrontVisible,
      termText: unit.frontText,
      meaningDisplayText: meaningDisplayText,
    );
    final bool isPlayingAudio = state.playingFlashcardId == unit.flashcardId;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final double? primaryVelocity = details.primaryVelocity;
        if (primaryVelocity == null) {
          return;
        }
        if (primaryVelocity > 0) {
          controller.previous();
          return;
        }
        controller.next();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _ReviewCardFace(
              text: topCardText,
              textStyle: Theme.of(context).textTheme.titleLarge,
              actionIcon: Icons.edit_outlined,
              selectedActionIcon: Icons.edit_outlined,
              tooltip: l10n.flashcardsEditTooltip,
              onActionPressed: controller.submitFlip,
            ),
          ),
          const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
          Expanded(
            child: _ReviewCardFace(
              text: bottomCardText,
              textStyle: Theme.of(context).textTheme.headlineMedium,
              actionIcon: Icons.volume_up_outlined,
              selectedActionIcon: Icons.graphic_eq_rounded,
              tooltip: l10n.flashcardsPlayAudioTooltip,
              isActionSelected: isPlayingAudio,
              onActionPressed: controller.playCurrentAudio,
            ),
          ),
          const SizedBox(
            height: FlashcardStudySessionTokens.reviewBodyBottomGap,
          ),
        ],
      ),
    );
  }
}

String _resolveMeaningDisplayText({
  required String meaningText,
  required String? note,
}) {
  if (note == null) {
    return meaningText;
  }
  return '$meaningText$_reviewMeaningNoteSeparator$note';
}

String _resolveTopCardText({
  required bool isFrontVisible,
  required String termText,
  required String meaningDisplayText,
}) {
  if (isFrontVisible) {
    return meaningDisplayText;
  }
  return termText;
}

String _resolveBottomCardText({
  required bool isFrontVisible,
  required String termText,
  required String meaningDisplayText,
}) {
  if (isFrontVisible) {
    return termText;
  }
  return meaningDisplayText;
}

class _ReviewCardFace extends StatelessWidget {
  const _ReviewCardFace({
    required this.text,
    required this.textStyle,
    required this.actionIcon,
    required this.selectedActionIcon,
    required this.tooltip,
    required this.onActionPressed,
    this.isActionSelected = false,
  });

  final String text;
  final TextStyle? textStyle;
  final IconData actionIcon;
  final IconData selectedActionIcon;
  final String tooltip;
  final bool isActionSelected;
  final VoidCallback onActionPressed;

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
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Spacer(),
              IconButton(
                isSelected: isActionSelected,
                onPressed: onActionPressed,
                tooltip: tooltip,
                iconSize: FlashcardStudySessionTokens.iconSize,
                constraints: const BoxConstraints(
                  minWidth:
                      FlashcardStudySessionTokens.reviewAppBarIconTapTarget,
                  minHeight:
                      FlashcardStudySessionTokens.reviewAppBarIconTapTarget,
                ),
                icon: Icon(actionIcon),
                selectedIcon: Icon(selectedActionIcon),
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
                    text,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: textStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
