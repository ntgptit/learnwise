import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../model/folder_constants.dart';
import '../../model/folder_models.dart';
import 'folder_color_resolver.dart';

Future<FolderUpsertInput?> showFolderEditorDialog({
  required BuildContext context,
  required FolderItem? initialFolder,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final TextEditingController nameController = TextEditingController(
    text: initialFolder?.name ?? '',
  );
  final TextEditingController descriptionController = TextEditingController(
    text: initialFolder?.description ?? '',
  );
  String selectedColorHex =
      initialFolder?.colorHex ?? FolderConstants.defaultColorHex;

  final FolderUpsertInput? input = await showDialog<FolderUpsertInput>(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder:
            (
              BuildContext context,
              void Function(void Function()) setDialogState,
            ) {
              return AlertDialog(
                title: Text(
                  initialFolder == null
                      ? l10n.foldersCreateDialogTitle
                      : l10n.foldersEditDialogTitle,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        controller: nameController,
                        maxLength: FolderConstants.nameMaxLength,
                        decoration: InputDecoration(
                          labelText: l10n.foldersNameLabel,
                          hintText: l10n.foldersNameHint,
                        ),
                      ),
                      const SizedBox(height: FolderScreenTokens.sectionSpacing),
                      TextField(
                        controller: descriptionController,
                        maxLength: FolderConstants.descriptionMaxLength,
                        maxLines: FolderScreenTokens.descriptionMaxLines,
                        decoration: InputDecoration(
                          labelText: l10n.foldersDescriptionLabel,
                          hintText: l10n.foldersDescriptionHint,
                        ),
                      ),
                      const SizedBox(height: FolderScreenTokens.sectionSpacing),
                      Text(
                        l10n.foldersColorLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(
                        height: FolderScreenTokens.colorGridSpacing,
                      ),
                      Wrap(
                        spacing: FolderScreenTokens.colorGridSpacing,
                        runSpacing: FolderScreenTokens.colorGridSpacing,
                        children: FolderConstants.colorPresets.map((
                          String colorHex,
                        ) {
                          final bool isSelected = colorHex == selectedColorHex;
                          final Color color = resolveFolderColor(
                            colorHex,
                            Theme.of(context).colorScheme.primary,
                          );

                          return InkWell(
                            borderRadius: BorderRadius.circular(
                              FolderScreenTokens.colorBorderRadius,
                            ),
                            onTap: () {
                              setDialogState(() {
                                selectedColorHex = colorHex;
                              });
                            },
                            child: Container(
                              width: FolderScreenTokens.colorItemSize,
                              height: FolderScreenTokens.colorItemSize,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(
                                  FolderScreenTokens.colorBorderRadius,
                                ),
                                border: Border.all(
                                  width:
                                      FolderScreenTokens.colorItemBorderWidth,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.foldersCancelLabel),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(
                        FolderUpsertInput(
                          name: nameController.text,
                          description: descriptionController.text,
                          colorHex: selectedColorHex,
                          parentFolderId: initialFolder?.parentFolderId,
                        ),
                      );
                    },
                    child: Text(
                      initialFolder == null
                          ? l10n.foldersSaveLabel
                          : l10n.foldersUpdateLabel,
                    ),
                  ),
                ],
              );
            },
      );
    },
  );

  nameController.dispose();
  descriptionController.dispose();
  return input;
}
