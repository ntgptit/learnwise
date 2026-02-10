import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';

class ScaleIn extends StatelessWidget {
  const ScaleIn({
    super.key,
    required this.child,
    this.duration = AppDurations.animationNormal,
    this.beginScale = 0.94,
    this.endScale = 1,
    this.alignment = Alignment.center,
    this.curve = Curves.easeOutBack,
  }) : assert(beginScale >= 0, 'beginScale must be >= 0.'),
       assert(endScale >= 0, 'endScale must be >= 0.');

  final Widget child;
  final Duration duration;
  final double beginScale;
  final double endScale;
  final Alignment alignment;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
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
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          alignment: alignment,
          child: child,
        );
      },
    );
  }
}
