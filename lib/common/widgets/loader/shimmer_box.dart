import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';
import '../../styles/app_sizes.dart';

class LwShimmerBox extends StatefulWidget {
  const LwShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = AppSizes.spacingMd,
    this.borderRadius = AppSizes.radiusSm,
    this.baseColor,
    this.highlightColor,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<LwShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<LwShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.shimmerLoop,
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color base = widget.baseColor ?? colorScheme.surfaceContainerHighest;
    final Color highlight = widget.highlightColor ?? colorScheme.surface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        final double dx = -1 + (2 * t);

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + dx, -1),
              end: Alignment(1 + dx, 1),
              colors: <Color>[base, highlight, base],
              stops: const <double>[0.0, 0.5, 1.0],
              transform: const GradientRotation(pi / 16),
            ),
          ),
        );
      },
    );
  }
}
