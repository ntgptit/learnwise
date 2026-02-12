import 'package:flutter/material.dart';

class AppBottomNavDestination {
  const AppBottomNavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final String label;
  final IconData? selectedIcon;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.destinations, required this.selectedIndex, required this.onDestinationSelected, super.key,
  }) : assert(destinations.length > 0, 'destinations must not be empty.');

  final List<AppBottomNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isSelectedIndexInvalid =
        selectedIndex < 0 || selectedIndex >= destinations.length;
    if (isSelectedIndexInvalid) {
      return const SizedBox.shrink();
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations
          .map(
            (destination) => NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: destination.selectedIcon == null
                  ? null
                  : Icon(destination.selectedIcon),
              label: destination.label,
            ),
          )
          .toList(),
    );
  }
}
