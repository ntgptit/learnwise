import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// A button that combines an icon with a text label for clear action context.
///
/// This button displays both an icon and text label, making the action
/// immediately recognizable. It can be styled as either a primary or
/// secondary action using the [isPrimary] flag.
///
/// The button is automatically labeled for screen readers using the [label].
/// The icon provides visual reinforcement of the action.
///
/// Example:
/// ```dart
/// LwActionButton(
///   icon: Icons.add,
///   label: 'Add Item',
///   onPressed: () => addItem(),
///   isPrimary: true,
/// )
/// ```
///
/// See also:
///  * [LwPrimaryButton], for primary actions without icons
///  * [LwSecondaryButton], for secondary actions without icons
///  * [LwIconButton], for icon-only buttons
class LwActionButton extends StatelessWidget {
  /// Creates an action button with both icon and text.
  ///
  /// Both [icon] and [label] are required. The [isPrimary] flag determines
  /// the button style (filled for primary, outlined for secondary).
  const LwActionButton({
    required this.label,
    required this.icon,
    super.key,
    this.onPressed,
    this.isPrimary = false,
  });

  /// The text label shown on the button.
  ///
  /// This is also used as the semantic label for screen readers.
  final String label;

  /// The icon displayed before the label.
  ///
  /// Provides visual context for the button's action.
  final IconData icon;

  /// Called when the button is tapped.
  ///
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Whether to style as a primary action button.
  ///
  /// When true, uses [FilledButton] style. When false, uses [OutlinedButton].
  /// Defaults to false.
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: AppSizes.spacingXs),
        Text(label),
      ],
    );

    final Widget button = isPrimary
        ? FilledButton(onPressed: onPressed, child: child)
        : OutlinedButton(onPressed: onPressed, child: child);

    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }
}
