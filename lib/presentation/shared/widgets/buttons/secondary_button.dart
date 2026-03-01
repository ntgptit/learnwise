import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// A secondary action button following Material Design 3 guidelines.
///
/// This button uses [OutlinedButton] and is intended for secondary actions
/// that are less prominent than primary actions. It enforces the minimum
/// 48dp touch target as per Material Design standards.
///
/// The button is automatically labeled for screen readers using the [label].
/// The enabled/disabled state is properly announced based on [onPressed].
///
/// Example:
/// ```dart
/// LwSecondaryButton(
///   label: 'Cancel',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
///
/// See also:
///  * [LwPrimaryButton], for primary actions
///  * [LwTextButton], for tertiary or text-only actions
///  * [LwActionButton], for buttons with both icon and text
class LwSecondaryButton extends StatelessWidget {
  /// Creates a secondary action button.
  ///
  /// The [label] is required and used as the button text and semantic label.
  /// The [onPressed] callback is called when the button is tapped.
  const LwSecondaryButton({
    required this.label,
    super.key,
    this.onPressed,
    this.expanded = true,
  });

  /// The text label shown on the button.
  ///
  /// This is also used as the semantic label for screen readers.
  final String label;

  /// Called when the button is tapped.
  ///
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Whether the button should expand to fill available width.
  ///
  /// Defaults to true. When false, the button sizes to fit its content.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.size48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        child: Text(label),
      ),
    );

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
