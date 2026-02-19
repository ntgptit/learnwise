import 'package:flutter/material.dart';

/// A text-only button for tertiary or low-emphasis actions.
///
/// This button wraps Flutter's [TextButton] and is intended for less
/// prominent actions that don't need the visual weight of outlined or
/// filled buttons. Common uses include 'Cancel', 'Skip', or navigation links.
///
/// The button is automatically labeled for screen readers using the [label].
/// The enabled/disabled state is properly announced based on [onPressed].
///
/// Example:
/// ```dart
/// LwTextButton(
///   label: 'Skip',
///   onPressed: () => skipStep(),
/// )
/// ```
///
/// See also:
///  * [LwPrimaryButton], for primary actions
///  * [LwSecondaryButton], for secondary actions
///  * [LwActionButton], for buttons with both icon and text
class LwTextButton extends StatelessWidget {
  /// Creates a text-only button.
  ///
  /// The [label] is required and used as the button text and semantic label.
  /// The [onPressed] callback is called when the button is tapped.
  const LwTextButton({required this.label, super.key, this.onPressed});

  /// The text label shown on the button.
  ///
  /// This is also used as the semantic label for screen readers.
  final String label;

  /// Called when the button is tapped.
  ///
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      child: TextButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
