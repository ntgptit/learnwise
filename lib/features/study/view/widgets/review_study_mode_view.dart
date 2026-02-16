import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_durations.dart';
import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../core/utils/string_utils.dart';
import '../../model/study_unit.dart';

const String _reviewMeaningNoteSeparator = ' / ';
const double _reviewWebWheelDeltaThreshold = 8;

class ReviewStudyModeView extends StatefulWidget {
  const ReviewStudyModeView({
    required this.units,
    required this.currentIndex,
    required this.playingFlashcardId,
    required this.onPageChanged,
    required this.onAudioPressedFor,
    required this.onNext,
    required this.onPrevious,
    required this.l10n,
    super.key,
  });

  final List<ReviewUnit> units;
  final int currentIndex;
  final int? playingFlashcardId;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onAudioPressedFor;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final AppLocalizations l10n;

  @override
  State<ReviewStudyModeView> createState() => _ReviewStudyModeViewState();
}

class _ReviewStudyModeViewState extends State<ReviewStudyModeView> {
  late final PageController _pageController;
  late final FocusNode _focusNode;
  bool _isPageAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.currentIndex,
      viewportFraction: FlashcardStudySessionTokens.reviewPageViewportFraction,
    );
    _focusNode = FocusNode(debugLabel: 'review_mode_focus');
  }

  @override
  void didUpdateWidget(covariant ReviewStudyModeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_pageController.hasClients) {
      return;
    }
    final int nextIndex = widget.currentIndex;
    final int currentPage = _pageController.page?.round() ?? nextIndex;
    if (currentPage == nextIndex) {
      return;
    }
    if (_isPageAnimating) {
      return;
    }
    _isPageAnimating = true;
    unawaited(
      _pageController
          .animateToPage(
            nextIndex,
            duration: AppDurations.animationStandard,
            curve: AppMotionCurves.standard,
          )
          .whenComplete(() {
            _isPageAnimating = false;
          }),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
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
          child: Focus(
            autofocus: true,
            focusNode: _focusNode,
            onKeyEvent: _onKeyEvent,
            child: Listener(
              onPointerSignal: _onPointerSignal,
              child: ScrollConfiguration(
                behavior: const _ReviewWebScrollBehavior(),
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(
                    parent: PageScrollPhysics(),
                  ),
                  itemCount: widget.units.length,
                  onPageChanged: widget.onPageChanged,
                  itemBuilder: (context, index) {
                    final ReviewUnit unit = widget.units[index];
                    final bool isPlayingAudio =
                        widget.playingFlashcardId == unit.flashcardId;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal:
                            FlashcardStudySessionTokens.reviewPageHorizontalGap,
                      ),
                      child: _ReviewPage(
                        unit: unit,
                        l10n: widget.l10n,
                        isPlayingAudio: isPlayingAudio,
                        onAudioPressed: () {
                          widget.onAudioPressedFor(unit.flashcardId);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: FlashcardStudySessionTokens.reviewBodyBottomGap),
      ],
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.onNext();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.onPrevious();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }
    final double deltaX = event.scrollDelta.dx;
    final double deltaY = event.scrollDelta.dy;
    final double horizontalIntent = deltaX.abs();
    final double verticalIntent = deltaY.abs();
    if (horizontalIntent < _reviewWebWheelDeltaThreshold &&
        verticalIntent < _reviewWebWheelDeltaThreshold) {
      return;
    }
    if (horizontalIntent >= verticalIntent) {
      _onScrollDirection(deltaX);
      return;
    }
    _onScrollDirection(deltaY);
  }

  void _onScrollDirection(double delta) {
    if (delta > 0) {
      widget.onNext();
      return;
    }
    widget.onPrevious();
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
            textStyle: Theme.of(context).textTheme.titleMedium,
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
    final TextStyle? resolvedTextStyle = textStyle?.copyWith(
      fontWeight: FontWeight.normal,
    );
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
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: resolvedTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewWebScrollBehavior extends MaterialScrollBehavior {
  const _ReviewWebScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices {
    return <PointerDeviceKind>{
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.trackpad,
      PointerDeviceKind.stylus,
      PointerDeviceKind.unknown,
    };
  }
}
