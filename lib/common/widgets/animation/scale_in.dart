import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';

/// A widget that scales in its child with a customizable animation.
///
/// This widget animates the scale of its child from [beginScale] to
/// [endScale] over the specified [duration]. It respects the user's
/// reduce-motion preference by skipping the animation when enabled.
///
/// The animation automatically starts when the widget is built and uses
/// [TweenAnimationBuilder] internally for smooth transitions. The scale
/// transformation is applied around the specified [alignment] point.
///
/// Commonly used for entrance animations with a subtle bounce effect
/// when using curves like [Curves.easeOutBack].
///
/// Example:
/// ```dart
/// ScaleIn(
///   duration: AppDurations.animationNormal,
///   curve: Curves.easeOutBack,
///   child: Card(
///     child: Text('I bounce in!'),
///   ),
/// )
/// ```
///
/// See also:
///  * [FadeIn], for opacity animations
///  * [TweenAnimationBuilder], the underlying animation widget
class ScaleIn extends StatelessWidget {
  const ScaleIn({
    required this.child,
    super.key,
    this.duration = AppDurations.animationNormal,
    this.beginScale = 0.94,
    this.endScale = 1,
    this.alignment = Alignment.center,
    this.curve = AppMotionCurves.overshoot,
  }) : assert(beginScale >= 0, 'beginScale must be >= 0.'),
       assert(endScale >= 0, 'endScale must be >= 0.');

  /// The child widget to animate.
  final Widget child;

  /// The duration of the scale animation. Defaults to [AppDurations.animationNormal].
  final Duration duration;

  /// The starting scale value. Defaults to 0.94 for a subtle effect.
  final double beginScale;

  /// The ending scale value. Defaults to 1.0 (normal size).
  final double endScale;

  /// The alignment point for the scale transformation. Defaults to [Alignment.center].
  final Alignment alignment;

  /// The curve to apply to the animation. Defaults to [Curves.easeOutBack] for a bounce effect.
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    // Respect user's reduce-motion preference
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return Transform.scale(
        scale: endScale,
        alignment: alignment,
        child: child,
      );
    }

    final Duration safeDuration = duration < Duration.zero
        ? Duration.zero
        : duration;
    if (safeDuration == Duration.zero) {
      return Transform.scale(
        scale: endScale,
        alignment: alignment,
        child: child,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: beginScale, end: endScale),
      duration: safeDuration,
      curve: curve,
      child: child,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: alignment,
          child: child,
        );
      },
    );
  }
}
