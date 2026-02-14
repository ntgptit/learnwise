import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';

class SlideIn extends StatelessWidget {
  const SlideIn({
    required this.child,
    super.key,
    this.duration = AppDurations.animationNormal,
    this.beginOffset = const Offset(0, 0.08),
    this.endOffset = Offset.zero,
    this.curve = AppMotionCurves.decelerateCubic,
  });

  final Widget child;
  final Duration duration;
  final Offset beginOffset;
  final Offset endOffset;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    // Respect user's reduce-motion preference
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return FractionalTranslation(translation: endOffset, child: child);
    }

    final Duration safeDuration = duration < Duration.zero
        ? Duration.zero
        : duration;
    if (safeDuration == Duration.zero) {
      return FractionalTranslation(translation: endOffset, child: child);
    }

    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: beginOffset, end: endOffset),
      duration: safeDuration,
      curve: curve,
      child: child,
      builder: (context, value, child) {
        return FractionalTranslation(translation: value, child: child);
      },
    );
  }
}
