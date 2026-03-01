import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// A [Column] that automatically adds spacing between children.
///
/// This convenience widget wraps [Column] and inserts [SizedBox] widgets
/// with the specified [spacing] height between each child. This eliminates
/// the need to manually add spacing widgets in your UI code.
///
/// This is more concise and maintainable than manually adding SizedBox
/// between each child widget.
///
/// Example:
/// ```dart
/// LwSpacedColumn(
///   spacing: AppSizes.spacingMd,
///   children: [
///     Text('First item'),
///     Text('Second item'),
///     Text('Third item'),
///   ],
/// )
/// ```
///
/// See also:
///  * [LwSpacedRow], for horizontal spacing
///  * [Column], the underlying widget
class LwSpacedColumn extends StatelessWidget {
  const LwSpacedColumn({
    required this.children,
    super.key,
    this.spacing = AppSizes.spacingSm,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  /// The list of child widgets to display vertically with spacing.
  final List<Widget> children;

  /// The vertical spacing between children. Defaults to [AppSizes.spacingSm].
  final double spacing;

  /// How the children should be placed along the main axis.
  ///
  /// Defaults to [MainAxisAlignment.start].
  final MainAxisAlignment mainAxisAlignment;

  /// How the children should be aligned along the cross axis.
  ///
  /// Defaults to [CrossAxisAlignment.center].
  final CrossAxisAlignment crossAxisAlignment;

  /// How much space should be occupied in the main axis.
  ///
  /// Defaults to [MainAxisSize.max].
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Column(
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
      spacedChildren.add(SizedBox(height: spacing));
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}
