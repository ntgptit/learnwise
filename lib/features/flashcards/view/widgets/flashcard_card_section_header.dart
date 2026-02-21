// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../../../common/widgets/widgets.dart';

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
    final TextStyle? chipTextStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return LwSectionTitle(
      title: title,
      subtitle: subtitle,
      trailing: OutlinedButton.icon(
        onPressed: onSortPressed,
        icon: const Icon(Icons.tune_rounded),
        label: Text(sortLabel, style: chipTextStyle),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSizes.size48),
        ),
      ),
    );
  }
}
