import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';
import '../../model/flashcard_models.dart';

class FlashcardContentCard extends StatelessWidget {
  const FlashcardContentCard({
    required this.item, required this.isStarred, required this.onAudioPressed, required this.onStarPressed, super.key,
  });

  final FlashcardItem item;
  final bool isStarred;
  final VoidCallback onAudioPressed;
  final VoidCallback onStarPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String noteText = item.note.trim();
    final bool hasNote = noteText.isNotEmpty;

    return AppCard(
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: FlashcardScreenTokens.surfaceSoftOpacity,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.frontText,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: FlashcardScreenTokens.cardHeaderIconGap),
              IconButton(
                onPressed: onAudioPressed,
                tooltip: l10n.flashcardsPlayAudioTooltip,
                icon: const Icon(Icons.volume_up_outlined),
              ),
              IconButton(
                onPressed: onStarPressed,
                tooltip: l10n.flashcardsBookmarkTooltip,
                icon: Icon(
                  isStarred ? Icons.star : Icons.star_border,
                  color: isStarred ? colorScheme.primary : null,
                ),
              ),
            ],
          ),
          if (item.pronunciation.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: FlashcardScreenTokens.listMetadataGap),
            Text(
              item.pronunciation.trim(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(
                  alpha: FlashcardScreenTokens.mutedTextOpacity,
                ),
              ),
            ),
          ],
          const SizedBox(height: FlashcardScreenTokens.cardTextGap),
          Text(
            item.backText,
            style: theme.textTheme.bodyLarge,
            maxLines: FlashcardScreenTokens.backTextMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasNote) ...<Widget>[
            const SizedBox(height: FlashcardScreenTokens.cardTextGap),
            Text(
              noteText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(
                  alpha: FlashcardScreenTokens.mutedTextOpacity,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
