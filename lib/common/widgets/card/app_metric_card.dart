// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';
import '../../styles/app_sizes.dart';
import 'app_card.dart';

class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
    this.progress,
    this.minHeight = AppSizes.size72,
    this.padding = const EdgeInsets.all(AppSizes.spacingSm),
    this.elevation = AppSizes.size1,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final double? progress;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      variant: AppCardVariant.elevated,
      elevation: elevation,
      backgroundColor:
          backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: borderRadius,
      border: border,
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
              _AnimatedProgressBar(progress: progress!),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: SizedBox(
        height: AppSizes.size8,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: AppDurations.animationNormal,
          curve: AppMotionCurves.decelerateCubic,
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              color: colorScheme.secondary,
              backgroundColor: colorScheme.secondaryContainer,
            );
          },
        ),
      ),
    );
  }
}
