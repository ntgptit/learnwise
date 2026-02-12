import 'package:flutter/material.dart';

class SpacedRow extends StatelessWidget {
  const SpacedRow({
    required this.children, super.key,
    this.spacing = 12,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
      );
    }

    final List<Widget> spacedChildren = <Widget>[];
    for (int index = 0; index < children.length; index++) {
      spacedChildren.add(children[index]);
      if (index == children.length - 1) {
        continue;
      }
      spacedChildren.add(SizedBox(width: spacing));
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}
