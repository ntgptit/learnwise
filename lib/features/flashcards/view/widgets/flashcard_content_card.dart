import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_durations.dart';
import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../core/utils/string_utils.dart';
import '../../model/flashcard_models.dart';

class FlashcardContentCard extends StatefulWidget {
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
  State<FlashcardContentCard> createState() => _FlashcardContentCardState();
}

class _FlashcardContentCardState extends State<FlashcardContentCard> {
  late final ValueNotifier<bool> _isPressedNotifier;

  @override
  void initState() {
    super.initState();
    _isPressedNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _isPressedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String noteText = StringUtils.normalize(widget.item.note);
    final String pronunciationText = StringUtils.normalize(
      widget.item.pronunciation,
    );
    final bool hasNote = noteText.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _isPressedNotifier.value = true,
      onTapUp: (_) => _isPressedNotifier.value = false,
      onTapCancel: () => _isPressedNotifier.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isPressedNotifier,
        child: AppCard(
          variant: AppCardVariant.elevated,
          elevation: FlashcardScreenTokens.cardElevation,
          borderRadius: BorderRadius.circular(FlashcardScreenTokens.cardRadius),
          backgroundColor: colorScheme.surfaceContainerHigh,
          padding: const EdgeInsets.all(FlashcardScreenTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.item.frontText,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: FlashcardScreenTokens.cardPrimaryTextSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: FlashcardScreenTokens.cardPrimarySecondaryGap,
              ),
              Text(
                widget.item.backText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: FlashcardScreenTokens.cardSecondaryTextSize,
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
                      alpha: FlashcardScreenTokens.mutedTextOpacity,
                    ),
                  ),
                ),
              ],
              if (hasNote) ...<Widget>[
                const SizedBox(height: FlashcardScreenTokens.cardTextGap),
                Text(
                  noteText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: FlashcardScreenTokens.cardDescriptionTextSize,
                    color: colorScheme.onSurface.withValues(
                      alpha: FlashcardScreenTokens.cardDescriptionOpacity,
                    ),
                  ),
                  maxLines: FlashcardScreenTokens.cardDescriptionMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: FlashcardScreenTokens.cardTextGap),
              Align(
                alignment: Alignment.centerLeft,
                child: AppActionIconRow(
                  spacing: FlashcardScreenTokens.cardActionIconSpacing,
                  iconSize: FlashcardScreenTokens.cardActionIconSize,
                  tapTargetSize: FlashcardScreenTokens.cardActionTapTargetSize,
                  items: <AppActionIconItem>[
                    AppActionIconItem(
                      icon: Icons.volume_up_outlined,
                      activeIcon: Icons.graphic_eq_rounded,
                      tooltip: l10n.flashcardsPlayAudioTooltip,
                      onPressed: widget.onAudioPressed,
                      isActive: widget.isAudioPlaying,
                      activeColor: colorScheme.primary,
                    ),
                    AppActionIconItem(
                      icon: Icons.edit_outlined,
                      tooltip: l10n.flashcardsEditTooltip,
                      onPressed: widget.onEditPressed,
                    ),
                    AppActionIconItem(
                      icon: Icons.delete_outline_rounded,
                      tooltip: l10n.flashcardsDeleteTooltip,
                      onPressed: widget.onDeletePressed,
                    ),
                    AppActionIconItem(
                      icon: Icons.star_border,
                      activeIcon: Icons.star,
                      tooltip: l10n.flashcardsBookmarkTooltip,
                      onPressed: widget.onStarPressed,
                      isActive: widget.isStarred,
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
