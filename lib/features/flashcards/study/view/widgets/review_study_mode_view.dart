import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_durations.dart';
import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../model/study_unit.dart';
import '../../viewmodel/study_session_viewmodel.dart';

const String _reviewMeaningNoteSeparator = ' / ';

class ReviewStudyModeView extends StatefulWidget {
  const ReviewStudyModeView({
    required this.units,
    required this.state,
    required this.controller,
    required this.l10n,
    super.key,
  });

  final List<ReviewUnit> units;
  final StudySessionState state;
  final StudySessionController controller;
  final AppLocalizations l10n;

  @override
  State<ReviewStudyModeView> createState() => _ReviewStudyModeViewState();
}

class _ReviewStudyModeViewState extends State<ReviewStudyModeView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.state.currentIndex);
  }

  @override
  void didUpdateWidget(covariant ReviewStudyModeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_pageController.hasClients) {
      return;
    }
    final int nextIndex = widget.state.currentIndex;
    final int currentPage = _pageController.page?.round() ?? nextIndex;
    if (currentPage == nextIndex) {
      return;
    }
    unawaited(
      _pageController.animateToPage(
        nextIndex,
        duration: AppDurations.animationStandard,
        curve: AppMotionCurves.standard,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.units.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(
              parent: PageScrollPhysics(),
            ),
            itemCount: widget.units.length,
            onPageChanged: widget.controller.goTo,
            itemBuilder: (context, index) {
              final ReviewUnit unit = widget.units[index];
              final bool isPlayingAudio =
                  widget.state.playingFlashcardId == unit.flashcardId;
              return _ReviewPage(
                unit: unit,
                l10n: widget.l10n,
                isPlayingAudio: isPlayingAudio,
                onAudioPressed: () {
                  widget.controller.playAudioFor(unit.flashcardId);
                },
              );
            },
          ),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    widget.state.canGoPrevious ? widget.controller.previous : null,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(widget.l10n.flashcardsPreviousTooltip),
              ),
            ),
            const SizedBox(width: FlashcardStudySessionTokens.bottomActionGap),
            Expanded(
              child: FilledButton.icon(
                onPressed: widget.state.canGoNext ? widget.controller.next : null,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(widget.l10n.flashcardsNextTooltip),
              ),
            ),
          ],
        ),
        const SizedBox(height: FlashcardStudySessionTokens.reviewBodyBottomGap),
      ],
    );
  }
}

class _ReviewPage extends StatelessWidget {
  const _ReviewPage({
    required this.unit,
    required this.l10n,
    required this.isPlayingAudio,
    required this.onAudioPressed,
  });

  final ReviewUnit unit;
  final AppLocalizations l10n;
  final bool isPlayingAudio;
  final VoidCallback onAudioPressed;

  @override
  Widget build(BuildContext context) {
    final String? normalizedNote = StringUtils.normalizeNullable(unit.note);
    final String meaningDisplayText = _resolveMeaningDisplayText(
      meaningText: unit.backText,
      note: normalizedNote,
    );
    return Column(
      key: ValueKey<int>(unit.flashcardId),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: _ReviewCardFace(
            text: meaningDisplayText,
            textStyle: Theme.of(context).textTheme.titleLarge,
            actionIcon: Icons.edit_outlined,
            selectedActionIcon: Icons.edit_outlined,
            tooltip: l10n.flashcardsEditTooltip,
            onActionPressed: () {},
          ),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
        Expanded(
          child: _ReviewCardFace(
            text: unit.frontText,
            textStyle: Theme.of(context).textTheme.headlineMedium,
            actionIcon: Icons.volume_up_outlined,
            selectedActionIcon: Icons.graphic_eq_rounded,
            tooltip: l10n.flashcardsPlayAudioTooltip,
            isActionSelected: isPlayingAudio,
            onActionPressed: onAudioPressed,
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(FlashcardStudySessionTokens.cardRadius),
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
                  minWidth: FlashcardStudySessionTokens.reviewAppBarIconTapTarget,
                  minHeight: FlashcardStudySessionTokens.reviewAppBarIconTapTarget,
                ),
                icon: Icon(actionIcon),
                selectedIcon: Icon(selectedActionIcon),
              ),
            ],
          ),
          const SizedBox(height: FlashcardStudySessionTokens.reviewCardActionTopGap),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: textStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
