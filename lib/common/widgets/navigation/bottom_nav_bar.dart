// quality-guard: allow-long-function - navigation theming resolution is intentionally centralized in one build method.
import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// Represents a single destination in the bottom navigation bar.
///
/// Each destination has an [icon] and [label] for display, and an optional
/// [selectedIcon] to show when the destination is active.
class LwBottomNavDestination {
  const LwBottomNavDestination({
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
/// LwBottomNavBar(
///   destinations: [
///     LwBottomNavDestination(
///       icon: Icons.home_outlined,
///       selectedIcon: Icons.home,
///       label: 'Home',
///     ),
///     LwBottomNavDestination(
///       icon: Icons.search_outlined,
///       selectedIcon: Icons.search,
///       label: 'Search',
///     ),
///     LwBottomNavDestination(
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
///  * [LwBottomNavDestination], the destination data class
///  * [LwBreadcrumbs], for hierarchical navigation
class LwBottomNavBar extends StatelessWidget {
  const LwBottomNavBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  }) : assert(destinations.length > 0, 'destinations must not be empty.');

  /// The list of navigation destinations to display.
  ///
  /// Must not be empty.
  final List<LwBottomNavDestination> destinations;

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

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final NavigationBarThemeData navigationBarTheme = NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      indicatorColor: colorScheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
      elevation: AppSizes.size2,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.primary);
        }
        return IconThemeData(color: colorScheme.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          );
        }
        return Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant);
      }),
    );

    return NavigationBarTheme(
      data: navigationBarTheme,
      child: NavigationBar(
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
      ),
    );
  }
}
