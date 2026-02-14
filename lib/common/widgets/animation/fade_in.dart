import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';

/// A widget that fades in its child with a customizable animation.
///
/// This widget animates the opacity of its child from [beginOpacity] to
/// [endOpacity] over the specified [duration]. It supports an optional
/// [delay] before the animation starts and respects the user's reduce-motion
/// preference by skipping the animation when enabled.
///
/// The animation automatically starts when the widget is built and uses
/// [TweenAnimationBuilder] internally for smooth transitions.
///
/// Example:
/// ```dart
/// FadeIn(
///   duration: AppDurations.animationFast,
///   delay: Duration(milliseconds: 100),
///   child: Text('Hello World'),
/// )
/// ```
///
/// See also:
///  * [ScaleIn], for scale animations
///  * [TweenAnimationBuilder], the underlying animation widget
class FadeIn extends StatelessWidget {
  const FadeIn({
    required this.child,
    super.key,
    this.duration = AppDurations.animationFast,
    this.delay = Duration.zero,
    this.curve = AppMotionCurves.decelerate,
    this.beginOpacity = 0,
    this.endOpacity = 1,
  }) : assert(beginOpacity >= 0, 'beginOpacity must be >= 0.'),
       assert(beginOpacity <= 1, 'beginOpacity must be <= 1.'),
       assert(endOpacity >= 0, 'endOpacity must be >= 0.'),
       assert(endOpacity <= 1, 'endOpacity must be <= 1.');

  /// The child widget to animate.
  final Widget child;

  /// The duration of the fade animation. Defaults to [AppDurations.animationFast].
  final Duration duration;

  /// Optional delay before the animation starts. Defaults to [Duration.zero].
  final Duration delay;

  /// The curve to apply to the animation. Defaults to [Curves.easeOut].
  final Curve curve;

  /// The starting opacity value (0.0 to 1.0). Defaults to 0.
  final double beginOpacity;

  /// The ending opacity value (0.0 to 1.0). Defaults to 1.
  final double endOpacity;

  @override
  Widget build(BuildContext context) {
    // Respect user's reduce-motion preference
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return Opacity(opacity: endOpacity, child: child);
    }

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
      curve: AppMotionCurves.linear,
      child: child,
      builder: (context, rawProgress, child) {
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
