import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import 'app_card.dart';

class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    required this.icon, required this.label, required this.value, super.key,
    this.progress,
    this.minHeight = AppSizes.size72,
    this.padding = const EdgeInsets.all(AppSizes.spacingSm),
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final double? progress;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: AppSizes.spacingLg),
                const SizedBox(width: AppSizes.spacingXs),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingXs),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (progress != null) ...<Widget>[
              const SizedBox(height: AppSizes.spacing2Xs),
              LinearProgressIndicator(value: progress),
            ],
          ],
        ),
      ),
    );
  }
}
