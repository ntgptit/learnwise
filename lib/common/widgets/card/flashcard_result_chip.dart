import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../styles/app_opacities.dart';

enum FlashcardResultType { correct, wrong, hard }

class FlashcardResultChip extends StatelessWidget {
  const FlashcardResultChip({required this.type, super.key, this.onTap});

  final FlashcardResultType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(_label(type)),
      backgroundColor: _background(type),
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

  Color _background(FlashcardResultType value) {
    if (value == FlashcardResultType.correct) {
      return AppColors.success.withValues(alpha: AppOpacities.soft15);
    }
    if (value == FlashcardResultType.wrong) {
      return AppColors.error.withValues(alpha: AppOpacities.soft15);
    }
    return AppColors.warning.withValues(alpha: AppOpacities.soft20);
  }
}
