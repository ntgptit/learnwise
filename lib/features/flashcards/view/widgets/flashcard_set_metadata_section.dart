import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../core/utils/string_utils.dart';

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
    final String initial = resolvedOwner.characters.first.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: FlashcardScreenTokens.metadataGap),
        Wrap(
          spacing: FlashcardScreenTokens.metadataHorizontalGap,
          runSpacing: FlashcardScreenTokens.metadataHorizontalGap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            _OwnerIdentityCard(initial: initial, ownerName: resolvedOwner),
            _TotalFlashcardsChip(
              label: l10n.flashcardsTotalLabel(totalFlashcards),
            ),
          ],
        ),
      ],
    );
  }
}

class _OwnerIdentityCard extends StatelessWidget {
  const _OwnerIdentityCard({required this.initial, required this.ownerName});

  final String initial;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FlashcardScreenTokens.metadataOwnerCardHorizontalPadding,
        vertical: FlashcardScreenTokens.metadataOwnerCardVerticalPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          FlashcardScreenTokens.metadataOwnerCardRadius,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.primaryContainer.withValues(
              alpha: FlashcardScreenTokens.metadataOwnerCardPrimaryOpacity,
            ),
            colorScheme.tertiaryContainer.withValues(
              alpha: FlashcardScreenTokens.metadataOwnerCardSecondaryOpacity,
            ),
          ],
        ),
        border: Border.all(
          color: colorScheme.outline.withValues(
            alpha: FlashcardScreenTokens.outlineOpacity,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: FlashcardScreenTokens.metadataOwnerCardShadowOpacity,
            ),
            blurRadius: FlashcardScreenTokens.metadataOwnerCardShadowBlur,
            offset: const Offset(
              0,
              FlashcardScreenTokens.metadataOwnerCardShadowOffsetY,
            ),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(
              FlashcardScreenTokens.metadataAvatarHaloPadding,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surface.withValues(
                alpha: FlashcardScreenTokens.metadataAvatarHaloOpacity,
              ),
            ),
            child: CircleAvatar(
              radius: FlashcardScreenTokens.metadataAvatarSize / 2,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: Text(
                initial,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: FlashcardScreenTokens.metadataHorizontalGap),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: FlashcardScreenTokens.metadataOwnerNameMaxWidth,
            ),
            child: Text(
              ownerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalFlashcardsChip extends StatelessWidget {
  const _TotalFlashcardsChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FlashcardScreenTokens.metadataCountChipHorizontalPadding,
        vertical: FlashcardScreenTokens.metadataCountChipVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: FlashcardScreenTokens.surfaceSoftOpacity,
        ),
        borderRadius: BorderRadius.circular(
          FlashcardScreenTokens.metadataCountChipRadius,
        ),
        border: Border.all(
          color: colorScheme.outline.withValues(
            alpha: FlashcardScreenTokens.outlineOpacity,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.style_outlined,
            size: FlashcardScreenTokens.metadataCountChipIconSize,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: FlashcardScreenTokens.metadataCountChipIconGap),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
