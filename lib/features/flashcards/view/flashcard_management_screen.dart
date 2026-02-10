import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../common/styles/app_sizes.dart';
import '../model/flashcard_management_args.dart';

class FlashcardManagementScreen extends StatelessWidget {
  const FlashcardManagementScreen({super.key, required this.args});

  static const double _screenPadding = AppSizes.spacingMd;
  static const double _sectionSpacing = AppSizes.spacingSm;
  static const double _cardRadius = AppSizes.radiusMd;

  final FlashcardManagementArgs args;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String title = _resolveTitle(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.flashcardsTotalLabel(args.totalFlashcards),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: _sectionSpacing),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(_screenPadding),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(_cardRadius),
                ),
                child: Text(
                  l10n.flashcardsFeatureDescription,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveTitle(AppLocalizations l10n) {
    if (args.folderName.isEmpty) {
      return l10n.flashcardsTitle;
    }
    return l10n.flashcardsManageTitle(args.folderName);
  }
}
