import 'package:flutter/material.dart';

class AppLinearProgress extends StatelessWidget {
  const AppLinearProgress({
    super.key,
    required this.value,
    this.height = _LinearProgressConstants.defaultHeight,
    this.backgroundColor,
  }) : assert(value >= 0, 'value must be >= 0.'),
       assert(value <= 1, 'value must be <= 1.'),
       assert(height > 0, 'height must be > 0.');

  final double value;
  final double height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      minHeight: height,
      value: value,
      backgroundColor: backgroundColor,
    );
  }
}

class _LinearProgressConstants {
  const _LinearProgressConstants._();

  static const double defaultHeight = 8;
}
