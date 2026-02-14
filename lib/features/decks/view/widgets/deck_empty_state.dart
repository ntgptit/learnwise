import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/widgets/widgets.dart';

class DeckEmptyState extends StatelessWidget {
  const DeckEmptyState({
    required this.subtitle,
    required this.onCreateDeckPressed,
    super.key,
  });

  final String subtitle;
  final VoidCallback? onCreateDeckPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return EmptyState(
      title: l10n.decksEmptyTitle,
      subtitle: subtitle,
      icon: Icons.collections_bookmark_outlined,
      action: onCreateDeckPressed == null
          ? null
          : FilledButton.tonalIcon(
              onPressed: onCreateDeckPressed,
              icon: const Icon(Icons.style_rounded),
              label: Text(l10n.decksCreateButton),
            ),
    );
  }
}
