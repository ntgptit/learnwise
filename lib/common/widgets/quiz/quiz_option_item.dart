// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../../app/theme/semantic_colors.dart';
import '../../styles/app_opacities.dart';
import '../../styles/app_sizes.dart';

class QuizOptionItem extends StatelessWidget {
  const QuizOptionItem({
    required this.label,
    required this.text,
    required this.onTap,
    super.key,
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

    final Color contentColor = correct
        ? colorScheme.onSuccessContainer
        : selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    final Color borderColor = correct
        ? colorScheme.onSuccessContainer
        : selected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    final Color backgroundColor = correct
        ? colorScheme.successContainer
        : selected
        ? colorScheme.primaryContainer
        : colorScheme.surface;

    final Color avatarBackgroundColor = contentColor.withValues(
      alpha: AppOpacities.soft20,
    );

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
              backgroundColor: avatarBackgroundColor,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.spacingSm,
                  color: contentColor,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacingSm),
            Expanded(
              child: Text(text, style: TextStyle(color: contentColor)),
            ),
          ],
        ),
      ),
    );
  }
}
