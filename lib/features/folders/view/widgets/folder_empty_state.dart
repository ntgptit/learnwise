import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../../../common/widgets/widgets.dart';

class FolderEmptyState extends StatelessWidget {
  const FolderEmptyState({
    required this.description, required this.onCreatePressed, required this.onCreateDeckPressed, super.key,
  });

  final String description;
  final VoidCallback? onCreatePressed;
  final VoidCallback? onCreateDeckPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return EmptyState(
      title: l10n.foldersEmptyTitle,
      subtitle: description,
      icon: Icons.folder_off_outlined,
      action: Wrap(
        spacing: AppSizes.spacingSm,
        runSpacing: AppSizes.spacingSm,
        children: <Widget>[
          FilledButton.icon(
            onPressed: onCreatePressed,
            icon: const Icon(Icons.create_new_folder_outlined),
            label: Text(l10n.foldersCreateButton),
          ),
          FilledButton.tonalIcon(
            onPressed: onCreateDeckPressed,
            icon: const Icon(Icons.collections_bookmark_outlined),
            label: Text(l10n.decksCreateButton),
          ),
        ],
      ),
    );
  }
}
