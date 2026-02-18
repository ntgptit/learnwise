// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/styles/app_opacities.dart';

class FlashcardMockBanner extends StatelessWidget {
  const FlashcardMockBanner({required this.onInfoPressed, super.key});

  final VoidCallback onInfoPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      height: FlashcardScreenTokens.bannerHeight,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: AppOpacities.soft20,
        ),
        borderRadius: BorderRadius.circular(FlashcardScreenTokens.bannerRadius),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: FlashcardScreenTokens.bannerInnerGap),
          Icon(Icons.image_outlined, color: colorScheme.primary),
          const SizedBox(width: FlashcardScreenTokens.bannerInnerGap),
          Expanded(
            child: Text(
              l10n.flashcardsBannerPlaceholder,
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onInfoPressed,
            icon: const Icon(Icons.info_outline),
            tooltip: l10n.flashcardsBannerInfoTooltip,
          ),
        ],
      ),
    );
  }
}
