import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    required this.child, super.key,
    this.mobile = const EdgeInsets.all(AppSizes.spacingMd),
    this.tablet = const EdgeInsets.symmetric(
      horizontal: AppSizes.spacingLg,
      vertical: AppSizes.spacingMd,
    ),
    this.desktop = const EdgeInsets.symmetric(
      horizontal: AppSizes.size48,
      vertical: AppSizes.spacingLg,
    ),
    this.tabletBreakpoint = 600,
    this.desktopBreakpoint = 1100,
  });

  final Widget child;
  final EdgeInsetsGeometry mobile;
  final EdgeInsetsGeometry tablet;
  final EdgeInsetsGeometry desktop;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        if (width >= desktopBreakpoint) {
          return Padding(padding: desktop, child: child);
        }
        if (width >= tabletBreakpoint) {
          return Padding(padding: tablet, child: child);
        }
        return Padding(padding: mobile, child: child);
      },
    );
  }
}
