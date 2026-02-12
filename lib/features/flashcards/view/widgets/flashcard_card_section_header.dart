import 'package:flutter/material.dart';

class FlashcardCardSectionHeader extends StatelessWidget {
  const FlashcardCardSectionHeader({
    required this.title, required this.sortLabel, required this.onSortPressed, super.key,
  });

  final String title;
  final String sortLabel;
  final VoidCallback onSortPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onSortPressed,
          icon: const Icon(Icons.tune),
          label: Text(sortLabel),
        ),
      ],
    );
  }
}
