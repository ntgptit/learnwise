// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/styles/app_opacities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../model/folder_models.dart';
import 'folder_color_resolver.dart';

enum _FolderCardAction { edit, delete }

class FolderListCard extends StatelessWidget {
  const FolderListCard({
    required this.folder,
    required this.onOpenPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
    super.key,
  });

  final FolderItem folder;
  final VoidCallback onOpenPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color folderColor = resolveFolderColor(
      folder.colorHex,
      colorScheme.primary,
    );
    final String description = folder.description.isEmpty
        ? l10n.foldersNoDescriptionLabel
        : folder.description;
    final String metadata =
        '$description \u00b7 ${l10n.foldersDeckCountLabel(folder.directDeckCount)} \u00b7 ${l10n.foldersFlashcardCountLabel(folder.flashcardCount)} \u00b7 ${l10n.foldersAuditLabel(folder.updatedBy)}';

    return AppCard(
      onTap: onOpenPressed,
      padding: const EdgeInsets.symmetric(
        horizontal: FolderScreenTokens.listItemHorizontalPadding,
        vertical: FolderScreenTokens.listItemVerticalPadding,
      ),
      border: Border.all(
        color: colorScheme.outline.withValues(alpha: AppOpacities.outline26),
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
                alpha: AppOpacities.soft20,
              ),
              borderRadius: BorderRadius.circular(
                FolderScreenTokens.listItemLeadingRadius,
              ),
            ),
            margin: const EdgeInsets.only(
              top: FolderScreenTokens.colorDotTopMargin,
            ),
            child: Icon(
              Icons.folder_outlined,
              color: folderColor,
              size: FolderScreenTokens.listItemLeadingIconSize,
            ),
          ),
          const SizedBox(width: FolderScreenTokens.listItemHorizontalGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  folder.name,
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
                      alpha: AppOpacities.muted82,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_FolderCardAction>(
            onSelected: (action) {
              if (action == _FolderCardAction.edit) {
                onEditPressed();
                return;
              }
              onDeletePressed();
            },
            itemBuilder: (context) {
              return <PopupMenuEntry<_FolderCardAction>>[
                PopupMenuItem<_FolderCardAction>(
                  value: _FolderCardAction.edit,
                  child: Text(l10n.foldersEditTooltip),
                ),
                PopupMenuItem<_FolderCardAction>(
                  value: _FolderCardAction.delete,
                  child: Text(l10n.foldersDeleteTooltip),
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
