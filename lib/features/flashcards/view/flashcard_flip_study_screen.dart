import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/widgets/widgets.dart';
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

class _FlashcardFlipStudyScreenState extends State<FlashcardFlipStudyScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _isStudyCardFlipped = false;
  final Set<int> _starredFlashcardIds = <int>{};

  @override
  void initState() {
    super.initState();
    final int safeInitialIndex = _resolveSafeIndex(widget.initialIndex);
    _currentIndex = safeInitialIndex;
    _pageController = PageController(initialPage: safeInitialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (widget.items.isEmpty) {
      return Scaffold(
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

    final int currentIndex = _resolveSafeIndex(_currentIndex);
    if (currentIndex != _currentIndex) {
      _currentIndex = currentIndex;
    }
    final double progressValue = (currentIndex + 1) / widget.items.length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FlashcardFlipStudyTokens.screenPadding),
          child: Column(
            children: <Widget>[
              _StudyTopBar(
                progressText: '${currentIndex + 1} / ${widget.items.length}',
                onClosePressed: () => Navigator.of(context).pop(true),
                onSettingsPressed: () =>
                    _showToast(l10n.flashcardsFlipStudySettingsToast),
              ),
              const SizedBox(
                height: FlashcardFlipStudyTokens.progressBarTopGap,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  FlashcardFlipStudyTokens.progressBarRadius,
                ),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: FlashcardFlipStudyTokens.progressBarHeight,
                  backgroundColor: colorScheme.onSurface.withValues(
                    alpha: FlashcardFlipStudyTokens.progressTrackOpacity,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onSurface.withValues(
                      alpha: FlashcardFlipStudyTokens.progressValueOpacity,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: FlashcardFlipStudyTokens.progressBarBottomGap,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.items.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final FlashcardItem item = widget.items[index];
                    final bool isItemStarred =
                        item.isBookmarked ||
                        _starredFlashcardIds.contains(item.id);
                    return FlipAnimation(
                      isFlipped: _isStudyCardFlipped && index == currentIndex,
                      onTap: _toggleStudyCardFlipped,
                      front: _StudyCardFace(
                        content: item.frontText,
                        isStarred: isItemStarred,
                        onAudioPressed: () => _showToast(
                          l10n.flashcardsAudioPlayToast(item.frontText),
                        ),
                        onStarPressed: () {
                          _toggleStar(item.id);
                          _showToast(
                            isItemStarred
                                ? l10n.flashcardsUnbookmarkToast
                                : l10n.flashcardsBookmarkToast,
                          );
                        },
                      ),
                      back: _StudyCardFace(
                        content: _buildBackContent(item),
                        isStarred: isItemStarred,
                        onAudioPressed: () => _showToast(
                          l10n.flashcardsAudioPlayToast(item.frontText),
                        ),
                        onStarPressed: () {
                          _toggleStar(item.id);
                          _showToast(
                            isItemStarred
                                ? l10n.flashcardsUnbookmarkToast
                                : l10n.flashcardsBookmarkToast,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: FlashcardFlipStudyTokens.bottomBarTopGap),
              _StudyBottomBar(
                onPreviousPressed:
                    currentIndex == FlashcardConstants.defaultPage
                    ? null
                    : _goPrevious,
                onNextPressed: currentIndex == (widget.items.length - 1)
                    ? () => _showToast(l10n.flashcardsFlipStudyCompletedToast)
                    : _goNext,
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
    if (_currentIndex == index) {
      return;
    }
    setState(() {
      _currentIndex = index;
      _isStudyCardFlipped = false;
    });
  }

  int _resolveSafeIndex(int value) {
    if (widget.items.isEmpty) {
      return FlashcardConstants.defaultPage;
    }
    final int maxIndex = widget.items.length - 1;
    return value.clamp(FlashcardConstants.defaultPage, maxIndex);
  }

  String _buildBackContent(FlashcardItem item) {
    final String note = item.note.trim();
    if (note.isEmpty) {
      return item.backText;
    }
    return '${item.backText}\n\n$note';
  }

  void _toggleStudyCardFlipped() {
    setState(() {
      _isStudyCardFlipped = !_isStudyCardFlipped;
    });
  }

  void _toggleStar(int flashcardId) {
    setState(() {
      if (_starredFlashcardIds.contains(flashcardId)) {
        _starredFlashcardIds.remove(flashcardId);
        return;
      }
      _starredFlashcardIds.add(flashcardId);
    });
  }

  void _goPrevious() {
    unawaited(
      _pageController.previousPage(
        duration: AppDurations.animationFast,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _goNext() {
    unawaited(
      _pageController.nextPage(
        duration: AppDurations.animationFast,
        curve: Curves.easeOutCubic,
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

class _StudyTopBar extends StatelessWidget {
  const _StudyTopBar({
    required this.progressText,
    required this.onClosePressed,
    required this.onSettingsPressed,
  });

  final String progressText;
  final VoidCallback onClosePressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        IconButton(
          onPressed: onClosePressed,
          tooltip: l10n.flashcardsCloseTooltip,
          icon: const Icon(Icons.close),
        ),
        Expanded(
          child: Text(
            progressText,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: onSettingsPressed,
          tooltip: l10n.flashcardsFlipStudySettingsTooltip,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _StudyCardFace extends StatelessWidget {
  const _StudyCardFace({
    required this.content,
    required this.isStarred,
    required this.onAudioPressed,
    required this.onStarPressed,
  });

  final String content;
  final bool isStarred;
  final VoidCallback onAudioPressed;
  final VoidCallback onStarPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color cardBackgroundColor = _resolveCardBackgroundColor(
      colorScheme: colorScheme,
      isDarkMode: isDarkMode,
    );

    return AppCard(
      backgroundColor: cardBackgroundColor,
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
                onPressed: onAudioPressed,
                tooltip: AppLocalizations.of(
                  context,
                )!.flashcardsPlayAudioTooltip,
                icon: const Icon(Icons.volume_up_outlined),
              ),
              const Spacer(),
              IconButton(
                onPressed: onStarPressed,
                tooltip: AppLocalizations.of(
                  context,
                )!.flashcardsBookmarkTooltip,
                icon: Icon(isStarred ? Icons.star : Icons.star_border),
              ),
            ],
          ),
          const SizedBox(height: FlashcardFlipStudyTokens.cardBodyTopGap),
          Expanded(
            child: Center(
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface.withValues(
                    alpha: FlashcardFlipStudyTokens.centerTitleOpacity,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: FlashcardFlipStudyTokens.cardBodyBottomGap),
        ],
      ),
    );
  }

  Color _resolveCardBackgroundColor({
    required ColorScheme colorScheme,
    required bool isDarkMode,
  }) {
    if (!isDarkMode) {
      return colorScheme.surfaceContainerHighest.withValues(
        alpha: FlashcardScreenTokens.surfaceSoftOpacity,
      );
    }
    return colorScheme.primaryContainer.withValues(
      alpha: FlashcardScreenTokens.heroCardDarkModeOpacity,
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

    return Row(
      children: <Widget>[
        IconButton(
          onPressed: onPreviousPressed,
          tooltip: l10n.flashcardsPreviousTooltip,
          icon: const Icon(Icons.undo_rounded),
        ),
        const Spacer(),
        IconButton(
          onPressed: onNextPressed,
          tooltip: l10n.flashcardsNextTooltip,
          icon: const Icon(Icons.play_arrow_rounded),
        ),
      ],
    );
  }
}
