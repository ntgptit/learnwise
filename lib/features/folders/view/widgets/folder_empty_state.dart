import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../../../common/widgets/widgets.dart';

class FolderEmptyState extends StatelessWidget {
  const FolderEmptyState({
    required this.description,
    required this.onCreatePressed,
    required this.onCreateDeckPressed,
    super.key,
  });

  final String description;
  final VoidCallback? onCreatePressed;
  final VoidCallback? onCreateDeckPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return LwEmptyState(
      title: l10n.foldersEmptyTitle,
      subtitle: description,
      icon: Icons.folder_off_outlined,
      action: _buildAction(l10n),
    );
  }

  Widget? _buildAction(AppLocalizations l10n) {
    final List<Widget> actions = <Widget>[];
    final Widget? createFolderButton = _buildCreateFolderButton(l10n);
    final Widget? createDeckButton = _buildCreateDeckButton(l10n);

    if (createFolderButton != null) {
      actions.add(createFolderButton);
    }
    if (createDeckButton != null) {
      actions.add(createDeckButton);
    }

    if (actions.isEmpty) {
      return null;
    }
    return Wrap(
      spacing: AppSizes.spacingSm,
      runSpacing: AppSizes.spacingSm,
      children: actions,
    );
  }

  Widget? _buildCreateFolderButton(AppLocalizations l10n) {
    if (onCreatePressed == null) {
      return null;
    }
    return FilledButton.icon(
      onPressed: onCreatePressed,
      icon: const Icon(Icons.create_new_folder_outlined),
      label: Text(l10n.foldersCreateButton),
    );
  }

  Widget? _buildCreateDeckButton(AppLocalizations l10n) {
    if (onCreateDeckPressed == null) {
      return null;
    }
    return FilledButton.tonalIcon(
      onPressed: onCreateDeckPressed,
      icon: const Icon(Icons.collections_bookmark_outlined),
      label: Text(l10n.decksCreateButton),
    );
  }
}
