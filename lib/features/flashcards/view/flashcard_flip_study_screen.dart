// quality-guard: allow-large-file - phase2 legacy backlog tracked for file modularization.
// quality-guard: allow-large-class - phase2 legacy backlog tracked for class decomposition.
// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_opacities.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/widgets/widgets.dart';
import '../../../core/utils/string_utils.dart';
import '../model/flashcard_constants.dart';
import '../model/flashcard_models.dart';

class FlashcardFlipStudyScreen extends StatefulWidget {
  const FlashcardFlipStudyScreen({
    required this.items,
    required this.initialIndex,
    required this.title,
    super.key,
  });

  final List<FlashcardItem> items;
  final int initialIndex;
  final String title;

  @override
  State<FlashcardFlipStudyScreen> createState() =>
      _FlashcardFlipStudyScreenState();
}

class FlashcardFlipStudyArgs {
  const FlashcardFlipStudyArgs({
    required this.items,
    required this.initialIndex,
    required this.title,
  });

  const FlashcardFlipStudyArgs.fallback()
    : items = const <FlashcardItem>[],
      initialIndex = FlashcardConstants.defaultPage,
      title = '';

  final List<FlashcardItem> items;
  final int initialIndex;
  final String title;
}

class _FlashcardFlipStudyScreenState extends State<FlashcardFlipStudyScreen> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentIndexNotifier;
  late final ValueNotifier<bool> _isFlippedNotifier;
  late final ValueNotifier<Set<int>> _starToggleIdsNotifier;
  late final ValueNotifier<int?> _playingFlashcardIdNotifier;
  Timer? _audioPlayingIndicatorTimer;

  @override
  void initState() {
    super.initState();
    final int safeInitialIndex = _resolveSafeIndex(widget.initialIndex);
    _pageController = PageController(initialPage: safeInitialIndex);
    _currentIndexNotifier = ValueNotifier<int>(safeInitialIndex);
    _isFlippedNotifier = ValueNotifier<bool>(false);
    _starToggleIdsNotifier = ValueNotifier<Set<int>>(<int>{});
    _playingFlashcardIdNotifier = ValueNotifier<int?>(null);
  }

  @override
  void dispose() {
    _audioPlayingIndicatorTimer?.cancel();
    _pageController.dispose();
    _currentIndexNotifier.dispose();
    _isFlippedNotifier.dispose();
    _starToggleIdsNotifier.dispose();
    _playingFlashcardIdNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (widget.items.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: EmptyState(
              title: l10n.flashcardsEmptyTitle,
              subtitle: l10n.flashcardsEmptyDescription,
              icon: Icons.style_outlined,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: ValueListenableBuilder<int>(
          valueListenable: _currentIndexNotifier,
          builder: (context, currentIndex, child) {
            return Text(
              '${currentIndex + 1} / ${widget.items.length}',
              style: theme.textTheme.titleLarge,
            );
          },
        ),
        leading: IconButton(
          onPressed: () => context.pop(true),
          tooltip: l10n.flashcardsCloseTooltip,
          iconSize: FlashcardFlipStudyTokens.topIconSize,
          constraints: const BoxConstraints(
            minWidth: FlashcardFlipStudyTokens.topIconTapTargetSize,
            minHeight: FlashcardFlipStudyTokens.topIconTapTargetSize,
          ),
          icon: Icon(
            Icons.close,
            color: colorScheme.onSurfaceVariant.withValues(
              alpha: FlashcardFlipStudyTokens.topIconOpacity,
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => _showToast(l10n.flashcardsFlipStudySettingsToast),
            tooltip: l10n.flashcardsFlipStudySettingsTooltip,
            iconSize: FlashcardFlipStudyTokens.topIconSize,
            constraints: const BoxConstraints(
              minWidth: FlashcardFlipStudyTokens.topIconTapTargetSize,
              minHeight: FlashcardFlipStudyTokens.topIconTapTargetSize,
            ),
            icon: Icon(
              Icons.settings_outlined,
              color: colorScheme.onSurfaceVariant.withValues(
                alpha: FlashcardFlipStudyTokens.topIconOpacity,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FlashcardFlipStudyTokens.screenPadding,
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: FlashcardFlipStudyTokens.progressBarTopGap,
              ),
              ValueListenableBuilder<int>(
                valueListenable: _currentIndexNotifier,
                builder: (context, currentIndex, child) {
                  final double progressValue =
                      (currentIndex + 1) / widget.items.length;
                  return _AnimatedStudyProgressBar(value: progressValue);
                },
              ),
              const SizedBox(
                height: FlashcardFlipStudyTokens.progressBarBottomGap,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.items.length,
                  physics: const BouncingScrollPhysics(
                    parent: PageScrollPhysics(),
                  ),
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final FlashcardItem item = widget.items[index];
                    final String noteText = StringUtils.normalize(item.note);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical:
                            FlashcardFlipStudyTokens.cardOuterVerticalInset,
                      ),
                      child: SizedBox.expand(
                        child: AnimatedBuilder(
                          animation: Listenable.merge(<Listenable>[
                            _currentIndexNotifier,
                            _isFlippedNotifier,
                            _starToggleIdsNotifier,
                            _playingFlashcardIdNotifier,
                          ]),
                          builder: (context, child) {
                            final bool isCurrent =
                                _currentIndexNotifier.value == index;
                            final bool isFlipped =
                                isCurrent && _isFlippedNotifier.value;
                            final bool isStarred = _resolveIsItemStarred(item);
                            final bool isAudioPlaying =
                                _playingFlashcardIdNotifier.value == item.id;

                            return FlipAnimation(
                              isFlipped: isFlipped,
                              duration: AppDurations.animationStandard,
                              curve: AppMotionCurves.standard,
                              front: _StudyCardFace(
                                isFrontSide: true,
                                primaryText: item.frontText,
                                secondaryText: null,
                                descriptionText: null,
                                isStarred: isStarred,
                                isAudioPlaying: isAudioPlaying,
                                onFlipPressed: _toggleStudyCardFlipped,
                                onAudioPressed: () {
                                  _startAudioPlayingIndicator(item.id);
                                  _showToast(
                                    l10n.flashcardsAudioPlayToast(
                                      item.frontText,
                                    ),
                                  );
                                },
                                onStarPressed: () {
                                  _toggleStar(item.id);
                                  _showToast(
                                    isStarred
                                        ? l10n.flashcardsUnbookmarkToast
                                        : l10n.flashcardsBookmarkToast,
                                  );
                                },
                              ),
                              back: _StudyCardFace(
                                isFrontSide: false,
                                primaryText: item.backText,
                                secondaryText: null,
                                descriptionText: noteText.isEmpty
                                    ? null
                                    : noteText,
                                isStarred: isStarred,
                                isAudioPlaying: isAudioPlaying,
                                onFlipPressed: _toggleStudyCardFlipped,
                                onAudioPressed: () {
                                  _startAudioPlayingIndicator(item.id);
                                  _showToast(
                                    l10n.flashcardsAudioPlayToast(
                                      item.frontText,
                                    ),
                                  );
                                },
                                onStarPressed: () {
                                  _toggleStar(item.id);
                                  _showToast(
                                    isStarred
                                        ? l10n.flashcardsUnbookmarkToast
                                        : l10n.flashcardsBookmarkToast,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: FlashcardFlipStudyTokens.bottomBarTopGap),
              ValueListenableBuilder<int>(
                valueListenable: _currentIndexNotifier,
                builder: (context, currentIndex, child) {
                  final bool isAtFirstCard =
                      currentIndex == FlashcardConstants.defaultPage;
                  final bool isAtLastCard =
                      currentIndex == (widget.items.length - 1);
                  return _StudyBottomBar(
                    onPreviousPressed: isAtFirstCard ? null : _goPrevious,
                    onNextPressed: () {
                      if (isAtLastCard) {
                        _showToast(l10n.flashcardsFlipStudyCompletedToast);
                        return;
                      }
                      _goNext();
                    },
                  );
                },
              ),
              const SizedBox(
                height: FlashcardFlipStudyTokens.bottomBarBottomGap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    if (_currentIndexNotifier.value == index) {
      return;
    }
    _currentIndexNotifier.value = index;
    _isFlippedNotifier.value = false;
    _clearAudioPlayingIndicator();
    unawaited(HapticFeedback.selectionClick());
  }

  int _resolveSafeIndex(int value) {
    if (widget.items.isEmpty) {
      return FlashcardConstants.defaultPage;
    }
    final int maxIndex = widget.items.length - 1;
    return value.clamp(FlashcardConstants.defaultPage, maxIndex);
  }

  bool _resolveIsItemStarred(FlashcardItem item) {
    final bool isToggled = _starToggleIdsNotifier.value.contains(item.id);
    if (item.isBookmarked) {
      return !isToggled;
    }
    return isToggled;
  }

  void _toggleStudyCardFlipped() {
    _isFlippedNotifier.value = !_isFlippedNotifier.value;
    unawaited(HapticFeedback.selectionClick());
  }

  void _toggleStar(int flashcardId) {
    final Set<int> nextIds = Set<int>.from(_starToggleIdsNotifier.value);
    if (nextIds.contains(flashcardId)) {
      nextIds.remove(flashcardId);
      _starToggleIdsNotifier.value = nextIds;
      return;
    }
    nextIds.add(flashcardId);
    _starToggleIdsNotifier.value = nextIds;
  }

  void _startAudioPlayingIndicator(int flashcardId) {
    _audioPlayingIndicatorTimer?.cancel();
    _playingFlashcardIdNotifier.value = flashcardId;
    _audioPlayingIndicatorTimer = Timer(
      const Duration(
        milliseconds: FlashcardConstants.audioPlayingIndicatorDurationMs,
      ),
      _clearAudioPlayingIndicator,
    );
  }

  void _clearAudioPlayingIndicator() {
    if (_playingFlashcardIdNotifier.value == null) {
      return;
    }
    _playingFlashcardIdNotifier.value = null;
  }

  void _goPrevious() {
    unawaited(
      _pageController.previousPage(
        duration: AppDurations.animationStandard,
        curve: AppMotionCurves.standard,
      ),
    );
  }

  void _goNext() {
    unawaited(
      _pageController.nextPage(
        duration: AppDurations.animationStandard,
        curve: AppMotionCurves.standard,
      ),
    );
  }

  void _showToast(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AnimatedStudyProgressBar extends StatelessWidget {
  const _AnimatedStudyProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: AppDurations.animationStandard,
      curve: AppMotionCurves.standard,
      builder: (context, animatedValue, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(
            FlashcardFlipStudyTokens.progressBarRadius,
          ),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: FlashcardFlipStudyTokens.progressBarHeight,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        );
      },
    );
  }
}

class _StudyCardFace extends StatefulWidget {
  const _StudyCardFace({
    required this.isFrontSide,
    required this.primaryText,
    required this.secondaryText,
    required this.descriptionText,
    required this.isStarred,
    required this.isAudioPlaying,
    required this.onFlipPressed,
    required this.onAudioPressed,
    required this.onStarPressed,
  });

  final bool isFrontSide;
  final String primaryText;
  final String? secondaryText;
  final String? descriptionText;
  final bool isStarred;
  final bool isAudioPlaying;
  final VoidCallback onFlipPressed;
  final VoidCallback onAudioPressed;
  final VoidCallback onStarPressed;

  @override
  State<_StudyCardFace> createState() => _StudyCardFaceState();
}

class _StudyCardFaceState extends State<_StudyCardFace> {
  late final ValueNotifier<bool> _isPressedNotifier;

  @override
  void initState() {
    super.initState();
    _isPressedNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _isPressedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String? normalizedSecondary = StringUtils.normalizeNullable(
      widget.secondaryText,
    );
    final String? normalizedDescription = StringUtils.normalizeNullable(
      widget.descriptionText,
    );

    return ValueListenableBuilder<bool>(
      valueListenable: _isPressedNotifier,
      builder: (context, isPressed, child) {
        return Card(
          elevation: isPressed
              ? FlashcardFlipStudyTokens.cardPressedElevation
              : FlashcardFlipStudyTokens.cardElevation,
          shadowColor: colorScheme.shadow,
          margin: EdgeInsets.zero,
          color: colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              FlashcardFlipStudyTokens.cardRadius,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              FlashcardFlipStudyTokens.cardRadius,
            ),
            onTap: widget.onFlipPressed,
            onHighlightChanged: (isHighlighted) {
              _isPressedNotifier.value = isHighlighted;
            },
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return colorScheme.primary.withValues(
                  alpha: AppOpacities.soft10,
                );
              }
              if (states.contains(WidgetState.hovered)) {
                return colorScheme.primary.withValues(
                  alpha: AppOpacities.soft08,
                );
              }
              if (states.contains(WidgetState.focused)) {
                return colorScheme.primary.withValues(
                  alpha: AppOpacities.soft08,
                );
              }
              return null;
            }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                FlashcardFlipStudyTokens.cardContentHorizontalPadding,
                FlashcardFlipStudyTokens.cardContentTopPadding,
                FlashcardFlipStudyTokens.cardContentHorizontalPadding,
                FlashcardFlipStudyTokens.cardContentBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        isSelected: widget.isAudioPlaying,
                        iconSize: FlashcardFlipStudyTokens.cardActionIconSize,
                        style: _resolveCardActionIconStyle(colorScheme),
                        tooltip: AppLocalizations.of(
                          context,
                        )!.flashcardsPlayAudioTooltip,
                        onPressed: widget.onAudioPressed,
                        icon: const Icon(Icons.volume_up_outlined),
                        selectedIcon: const Icon(Icons.graphic_eq_rounded),
                      ),
                      const Spacer(),
                      IconButton(
                        isSelected: widget.isStarred,
                        iconSize: FlashcardFlipStudyTokens.cardActionIconSize,
                        style: _resolveCardActionIconStyle(colorScheme),
                        tooltip: AppLocalizations.of(
                          context,
                        )!.flashcardsBookmarkTooltip,
                        onPressed: widget.onStarPressed,
                        icon: const Icon(Icons.star_border),
                        selectedIcon: const Icon(Icons.star),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: FlashcardFlipStudyTokens.cardBodyTopGap,
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              widget.primaryText,
                              textAlign: TextAlign.center,
                              style: widget.isFrontSide
                                  ? theme.textTheme.headlineMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    )
                                  : theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                            ),
                            if (normalizedSecondary != null) ...<Widget>[
                              const SizedBox(
                                height: FlashcardFlipStudyTokens.cardBodyTopGap,
                              ),
                              Text(
                                normalizedSecondary,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: FlashcardFlipStudyTokens
                                    .backPrimaryMaxLines,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (normalizedDescription != null) ...<Widget>[
                              const SizedBox(
                                height: FlashcardFlipStudyTokens.cardBodyTopGap,
                              ),
                              Text(
                                normalizedDescription,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: FlashcardFlipStudyTokens
                                    .backDescriptionMaxLines,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: FlashcardFlipStudyTokens.cardBodyBottomGap,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ButtonStyle _resolveCardActionIconStyle(ColorScheme colorScheme) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(
        Size.square(FlashcardFlipStudyTokens.cardActionTapTargetSize),
      ),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(
            alpha: AppOpacities.disabled38,
          );
        }
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.onSurfaceVariant;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.primary.withValues(alpha: AppOpacities.soft10);
        }
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.primary.withValues(alpha: AppOpacities.soft08);
        }
        if (states.contains(WidgetState.focused)) {
          return colorScheme.primary.withValues(alpha: AppOpacities.soft08);
        }
        return null;
      }),
    );
  }
}

class _StudyBottomBar extends StatelessWidget {
  const _StudyBottomBar({
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FlashcardFlipStudyTokens.bottomBarHorizontalPadding,
      ),
      child: Row(
        children: <Widget>[
          IconButton.filledTonal(
            onPressed: onPreviousPressed,
            tooltip: l10n.flashcardsPreviousTooltip,
            iconSize: FlashcardFlipStudyTokens.bottomBarIconSize,
            constraints: const BoxConstraints(
              minWidth: FlashcardFlipStudyTokens.bottomBarTapTargetSize,
              minHeight: FlashcardFlipStudyTokens.bottomBarTapTargetSize,
            ),
            icon: const Icon(Icons.undo_rounded),
          ),
          const Spacer(),
          IconButton.filled(
            onPressed: onNextPressed,
            tooltip: l10n.flashcardsNextTooltip,
            iconSize: FlashcardFlipStudyTokens.bottomBarIconSize,
            constraints: const BoxConstraints(
              minWidth: FlashcardFlipStudyTokens.bottomBarTapTargetSize,
              minHeight: FlashcardFlipStudyTokens.bottomBarTapTargetSize,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
          ),
        ],
      ),
    );
  }
}
