import 'dart:math';

import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';

class FlashcardFlip extends StatefulWidget {
  const FlashcardFlip({
    super.key,
    required this.front,
    required this.back,
    this.duration = AppDurations.animationEmphasized,
    this.initiallyFront = true,
    this.onFlipChanged,
  });

  final Widget front;
  final Widget back;
  final Duration duration;
  final bool initiallyFront;
  final ValueChanged<bool>? onFlipChanged;

  @override
  State<FlashcardFlip> createState() => _FlashcardFlipState();
}

class _FlashcardFlipState extends State<FlashcardFlip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late bool _isFront;

  @override
  void initState() {
    super.initState();
    _isFront = widget.initiallyFront;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (!widget.initiallyFront) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isAnimating) {
      return;
    }

    final bool nextIsFront = !_isFront;
    if (nextIsFront) {
      _controller.reverse();
    }
    if (!nextIsFront) {
      _controller.forward();
    }

    _isFront = nextIsFront;
    widget.onFlipChanged?.call(_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double angle = _controller.value * pi;
          final bool showFront = angle <= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}
