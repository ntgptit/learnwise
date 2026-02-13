import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_durations.dart';
import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';
import '../../model/flashcard_constants.dart';
import '../../model/flashcard_models.dart';

class FlashcardPreviewCarousel extends StatelessWidget {
  const FlashcardPreviewCarousel({
    required this.items,
    required this.pageController,
    required this.previewIndex,
    required this.onPageChanged,
    required this.onExpandPressed,
    super.key,
  });

  final List<FlashcardItem> items;
  final PageController pageController;
  final int previewIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onExpandPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color cardBackgroundColor = _resolveCardBackgroundColor(
      colorScheme: colorScheme,
      isDarkMode: isDarkMode,
    );
    final Color activeDotColor = _resolveActiveDotColor(
      colorScheme: colorScheme,
      isDarkMode: isDarkMode,
    );
    final Color inactiveDotColor = _resolveInactiveDotColor(
      colorScheme: colorScheme,
      isDarkMode: isDarkMode,
    );
    final List<FlashcardItem> previewItems = items;
    final int dotCount = previewItems.isEmpty ? 1 : previewItems.length;
    final int safePreviewIndex = previewIndex.clamp(0, dotCount - 1);
    final int visibleDotCount = _resolveVisibleDotCount(totalDots: dotCount);
    final int indicatorStart = _resolveIndicatorStart(
      totalDots: dotCount,
      activeIndex: safePreviewIndex,
      visibleDots: visibleDotCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: FlashcardScreenTokens.heroCardHeight,
          child: ScrollConfiguration(
            behavior: const _FlashcardCarouselScrollBehavior(),
            child: PageView.builder(
              controller: pageController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(parent: PageScrollPhysics()),
              itemCount: dotCount,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final FlashcardItem? item = previewItems.isEmpty
                    ? null
                    : previewItems[index];
                final String displayText = item?.frontText.isNotEmpty == true
                    ? item!.frontText
                    : l10n.flashcardsPreviewPlaceholder;

                void handleExpandPressed() {
                  onExpandPressed(index);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FlashcardScreenTokens.heroCardItemSpacing,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: handleExpandPressed,
                    child: AppCard(
                      backgroundColor: cardBackgroundColor,
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Text(
                              displayText,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: FlashcardScreenTokens.previewMaxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Positioned(
                            right: FlashcardScreenTokens.overlayEdgeInset,
                            bottom: FlashcardScreenTokens.overlayEdgeInset,
                            child: IconButton(
                              onPressed: handleExpandPressed,
                              tooltip: l10n.flashcardsExpandPreviewTooltip,
                              icon: const Icon(Icons.fullscreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: FlashcardScreenTokens.heroPagerGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(visibleDotCount, (index) {
            final int actualIndex = indicatorStart + index;
            final bool isActive = actualIndex == safePreviewIndex;
            final double dotSize = isActive
                ? FlashcardScreenTokens.heroDotSize * 1.6
                : FlashcardScreenTokens.heroDotSize;
            return AnimatedContainer(
              duration: AppDurations.animationSnappy,
              curve: Curves.easeOutCubic,
              width: dotSize,
              height: dotSize,
              margin: const EdgeInsets.symmetric(
                horizontal: FlashcardScreenTokens.heroDotSpacing,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeDotColor : inactiveDotColor,
              ),
            );
          }),
        ),
      ],
    );
  }

  int _resolveVisibleDotCount({required int totalDots}) {
    if (totalDots <= FlashcardScreenTokens.heroMaxIndicatorDots) {
      return totalDots;
    }
    return FlashcardScreenTokens.heroMaxIndicatorDots;
  }

  int _resolveIndicatorStart({
    required int totalDots,
    required int activeIndex,
    required int visibleDots,
  }) {
    if (totalDots <= visibleDots) {
      return FlashcardConstants.minPage;
    }

    final int centeredStart = activeIndex - (visibleDots ~/ 2);
    final int maxStart = totalDots - visibleDots;
    if (centeredStart < FlashcardConstants.minPage) {
      return FlashcardConstants.minPage;
    }
    if (centeredStart > maxStart) {
      return maxStart;
    }
    return centeredStart;
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

  Color _resolveActiveDotColor({
    required ColorScheme colorScheme,
    required bool isDarkMode,
  }) {
    if (!isDarkMode) {
      return colorScheme.onSurface;
    }
    return colorScheme.primaryContainer;
  }

  Color _resolveInactiveDotColor({
    required ColorScheme colorScheme,
    required bool isDarkMode,
  }) {
    if (!isDarkMode) {
      return colorScheme.onSurface.withValues(
        alpha: FlashcardScreenTokens.mutedTextOpacity,
      );
    }
    return colorScheme.primaryContainer.withValues(
      alpha: FlashcardScreenTokens.heroDotInactiveDarkModeOpacity,
    );
  }
}

class _FlashcardCarouselScrollBehavior extends MaterialScrollBehavior {
  const _FlashcardCarouselScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
