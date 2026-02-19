import 'package:flutter/material.dart';

import '../../../app/theme/semantic_colors.dart';
import '../../styles/app_opacities.dart';

enum FlashcardResultType { correct, wrong, hard }

class LwFlashcardResultChip extends StatelessWidget {
  const LwFlashcardResultChip({required this.type, super.key, this.onTap});

  final FlashcardResultType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color foregroundColor = _foreground(type, colorScheme);

    return ActionChip(
      label: Text(_label(type)),
      labelStyle: TextStyle(color: foregroundColor),
      backgroundColor: _background(type, colorScheme),
      side: BorderSide(
        color: foregroundColor.withValues(alpha: AppOpacities.soft35),
      ),
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

  Color _foreground(FlashcardResultType value, ColorScheme colorScheme) {
    if (value == FlashcardResultType.correct) {
      return colorScheme.onSuccessContainer;
    }
    if (value == FlashcardResultType.wrong) {
      return colorScheme.onErrorContainer;
    }
    return colorScheme.onWarningContainer;
  }
}
