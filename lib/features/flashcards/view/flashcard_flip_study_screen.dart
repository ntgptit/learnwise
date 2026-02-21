// quality-guard: allow-large-file - phase2 legacy backlog tracked for file modularization.
// quality-guard: allow-large-class - phase2 legacy backlog tracked for class decomposition.
// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_opacities.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../../core/utils/string_utils.dart';
import '../../decks/viewmodel/deck_audio_settings_viewmodel.dart';
import '../../profile/model/profile_models.dart';
import '../../tts/viewmodel/tts_viewmodel.dart';
import '../model/flashcard_constants.dart';
import '../model/flashcard_models.dart';

class FlashcardFlipStudyScreen extends HookConsumerWidget {
  const FlashcardFlipStudyScreen({
    required this.deckId,
    required this.items,
    required this.initialIndex,
    required this.title,
    super.key,
  });

  final int deckId;
  final List<FlashcardItem> items;
  final int initialIndex;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int safeInitialIndex = _resolveSafeFlashcardIndex(
      value: initialIndex,
      itemCount: items.length,
    );
    final PageController pageController = usePageController(
      initialPage: safeInitialIndex,
    );
    final ValueNotifier<int> currentIndexNotifier = useState<int>(
      safeInitialIndex,
    );
    final ValueNotifier<bool> isFlippedNotifier = useState<bool>(false);
    final ValueNotifier<Set<int>> starToggleIdsNotifier = useState<Set<int>>(
      <int>{},
    );
    final ValueNotifier<int?> playingFlashcardIdNotifier = useState<int?>(null);
    final ObjectRef<Timer?> audioPlayingIndicatorTimerRef = useRef<Timer?>(
      null,
    );
    final ObjectRef<int?> lastAutoPlayFlashcardIdRef = useRef<int?>(null);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    bool resolveIsItemStarred(FlashcardItem item) {
      final bool isToggled = starToggleIdsNotifier.value.contains(item.id);
      if (item.isBookmarked) {
        return !isToggled;
      }
      return isToggled;
    }

    void clearAudioPlayingIndicator() {
      if (playingFlashcardIdNotifier.value == null) {
        return;
      }
      playingFlashcardIdNotifier.value = null;
    }

    void startAudioPlayingIndicator(int flashcardId) {
      audioPlayingIndicatorTimerRef.value?.cancel();
      playingFlashcardIdNotifier.value = flashcardId;
      audioPlayingIndicatorTimerRef.value = Timer(
        const Duration(
          milliseconds: FlashcardConstants.audioPlayingIndicatorDurationMs,
        ),
        clearAudioPlayingIndicator,
      );
    }

    void applyTtsSettings(TtsController ttsController) {
      final UserStudySettings settings = ref.read(
        effectiveStudySettingsForDeckProvider(deckId),
      );
      ttsController.applyVoiceSettings(
        voiceId: settings.ttsVoiceId,
        speechRate: settings.ttsSpeechRate,
        pitch: settings.ttsPitch,
        volume: settings.ttsVolume,
        clearVoiceId: settings.ttsVoiceId == null,
      );
    }

    bool isAutoPlayEnabled() {
      final UserStudySettings settings = ref.read(
        effectiveStudySettingsForDeckProvider(deckId),
      );
      return settings.studyAutoPlayAudio;
    }

    Future<void> speakText(String text) async {
      final TtsController ttsController = ref.read(
        ttsControllerProvider.notifier,
      );
      applyTtsSettings(ttsController);
      await ttsController.initialize();
      await ttsController.speakText(text);
    }

    void playPronunciationFor({required FlashcardItem item}) {
      startAudioPlayingIndicator(item.id);
      final String text = StringUtils.normalize(item.frontText);
      if (text.isEmpty) {
        return;
      }
      unawaited(speakText(text));
    }

    Future<void> attemptAutoPlayCurrentCard() async {
      if (!isAutoPlayEnabled()) {
        lastAutoPlayFlashcardIdRef.value = null;
        return;
      }
      if (items.isEmpty) {
        return;
      }
      final int index = currentIndexNotifier.value;
      if (index < 0 || index >= items.length) {
        return;
      }
      final FlashcardItem currentItem = items[index];
      if (lastAutoPlayFlashcardIdRef.value == currentItem.id) {
        return;
      }
      lastAutoPlayFlashcardIdRef.value = currentItem.id;
      playPronunciationFor(item: currentItem);
    }

    void showToast(String message) {
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    void onPageChanged(int index) {
      if (currentIndexNotifier.value == index) {
        return;
      }
      currentIndexNotifier.value = index;
      isFlippedNotifier.value = false;
      clearAudioPlayingIndicator();
      unawaited(HapticFeedback.selectionClick());
      unawaited(attemptAutoPlayCurrentCard());
    }

    void toggleStudyCardFlipped() {
      isFlippedNotifier.value = !isFlippedNotifier.value;
      unawaited(HapticFeedback.selectionClick());
    }

    void toggleStar(int flashcardId) {
      final Set<int> nextIds = Set<int>.from(starToggleIdsNotifier.value);
      if (nextIds.contains(flashcardId)) {
        nextIds.remove(flashcardId);
        starToggleIdsNotifier.value = nextIds;
        return;
      }
      nextIds.add(flashcardId);
      starToggleIdsNotifier.value = nextIds;
    }

    void goPrevious() {
      unawaited(
        pageController.previousPage(
          duration: AppDurations.animationStandard,
          curve: AppMotionCurves.standard,
        ),
      );
    }

    void goNext() {
      unawaited(
        pageController.nextPage(
          duration: AppDurations.animationStandard,
          curve: AppMotionCurves.standard,
        ),
      );
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(attemptAutoPlayCurrentCard());
      });
      return () {
        audioPlayingIndicatorTimerRef.value?.cancel();
      };
    }, <Object>[deckId, safeInitialIndex, items.length]);

    if (items.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: LwEmptyState(
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
          valueListenable: currentIndexNotifier,
          builder: (context, currentIndex, child) {
            return Text(
              '${currentIndex + 1} / ${items.length}',
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
              alpha: AppOpacities.muted82,
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => showToast(l10n.flashcardsFlipStudySettingsToast),
            tooltip: l10n.flashcardsFlipStudySettingsTooltip,
            iconSize: FlashcardFlipStudyTokens.topIconSize,
            constraints: const BoxConstraints(
              minWidth: FlashcardFlipStudyTokens.topIconTapTargetSize,
              minHeight: FlashcardFlipStudyTokens.topIconTapTargetSize,
            ),
            icon: Icon(
              Icons.settings_outlined,
              color: colorScheme.onSurfaceVariant.withValues(
                alpha: AppOpacities.muted82,
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
                valueListenable: currentIndexNotifier,
                builder: (context, currentIndex, child) {
                  final double progressValue =
                      (currentIndex + 1) / items.length;
                  return _AnimatedStudyProgressBar(value: progressValue);
                },
              ),
              const SizedBox(
                height: FlashcardFlipStudyTokens.progressBarBottomGap,
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: items.length,
                  physics: const BouncingScrollPhysics(
                    parent: PageScrollPhysics(),
                  ),
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    final FlashcardItem item = items[index];
                    final String noteText = StringUtils.normalize(item.note);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical:
                            FlashcardFlipStudyTokens.cardOuterVerticalInset,
                      ),
                      child: SizedBox.expand(
                        child: AnimatedBuilder(
                          animation: Listenable.merge(<Listenable>[
                            currentIndexNotifier,
                            isFlippedNotifier,
                            starToggleIdsNotifier,
                            playingFlashcardIdNotifier,
                          ]),
                          builder: (context, child) {
                            final bool isCurrent =
                                currentIndexNotifier.value == index;
                            final bool isFlipped =
                                isCurrent && isFlippedNotifier.value;
                            final bool isStarred = resolveIsItemStarred(item);
                            final bool isAudioPlaying =
                                playingFlashcardIdNotifier.value == item.id;

                            return LwFlipAnimation(
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
                                onFlipPressed: toggleStudyCardFlipped,
                                onAudioPressed: () {
                                  playPronunciationFor(item: item);
                                  showToast(
                                    l10n.flashcardsAudioPlayToast(
                                      item.frontText,
                                    ),
                                  );
                                },
                                onStarPressed: () {
                                  toggleStar(item.id);
                                  showToast(
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
                                onFlipPressed: toggleStudyCardFlipped,
                                onAudioPressed: () {
                                  playPronunciationFor(item: item);
                                  showToast(
                                    l10n.flashcardsAudioPlayToast(
                                      item.frontText,
                                    ),
                                  );
                                },
                                onStarPressed: () {
                                  toggleStar(item.id);
                                  showToast(
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
                valueListenable: currentIndexNotifier,
                builder: (context, currentIndex, child) {
                  final bool isAtFirstCard =
                      currentIndex == FlashcardConstants.defaultPage;
                  final bool isAtLastCard = currentIndex == (items.length - 1);
                  return _StudyBottomBar(
                    onPreviousPressed: isAtFirstCard ? null : goPrevious,
                    onNextPressed: () {
                      if (isAtLastCard) {
                        showToast(l10n.flashcardsFlipStudyCompletedToast);
                        return;
                      }
                      goNext();
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
}

class FlashcardFlipStudyArgs {
  const FlashcardFlipStudyArgs({
    required this.deckId,
    required this.items,
    required this.initialIndex,
    required this.title,
  });

  const FlashcardFlipStudyArgs.fallback()
    : deckId = 0,
      items = const <FlashcardItem>[],
      initialIndex = FlashcardConstants.defaultPage,
      title = '';

  final int deckId;
  final List<FlashcardItem> items;
  final int initialIndex;
  final String title;
}

int _resolveSafeFlashcardIndex({required int value, required int itemCount}) {
  if (itemCount == 0) {
    return FlashcardConstants.defaultPage;
  }
  final int maxIndex = itemCount - 1;
  return value.clamp(FlashcardConstants.defaultPage, maxIndex);
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

class _StudyCardFace extends HookWidget {
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
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isPressedNotifier = useState<bool>(false);
    final bool isPressed = isPressedNotifier.value;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double defaultCardElevation =
        theme.cardTheme.elevation ?? AppSizes.size1;
    final String? normalizedSecondary = StringUtils.normalizeNullable(
      secondaryText,
    );
    final String? normalizedDescription = StringUtils.normalizeNullable(
      descriptionText,
    );

    return Card(
      elevation: isPressed ? AppSizes.size2 : defaultCardElevation,
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
        onTap: onFlipPressed,
        onHighlightChanged: (isHighlighted) {
          isPressedNotifier.value = isHighlighted;
        },
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
                    isSelected: isAudioPlaying,
                    iconSize: FlashcardFlipStudyTokens.cardActionIconSize,
                    style: _resolveCardActionIconStyle(colorScheme),
                    tooltip: AppLocalizations.of(
                      context,
                    )!.flashcardsPlayAudioTooltip,
                    onPressed: onAudioPressed,
                    icon: const Icon(Icons.volume_up_outlined),
                    selectedIcon: const Icon(Icons.graphic_eq_rounded),
                  ),
                  const Spacer(),
                  IconButton(
                    isSelected: isStarred,
                    iconSize: FlashcardFlipStudyTokens.cardActionIconSize,
                    style: _resolveCardActionIconStyle(colorScheme),
                    tooltip: AppLocalizations.of(
                      context,
                    )!.flashcardsBookmarkTooltip,
                    onPressed: onStarPressed,
                    icon: const Icon(Icons.star_border),
                    selectedIcon: const Icon(Icons.star),
                  ),
                ],
              ),
              const SizedBox(height: FlashcardFlipStudyTokens.cardBodyTopGap),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          primaryText,
                          textAlign: TextAlign.center,
                          style: isFrontSide
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
                            maxLines:
                                FlashcardFlipStudyTokens.backPrimaryMaxLines,
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
  }
}

ButtonStyle _resolveCardActionIconStyle(ColorScheme colorScheme) {
  return ButtonStyle(
    minimumSize: const WidgetStatePropertyAll<Size>(
      Size.square(FlashcardFlipStudyTokens.cardActionTapTargetSize),
    ),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colorScheme.onSurface.withValues(alpha: AppOpacities.disabled38);
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
