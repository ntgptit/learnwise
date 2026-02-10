import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/widgets/widgets.dart';

class FolderEmptyState extends StatelessWidget {
  const FolderEmptyState({super.key, required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return EmptyState(
      title: l10n.foldersEmptyTitle,
      subtitle: l10n.foldersEmptyDescription,
      icon: Icons.folder_off_outlined,
      action: FilledButton.icon(
        onPressed: onCreatePressed,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(l10n.foldersCreateButton),
      ),
    );
  }
}
