import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import 'shimmer_box.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 72,
    this.itemSpacing = AppSizes.spacingSm,
    this.padding = const EdgeInsets.all(AppSizes.spacingMd),
  }) : assert(itemCount > 0, 'itemCount must be greater than 0.'),
       assert(itemHeight > 0, 'itemHeight must be greater than 0.'),
       assert(itemSpacing >= 0, 'itemSpacing must be >= 0.');

  final int itemCount;
  final double itemHeight;
  final double itemSpacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final int safeItemCount = itemCount <= 0 ? 1 : itemCount;
    final double safeItemHeight = itemHeight <= 0 ? 48 : itemHeight;
    final double safeItemSpacing = itemSpacing < 0 ? 0 : itemSpacing;

    return ListView.separated(
      padding: padding,
      itemCount: safeItemCount,
      separatorBuilder: (context, index) {
        return SizedBox(height: safeItemSpacing);
      },
      itemBuilder: (context, index) {
        return ShimmerBox(height: safeItemHeight, borderRadius: 12);
      },
    );
  }
}
