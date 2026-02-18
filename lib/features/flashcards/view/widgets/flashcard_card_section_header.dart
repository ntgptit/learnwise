// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/styles/app_opacities.dart';

class FlashcardCardSectionHeader extends StatelessWidget {
  const FlashcardCardSectionHeader({
    required this.title,
    required this.subtitle,
    required this.sortLabel,
    required this.onSortPressed,
    super.key,
  });

  final String title;
  final String subtitle;
  final String sortLabel;
  final VoidCallback onSortPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextStyle? titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final TextStyle? subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: AppOpacities.muted70),
    );
    final TextStyle? chipTextStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
              const SizedBox(
                height: FlashcardScreenTokens.sectionHeaderSubtitleGap,
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subtitleStyle,
              ),
            ],
          ),
        ),
        const SizedBox(width: FlashcardScreenTokens.sectionHeaderActionGap),
        ActionChip(
          onPressed: onSortPressed,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(sortLabel, style: chipTextStyle),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity,
          ),
        ),
      ],
    );
  }
}
