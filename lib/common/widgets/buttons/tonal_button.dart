import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// A tonal button for medium-emphasis actions following Material Design 3 guidelines.
///
/// Tonal buttons are used for important actions that don't need as much visual weight
/// as [PrimaryButton]. They use [FilledButton.tonal] which fills with secondary
/// color and has less contrast than a filled button.
///
/// Use this button for actions that are important but not the primary action on the screen.
/// For example, "Save Draft" alongside a "Publish" primary button, or "Cancel" alongside
/// a "Confirm" primary button.
///
/// This button supports loading states, leading icons, and proper accessibility.
/// It enforces the minimum 48dp touch target as per Material Design standards.
///
/// The button is automatically labeled for screen readers using the [label].
/// The enabled/disabled state is properly announced based on [onPressed] and
/// [isLoading] values.
///
/// Example:
/// ```dart
/// TonalButton(
///   label: 'Save Draft',
///   onPressed: () => handleSaveDraft(),
///   isLoading: _isSaving,
///   leading: Icon(Icons.save),
/// )
/// ```
///
/// Button Hierarchy:
/// - Primary: [PrimaryButton] (FilledButton) - Highest emphasis
/// - Tonal: [TonalButton] (FilledButton.tonal) - Medium-high emphasis
/// - Secondary: [SecondaryButton] (OutlinedButton) - Medium emphasis
/// - Tertiary: [AppTextButton] (TextButton) - Low emphasis
///
/// See also:
///  * [PrimaryButton], for primary actions with highest emphasis
///  * [SecondaryButton], for secondary actions with outlined style
///  * [AppTextButton], for tertiary actions with minimal style
///  * [ActionButton], for buttons with both icon and text
class TonalButton extends StatelessWidget {
  /// Creates a tonal button for medium-emphasis actions.
  ///
  /// The [label] is required and used as the button text and semantic label.
  /// The [onPressed] callback is called when the button is tapped.
  /// When [isLoading] is true, a loading indicator is shown and the button is disabled.
  const TonalButton({
    required this.label,
    super.key,
    this.onPressed,
    this.leading,
    this.isLoading = false,
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

  /// An optional widget displayed before the label.
  ///
  /// Typically an [Icon] widget. Hidden when [isLoading] is true.
  final Widget? leading;

  /// Whether the button is in a loading state.
  ///
  /// When true, shows a [CircularProgressIndicator] and disables the button.
  final bool isLoading;

  /// Whether the button should expand to fill available width.
  ///
  /// Defaults to true. When false, the button sizes to fit its content.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading)
          SizedBox(
            width: AppSizes.spacingMd,
            height: AppSizes.spacingMd,
            child: CircularProgressIndicator(
              strokeWidth: AppSizes.size2,
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        if (!isLoading && leading != null) leading!,
        if (isLoading || leading != null)
          const SizedBox(width: AppSizes.spacingXs),
        Text(label),
      ],
    );

    final Widget button = Semantics(
      label: label,
      button: true,
      enabled: !disabled,
      child: FilledButton.tonal(
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.size48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        child: content,
      ),
    );

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
