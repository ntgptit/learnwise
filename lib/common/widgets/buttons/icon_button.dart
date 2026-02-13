import 'package:flutter/material.dart';

/// An icon-only button wrapper with proper accessibility support.
///
/// This button wraps Flutter's [IconButton] and ensures proper semantic
/// labeling for screen readers. It's designed for icon-only actions where
/// space is limited or icons provide clear visual affordance.
///
/// The button uses [tooltip] or a default label for accessibility.
/// Always provide a [tooltip] to describe the button's action for users
/// who rely on screen readers.
///
/// Example:
/// ```dart
/// AppIconButton(
///   icon: Icons.delete,
///   tooltip: 'Delete item',
///   onPressed: () => handleDelete(),
/// )
/// ```
///
/// See also:
///  * [PrimaryButton], for primary actions with text labels
///  * [CircleButton], for circular icon buttons
///  * [ActionButton], for buttons with both icon and text
class AppIconButton extends StatelessWidget {
  /// Creates an icon-only button.
  ///
  /// The [icon] is required and specifies which icon to display.
  /// The [tooltip] should describe the button's action and is used
  /// for accessibility.
  const AppIconButton({
    required this.icon, super.key,
    this.onPressed,
    this.tooltip,
  });

  /// The icon to display in the button.
  final IconData icon;

  /// Called when the button is tapped.
  ///
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// The tooltip shown on long press and used for accessibility.
  ///
  /// Provides context about the button's action. Should be concise
  /// and descriptive (e.g., 'Delete', 'Edit', 'Share').
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip ?? 'Icon button',
      button: true,
      enabled: onPressed != null,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon),
      ),
    );
  }
}
