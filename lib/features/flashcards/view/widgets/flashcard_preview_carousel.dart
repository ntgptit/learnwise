import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';
import '../../model/flashcard_constants.dart';
import '../../model/flashcard_models.dart';

class FlashcardPreviewCarousel extends StatelessWidget {
  const FlashcardPreviewCarousel({
    required this.items, required this.pageController, required this.previewIndex, required this.onPageChanged, required this.onExpandPressed, super.key,
  });

  final List<FlashcardItem> items;
  final PageController pageController;
  final int previewIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onExpandPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<FlashcardItem> previewItems = items.isEmpty
        ? <FlashcardItem>[]
        : items.take(FlashcardConstants.previewItemLimit).toList();
    final int dotCount = previewItems.isEmpty ? 1 : previewItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: FlashcardScreenTokens.heroCardHeight,
          child: PageView.builder(
            controller: pageController,
            itemCount: dotCount,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final FlashcardItem? item = previewItems.isEmpty
                  ? null
                  : previewItems[index];
              final String displayText = item?.frontText.isNotEmpty == true
                  ? item!.frontText
                  : l10n.flashcardsPreviewPlaceholder;
              return AppCard(
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: FlashcardScreenTokens.surfaceSoftOpacity,
                ),
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
                        onPressed: onExpandPressed,
                        tooltip: l10n.flashcardsExpandPreviewTooltip,
                        icon: const Icon(Icons.fullscreen),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: FlashcardScreenTokens.heroPagerGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(dotCount, (index) {
            final bool isActive = index == previewIndex;
            return Container(
              width: FlashcardScreenTokens.heroDotSize,
              height: FlashcardScreenTokens.heroDotSize,
              margin: const EdgeInsets.symmetric(
                horizontal: FlashcardScreenTokens.heroDotSpacing,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(
                        alpha: FlashcardScreenTokens.mutedTextOpacity,
                      ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
