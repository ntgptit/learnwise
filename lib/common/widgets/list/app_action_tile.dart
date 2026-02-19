// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import '../card/app_card.dart';

class LwActionTile extends StatelessWidget {
  const LwActionTile({
    required this.label,
    required this.icon,
    super.key,
    this.subtitle,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return LwCard(
      onTap: onPressed,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingSm,
      ),
      backgroundColor: colorScheme.surfaceContainer,
      child: Row(
        children: <Widget>[
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: AppSizes.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.spacing2Xs),
                    child: Text(subtitle!, style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          if (onPressed != null)
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}
