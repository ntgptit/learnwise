import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';
import '../../model/folder_models.dart';
import 'folder_color_resolver.dart';

class FolderListCard extends StatelessWidget {
  const FolderListCard({
    super.key,
    required this.folder,
    required this.onOpenPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  final FolderItem folder;
  final VoidCallback onOpenPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color folderColor = resolveFolderColor(
      folder.colorHex,
      colorScheme.primary,
    );

    return AppCard(
      onTap: onOpenPressed,
      padding: const EdgeInsets.all(FolderScreenTokens.cardPadding),
      border: Border.all(
        color: colorScheme.outline.withValues(
          alpha: FolderScreenTokens.outlineOpacity,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: FolderScreenTokens.colorDotSize,
            height: FolderScreenTokens.colorDotSize,
            margin: const EdgeInsets.only(
              top: FolderScreenTokens.colorDotTopMargin,
            ),
            decoration: BoxDecoration(
              color: folderColor,
              borderRadius: BorderRadius.circular(
                FolderScreenTokens.colorDotRadius,
              ),
            ),
          ),
          const SizedBox(width: FolderScreenTokens.cardHorizontalGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  folder.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: FolderScreenTokens.cardMetaGap),
                Text(
                  folder.description.isEmpty
                      ? l10n.foldersNoDescriptionLabel
                      : folder.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: FolderScreenTokens.cardMetaGap),
                AppMetadataList(
                  spacing: FolderScreenTokens.cardMetaGap,
                  color: colorScheme.onSurface.withValues(
                    alpha: FolderScreenTokens.dimOpacity,
                  ),
                  items: <String>[
                    l10n.foldersFlashcardCountLabel(folder.flashcardCount),
                    l10n.foldersSubfolderCountLabel(folder.childFolderCount),
                    l10n.foldersAuditLabel(folder.updatedBy),
                  ],
                ),
              ],
            ),
          ),
          AppActionIconRow(
            items: <AppActionIconItem>[
              AppActionIconItem(
                icon: Icons.keyboard_arrow_right_rounded,
                tooltip: l10n.foldersOpenTooltip,
                onPressed: onOpenPressed,
              ),
              AppActionIconItem(
                icon: Icons.edit_outlined,
                tooltip: l10n.foldersEditTooltip,
                onPressed: onEditPressed,
              ),
              AppActionIconItem(
                icon: Icons.delete_outline_rounded,
                tooltip: l10n.foldersDeleteTooltip,
                onPressed: onDeletePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
