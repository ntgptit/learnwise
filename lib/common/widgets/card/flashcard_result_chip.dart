import 'package:flutter/material.dart';

import '../../../app/theme/semantic_colors.dart';

enum FlashcardResultType { correct, wrong, hard }

class FlashcardResultChip extends StatelessWidget {
  const FlashcardResultChip({required this.type, super.key, this.onTap});

  final FlashcardResultType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      label: Text(_label(type)),
      backgroundColor: _background(type, colorScheme),
      onPressed: onTap,
    );
  }

  String _label(FlashcardResultType value) {
    if (value == FlashcardResultType.correct) {
      return 'Correct';
    }
    if (value == FlashcardResultType.wrong) {
      return 'Wrong';
    }
    return 'Hard';
  }

  Color _background(FlashcardResultType value, ColorScheme colorScheme) {
    if (value == FlashcardResultType.correct) {
      return colorScheme.successContainer;
    }
    if (value == FlashcardResultType.wrong) {
      return colorScheme.errorContainer;
    }
    return colorScheme.warningContainer;
  }
}
