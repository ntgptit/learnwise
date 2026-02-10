import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';

class FadeIn extends StatelessWidget {
  const FadeIn({
    super.key,
    required this.child,
    this.duration = AppDurations.animationFast,
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.beginOpacity = 0,
    this.endOpacity = 1,
  }) : assert(beginOpacity >= 0, 'beginOpacity must be >= 0.'),
       assert(beginOpacity <= 1, 'beginOpacity must be <= 1.'),
       assert(endOpacity >= 0, 'endOpacity must be >= 0.'),
       assert(endOpacity <= 1, 'endOpacity must be <= 1.');

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginOpacity;
  final double endOpacity;

  @override
  Widget build(BuildContext context) {
    final Duration safeDuration = duration < Duration.zero
        ? Duration.zero
        : duration;
    final Duration safeDelay = delay < Duration.zero ? Duration.zero : delay;
    final Duration totalDuration = safeDuration + safeDelay;
    if (totalDuration == Duration.zero) {
      return Opacity(opacity: endOpacity, child: child);
    }

    final double delayRatio =
        safeDelay.inMilliseconds / totalDuration.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: totalDuration,
      curve: Curves.linear,
      child: child,
      builder: (BuildContext context, double rawProgress, Widget? child) {
        final double delayedProgress = _applyDelay(
          progress: rawProgress,
          delayRatio: delayRatio,
        );
        final double curvedProgress = curve.transform(delayedProgress);
        final double opacity =
            beginOpacity + ((endOpacity - beginOpacity) * curvedProgress);
        return Opacity(opacity: opacity, child: child);
      },
    );
  }

  double _applyDelay({required double progress, required double delayRatio}) {
    if (delayRatio <= 0) {
      return progress;
    }
    if (progress <= delayRatio) {
      return 0;
    }

    final double normalized = (progress - delayRatio) / (1 - delayRatio);
    return normalized.clamp(0, 1).toDouble();
  }
}
