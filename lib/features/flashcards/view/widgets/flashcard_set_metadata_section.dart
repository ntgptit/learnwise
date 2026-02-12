import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';

class FlashcardSetMetadataSection extends StatelessWidget {
  const FlashcardSetMetadataSection({
    required this.title, required this.ownerName, required this.totalFlashcards, super.key,
  });

  final String title;
  final String ownerName;
  final int totalFlashcards;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String resolvedOwner = ownerName.trim().isEmpty
        ? l10n.flashcardsOwnerFallback
        : ownerName.trim();
    final String initial = resolvedOwner.characters.first.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: FlashcardScreenTokens.metadataGap),
        Row(
          children: <Widget>[
            CircleAvatar(
              radius: FlashcardScreenTokens.metadataAvatarSize / 2,
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: FlashcardScreenTokens.surfaceSoftOpacity,
              ),
              child: Text(
                initial,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: FlashcardScreenTokens.metadataHorizontalGap),
            Text(
              resolvedOwner,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: FlashcardScreenTokens.metadataHorizontalGap),
            Container(
              width: FlashcardScreenTokens.metadataDividerWidth,
              height: FlashcardScreenTokens.metadataDividerHeight,
              color: colorScheme.outline.withValues(
                alpha: FlashcardScreenTokens.outlineOpacity,
              ),
            ),
            const SizedBox(width: FlashcardScreenTokens.metadataHorizontalGap),
            Text(
              l10n.flashcardsTotalLabel(totalFlashcards),
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
      ],
    );
  }
}
