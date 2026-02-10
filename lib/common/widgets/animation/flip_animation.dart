import 'dart:math';

import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';

class FlipAnimation extends StatelessWidget {
  const FlipAnimation({
    super.key,
    required this.front,
    required this.back,
    required this.isFlipped,
    this.onTap,
    this.duration = AppDurations.animationEmphasized,
    this.curve = Curves.easeInOutCubic,
    this.perspective = 0.001,
  }) : assert(perspective > 0, 'perspective must be > 0.');

  final Widget front;
  final Widget back;
  final bool isFlipped;
  final VoidCallback? onTap;
  final Duration duration;
  final Curve curve;
  final double perspective;

  @override
  Widget build(BuildContext context) {
    final Duration safeDuration = duration < Duration.zero
        ? Duration.zero
        : duration;

    final Widget animated = TweenAnimationBuilder<double>(
      tween: Tween<double>(end: isFlipped ? 1 : 0),
      duration: safeDuration,
      curve: curve,
      builder: (BuildContext context, double value, Widget? child) {
        final double angle = value * pi;
        final bool showFront = angle <= pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, perspective)
            ..rotateY(angle),
          child: showFront
              ? front
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: back,
                ),
        );
      },
    );

    if (onTap == null) {
      return animated;
    }

    return GestureDetector(onTap: onTap, child: animated);
  }
}
