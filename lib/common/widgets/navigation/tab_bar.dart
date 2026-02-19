import 'package:flutter/material.dart';

class LwTabBar extends StatelessWidget implements PreferredSizeWidget {
  const LwTabBar({required this.tabs, super.key, this.isScrollable = false})
    : assert(tabs.length > 0, 'tabs must not be empty.');

  final List<Tab> tabs;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    return TabBar(tabs: tabs, isScrollable: isScrollable);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
