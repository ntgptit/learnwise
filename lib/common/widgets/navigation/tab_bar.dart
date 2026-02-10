import 'package:flutter/material.dart';

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({super.key, required this.tabs, this.isScrollable = false})
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
