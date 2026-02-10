import 'package:flutter/material.dart';

class AppCircularProgress extends StatelessWidget {
  const AppCircularProgress({
    super.key,
    required this.value,
    this.size = _CircularProgressConst.defaultSize,
    this.strokeWidth = _CircularProgressConst.defaultStrokeWidth,
    this.label,
  }) : assert(value >= 0, 'value must be >= 0.'),
       assert(value <= 1, 'value must be <= 1.'),
       assert(size > 0, 'size must be > 0.'),
       assert(strokeWidth > 0, 'strokeWidth must be > 0.');

  final double value;
  final double size;
  final double strokeWidth;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(value: value, strokeWidth: strokeWidth),
          if (label != null) Text(label!),
        ],
      ),
    );
  }
}

class _CircularProgressConst {
  const _CircularProgressConst._();

  static const double defaultSize = 44;
  static const double defaultStrokeWidth = 4;
}
