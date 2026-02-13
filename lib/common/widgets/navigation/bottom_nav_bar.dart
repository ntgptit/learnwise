import 'package:flutter/material.dart';

/// Represents a single destination in the bottom navigation bar.
///
/// Each destination has an [icon] and [label] for display, and an optional
/// [selectedIcon] to show when the destination is active.
class AppBottomNavDestination {
  const AppBottomNavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  /// The icon to display when this destination is not selected.
  final IconData icon;

  /// The label text displayed below the icon.
  final String label;

  /// The icon to display when this destination is selected.
  ///
  /// If null, [icon] is used for both states.
  final IconData? selectedIcon;
}

/// A Material Design 3 bottom navigation bar for primary app navigation.
///
/// This widget wraps [NavigationBar] with type-safe destination handling.
/// It displays a horizontal bar at the bottom of the screen with icons
/// and labels for each navigation destination.
///
/// Use this for primary navigation between 3-5 top-level destinations.
/// For more than 5 destinations, consider a navigation drawer instead.
///
/// Example:
/// ```dart
/// AppBottomNavBar(
///   destinations: [
///     AppBottomNavDestination(
///       icon: Icons.home_outlined,
///       selectedIcon: Icons.home,
///       label: 'Home',
///     ),
///     AppBottomNavDestination(
///       icon: Icons.search_outlined,
///       selectedIcon: Icons.search,
///       label: 'Search',
///     ),
///     AppBottomNavDestination(
///       icon: Icons.person_outlined,
///       selectedIcon: Icons.person,
///       label: 'Profile',
///     ),
///   ],
///   selectedIndex: currentIndex,
///   onDestinationSelected: (index) => setState(() => currentIndex = index),
/// )
/// ```
///
/// See also:
///  * [AppBottomNavDestination], the destination data class
///  * [AppBreadcrumbs], for hierarchical navigation
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.destinations, required this.selectedIndex, required this.onDestinationSelected, super.key,
  }) : assert(destinations.length > 0, 'destinations must not be empty.');

  /// The list of navigation destinations to display.
  ///
  /// Must not be empty.
  final List<AppBottomNavDestination> destinations;

  /// The index of the currently selected destination.
  ///
  /// Must be a valid index within [destinations].
  final int selectedIndex;

  /// Called when the user taps a destination.
  ///
  /// The [int] parameter is the index of the tapped destination.
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
