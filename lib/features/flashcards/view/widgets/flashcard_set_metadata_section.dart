// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/styles/app_opacities.dart';
import '../../../../core/utils/string_utils.dart';

const String _metadataSeparator = ' • ';

class FlashcardSetMetadataSection extends StatelessWidget {
  const FlashcardSetMetadataSection({
    required this.title,
    required this.ownerName,
    required this.totalFlashcards,
    super.key,
  });

  final String title;
  final String ownerName;
  final int totalFlashcards;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final String? normalizedOwnerName = StringUtils.normalizeNullable(
      ownerName,
    );
    final String resolvedOwner =
        normalizedOwnerName ?? l10n.flashcardsOwnerFallback;
    final String cardCountLabel = l10n.decksFlashcardCountLabel(
      totalFlashcards,
    );
    final String metadataLine = [
      resolvedOwner,
      cardCountLabel,
      l10n.flashcardsUpdatedRecentlyLabel,
    ].join(_metadataSeparator);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: FlashcardScreenTokens.metadataTitleBottomGap),
        Text(
          metadataLine,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(
              alpha: AppOpacities.muted70,
            ),
          ),
        ),
      ],
    );
  }
}
