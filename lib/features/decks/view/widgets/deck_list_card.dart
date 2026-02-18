// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';
import '../../model/deck_models.dart';

enum _DeckCardAction { open, edit, delete }

class DeckListCard extends StatelessWidget {
  const DeckListCard({
    required this.deck, required this.onOpenPressed, required this.onEditPressed, required this.onDeletePressed, super.key,
  });

  final DeckItem deck;
  final VoidCallback onOpenPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String description = deck.description.isEmpty
        ? l10n.decksNoDescriptionLabel
        : deck.description;
    final String metadata =
        '$description · ${l10n.decksFlashcardCountLabel(deck.flashcardCount)} · ${l10n.foldersAuditLabel(deck.updatedBy)}';

    return AppCard(
      onTap: onOpenPressed,
      padding: const EdgeInsets.symmetric(
        horizontal: FolderScreenTokens.listItemHorizontalPadding,
        vertical: FolderScreenTokens.listItemVerticalPadding,
      ),
      border: Border.all(
        color: colorScheme.outline.withValues(
          alpha: FolderScreenTokens.outlineOpacity,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: FolderScreenTokens.listItemLeadingSize,
            height: FolderScreenTokens.listItemLeadingSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: FolderScreenTokens.surfaceSoftOpacity,
              ),
              borderRadius: BorderRadius.circular(
                FolderScreenTokens.listItemLeadingRadius,
              ),
            ),
            margin: const EdgeInsets.only(
              top: FolderScreenTokens.colorDotTopMargin,
            ),
            child: Icon(
              Icons.collections_bookmark_outlined,
              color: colorScheme.primary,
              size: FolderScreenTokens.listItemLeadingIconSize,
            ),
          ),
          const SizedBox(width: FolderScreenTokens.listItemHorizontalGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  deck.name,
                  maxLines: FolderScreenTokens.nameMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: FolderScreenTokens.listItemTitleMetaGap),
                Text(
                  metadata,
                  maxLines: FolderScreenTokens.descriptionMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: FolderScreenTokens.dimOpacity,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_DeckCardAction>(
            onSelected: (action) {
              if (action == _DeckCardAction.open) {
                onOpenPressed();
                return;
              }
              if (action == _DeckCardAction.edit) {
                onEditPressed();
                return;
              }
              onDeletePressed();
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<_DeckCardAction>>[
                PopupMenuItem<_DeckCardAction>(
                  value: _DeckCardAction.open,
                  child: Text(l10n.decksOpenTooltip),
                ),
                PopupMenuItem<_DeckCardAction>(
                  value: _DeckCardAction.edit,
                  child: Text(l10n.decksEditTooltip),
                ),
                PopupMenuItem<_DeckCardAction>(
                  value: _DeckCardAction.delete,
                  child: Text(l10n.decksDeleteTooltip),
                ),
              ];
            },
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }
}
