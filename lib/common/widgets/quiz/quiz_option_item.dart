import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import '../../styles/app_opacities.dart';
import '../../../app/theme/colors.dart';

class QuizOptionItem extends StatelessWidget {
  const QuizOptionItem({
    required this.label, required this.text, required this.onTap, super.key,
    this.selected = false,
    this.correct = false,
    this.disabled = false,
  });

  final String label;
  final String text;
  final VoidCallback onTap;
  final bool selected;
  final bool correct;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Color borderColor = correct
        ? AppColors.success
        : selected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    final Color backgroundColor = correct
        ? AppColors.success.withValues(alpha: AppOpacities.soft10)
        : selected
        ? colorScheme.primary.withValues(alpha: AppOpacities.soft08)
        : colorScheme.surface;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacingMd),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: AppSizes.size14,
              child: Text(
                label,
                style: const TextStyle(fontSize: AppSizes.spacingSm),
              ),
            ),
            const SizedBox(width: AppSizes.spacingSm),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
