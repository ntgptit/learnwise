import 'package:flutter/material.dart';

/// An icon-only button wrapper with proper accessibility support.
///
/// This button wraps Flutter's standard [IconButton] and ensures proper semantic
/// labeling for screen readers. It's designed for icon-only actions where
/// space is limited or icons provide clear visual affordance.
///
/// This is the standard variant with no background. For buttons with emphasis,
/// use [AppFilledIconButton], [AppFilledTonalIconButton], or [AppOutlinedIconButton].
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
/// Icon Button Hierarchy:
/// - Filled: [AppFilledIconButton] - Highest emphasis, filled background
/// - Tonal: [AppFilledTonalIconButton] - Medium emphasis, tonal background
/// - Outlined: [AppOutlinedIconButton] - Medium-low emphasis, outlined border
/// - Standard: [AppIconButton] - Low emphasis, no background
///
/// See also:
///  * [AppFilledIconButton], for high-emphasis icon buttons
///  * [AppFilledTonalIconButton], for medium-emphasis icon buttons
///  * [AppOutlinedIconButton], for medium-low emphasis icon buttons
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

/// A filled icon button with high emphasis.
///
/// This button uses [IconButton.filled] which provides a filled background
/// with the primary color. Use this for the most important icon-only actions
/// on a screen, such as a primary action in a toolbar or a key control.
///
/// The filled style provides strong visual emphasis and should be used sparingly.
/// For medium emphasis, consider [AppFilledTonalIconButton] instead.
///
/// Example:
/// ```dart
/// AppFilledIconButton(
///   icon: Icons.edit,
///   tooltip: 'Edit',
///   onPressed: () => handleEdit(),
/// )
/// ```
///
/// See also:
///  * [AppFilledTonalIconButton], for medium-emphasis icon buttons
///  * [AppOutlinedIconButton], for medium-low emphasis icon buttons
///  * [AppIconButton], for standard icon buttons with no background
class AppFilledIconButton extends StatelessWidget {
  /// Creates a filled icon button with high emphasis.
  ///
  /// The [icon] is required and specifies which icon to display.
  /// The [tooltip] should describe the button's action and is used
  /// for accessibility.
  const AppFilledIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.tooltip,
    this.size,
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

  /// The size of the icon.
  ///
  /// If null, defaults to the theme's icon size.
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip ?? 'Filled icon button',
      button: true,
      enabled: onPressed != null,
      child: IconButton.filled(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: size),
      ),
    );
  }
}

/// A filled tonal icon button with medium emphasis.
///
/// This button uses [IconButton.filledTonal] which provides a tonal filled
/// background (secondary container color). Use this for important icon-only
/// actions that don't need as much visual weight as [AppFilledIconButton].
///
/// The tonal style is ideal for actions like "Save", "Archive", or "Favorite"
/// that are important but not the primary action on the screen.
///
/// Example:
/// ```dart
/// AppFilledTonalIconButton(
///   icon: Icons.favorite,
///   tooltip: 'Add to favorites',
///   onPressed: () => handleFavorite(),
/// )
/// ```
///
/// See also:
///  * [AppFilledIconButton], for high-emphasis icon buttons
///  * [AppOutlinedIconButton], for medium-low emphasis icon buttons
///  * [AppIconButton], for standard icon buttons with no background
class AppFilledTonalIconButton extends StatelessWidget {
  /// Creates a filled tonal icon button with medium emphasis.
  ///
  /// The [icon] is required and specifies which icon to display.
  /// The [tooltip] should describe the button's action and is used
  /// for accessibility.
  const AppFilledTonalIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.tooltip,
    this.size,
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

  /// The size of the icon.
  ///
  /// If null, defaults to the theme's icon size.
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip ?? 'Tonal icon button',
      button: true,
      enabled: onPressed != null,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: size),
      ),
    );
  }
}

/// An outlined icon button with medium-low emphasis.
///
/// This button uses [IconButton.outlined] which provides an outlined border
/// without a filled background. Use this for secondary icon-only actions that
/// need more emphasis than a standard [AppIconButton] but less than filled variants.
///
/// The outlined style is ideal for actions like "Share", "Download", or "Print"
/// that are useful but not critical to the main workflow.
///
/// Example:
/// ```dart
/// AppOutlinedIconButton(
///   icon: Icons.share,
///   tooltip: 'Share',
///   onPressed: () => handleShare(),
/// )
/// ```
///
/// See also:
///  * [AppFilledIconButton], for high-emphasis icon buttons
///  * [AppFilledTonalIconButton], for medium-emphasis icon buttons
///  * [AppIconButton], for standard icon buttons with no background
class AppOutlinedIconButton extends StatelessWidget {
  /// Creates an outlined icon button with medium-low emphasis.
  ///
  /// The [icon] is required and specifies which icon to display.
  /// The [tooltip] should describe the button's action and is used
  /// for accessibility.
  const AppOutlinedIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.tooltip,
    this.size,
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

  /// The size of the icon.
  ///
  /// If null, defaults to the theme's icon size.
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip ?? 'Outlined icon button',
      button: true,
      enabled: onPressed != null,
      child: IconButton.outlined(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: size),
      ),
    );
  }
}
