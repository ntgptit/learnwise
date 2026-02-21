import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../navigation/bottom_nav_bar.dart';

class LwAppShell extends StatelessWidget {
  const LwAppShell({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.useSafeArea = false,
    this.resizeToAvoidBottomInset,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool useSafeArea;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final Widget content = useSafeArea ? SafeArea(child: body) : body;
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: LwBottomNavBar(
        destinations: _buildMainDestinations(context),
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }

  List<LwBottomNavDestination> _buildMainDestinations(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return <LwBottomNavDestination>[
      LwBottomNavDestination(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: l10n.dashboardNavHome,
      ),
      LwBottomNavDestination(
        icon: Icons.folder_open_outlined,
        selectedIcon: Icons.folder_rounded,
        label: l10n.dashboardNavFolders,
      ),
      LwBottomNavDestination(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: l10n.dashboardNavProfile,
      ),
    ];
  }
}
