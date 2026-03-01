import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// A circular icon button with customizable size and colors.
///
/// This button displays an icon within a circular filled button shape.
/// It's useful for floating actions, avatar buttons, or any design
/// requiring circular icon buttons.
///
/// The button defaults to 48dp size to meet Material Design touch target
/// requirements but can be customized via the [size] parameter.
///
/// Since this is an icon-only button, it's crucial to provide semantic
/// context through tooltips or surrounding UI for accessibility.
///
/// Example:
/// ```dart
/// LwCircleButton(
///   icon: Icons.play_arrow,
///   onPressed: () => startPlayback(),
///   backgroundColor: Colors.green,
///   size: 56.0,
/// )
/// ```
///
/// See also:
///  * [LwIconButton], for standard icon buttons
///  * [LwPrimaryButton], for primary actions with text
///  * [LwActionButton], for buttons with both icon and text
class LwCircleButton extends StatelessWidget {
  /// Creates a circular icon button.
  ///
  /// The [icon] is required. The [size] defaults to 48dp to meet
  /// accessibility touch target requirements.
  const LwCircleButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size = AppSizes.size48,
  });

  /// The icon to display in the button.
  final IconData icon;

  /// Called when the button is tapped.
  ///
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// The background color of the button.
  ///
  /// Defaults to the theme's primary color if not specified.
  final Color? backgroundColor;

  /// The color of the icon.
  ///
  /// Defaults to the theme's onPrimary color if not specified.
  final Color? foregroundColor;

  /// The diameter of the circular button.
  ///
  /// Defaults to 48dp to meet Material Design touch target requirements.
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Circle button',
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        width: size,
        height: size,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            backgroundColor: backgroundColor ?? colorScheme.primary,
            foregroundColor: foregroundColor ?? colorScheme.onPrimary,
          ),
          child: Icon(icon),
        ),
      ),
    );
  }
}
