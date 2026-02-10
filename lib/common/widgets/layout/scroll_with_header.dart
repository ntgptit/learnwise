import 'package:flutter/material.dart';

class ScrollWithHeader extends StatelessWidget {
  const ScrollWithHeader({
    super.key,
    required this.header,
    required this.slivers,
    this.pinnedHeader = true,
  });

  final Widget header;
  final List<Widget> slivers;
  final bool pinnedHeader;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: pinnedHeader,
          delegate: _HeaderDelegate(child: header),
        ),
        ...slivers,
      ],
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => kToolbarHeight;

  @override
  double get maxExtent => kToolbarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
