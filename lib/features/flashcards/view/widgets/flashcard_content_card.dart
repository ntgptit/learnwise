// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_durations.dart';
import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/styles/app_sizes.dart';
import '../../../../common/styles/app_opacities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../core/utils/string_utils.dart';
import '../../model/flashcard_models.dart';

class FlashcardContentCard extends HookWidget {
  const FlashcardContentCard({
    required this.item,
    required this.isStarred,
    required this.isAudioPlaying,
    required this.onAudioPressed,
    required this.onStarPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
    super.key,
  });

  final FlashcardItem item;
  final bool isStarred;
  final bool isAudioPlaying;
  final VoidCallback onAudioPressed;
  final VoidCallback onStarPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isPressedNotifier = useState<bool>(false);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String noteText = StringUtils.normalize(item.note);
    final String pronunciationText = StringUtils.normalize(item.pronunciation);
    final bool hasNote = noteText.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => isPressedNotifier.value = true,
      onTapUp: (_) => isPressedNotifier.value = false,
      onTapCancel: () => isPressedNotifier.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: isPressedNotifier,
        child: LwCard(
          variant: AppCardVariant.elevated,
          borderRadius: BorderRadius.circular(FlashcardScreenTokens.cardRadius),
          backgroundColor: colorScheme.surfaceContainerHigh,
          padding: const EdgeInsets.all(
            FlashcardScreenTokens.cardPadding + AppSizes.spacing2Xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(item.frontText, style: theme.textTheme.titleLarge),
              const SizedBox(
                height: FlashcardScreenTokens.cardPrimarySecondaryGap,
              ),
              Text(
                item.backText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: FlashcardScreenTokens.cardSecondaryMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
              if (pronunciationText.isNotEmpty) ...<Widget>[
                const SizedBox(height: FlashcardScreenTokens.listMetadataGap),
                Text(
                  pronunciationText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppOpacities.muted82,
                    ),
                  ),
                ),
              ],
              if (hasNote) ...<Widget>[
                const SizedBox(height: FlashcardScreenTokens.cardTextGap),
                Text(
                  noteText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppOpacities.muted82,
                    ),
                  ),
                  maxLines: FlashcardScreenTokens.cardDescriptionMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: FlashcardScreenTokens.cardTextGap),
              Align(
                alignment: Alignment.centerLeft,
                child: LwActionIconRow(
                  spacing: FlashcardScreenTokens.cardActionIconSpacing,
                  iconSize: FlashcardScreenTokens.cardActionIconSize,
                  tapTargetSize: FlashcardScreenTokens.cardActionTapTargetSize,
                  items: <LwActionIconItem>[
                    LwActionIconItem(
                      icon: Icons.volume_up_outlined,
                      activeIcon: Icons.graphic_eq_rounded,
                      tooltip: l10n.flashcardsPlayAudioTooltip,
                      onPressed: onAudioPressed,
                      isActive: isAudioPlaying,
                      activeColor: colorScheme.primary,
                    ),
                    LwActionIconItem(
                      icon: Icons.edit_outlined,
                      tooltip: l10n.flashcardsEditTooltip,
                      onPressed: onEditPressed,
                    ),
                    LwActionIconItem(
                      icon: Icons.delete_outline_rounded,
                      tooltip: l10n.flashcardsDeleteTooltip,
                      onPressed: onDeletePressed,
                    ),
                    LwActionIconItem(
                      icon: Icons.star_border,
                      activeIcon: Icons.star,
                      tooltip: l10n.flashcardsBookmarkTooltip,
                      onPressed: onStarPressed,
                      isActive: isStarred,
                      activeColor: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        builder: (context, isPressed, child) {
          return AnimatedScale(
            duration: AppDurations.animationQuick,
            curve: Curves.easeOutCubic,
            scale: isPressed ? FlashcardScreenTokens.cardPressedScale : 1,
            child: child,
          );
        },
      ),
    );
  }
}
