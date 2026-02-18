// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../styles/app_sizes.dart';

/// A primary action button following Material Design 3 guidelines.
///
/// This button uses [FilledButton] and supports loading states, leading icons,
/// and proper accessibility. It enforces the minimum 48dp touch target
/// as per Material Design standards.
///
/// The button is automatically labeled for screen readers using the [label].
/// The enabled/disabled state is properly announced based on [onPressed] and
/// [isLoading] values.
///
/// Example:
/// ```dart
/// PrimaryButton(
///   label: 'Submit Form',
///   onPressed: () => handleSubmit(),
///   isLoading: _isSubmitting,
///   leading: Icon(Icons.check),
/// )
/// ```
///
/// See also:
///  * [SecondaryButton], for secondary actions
///  * [AppIconButton], for icon-only buttons
///  * [ActionButton], for buttons with both icon and text
class PrimaryButton extends StatelessWidget {
  /// Creates a primary action button.
  ///
  /// The [label] is required and used as the button text and semantic label.
  /// The [onPressed] callback is called when the button is tapped.
  /// When [isLoading] is true, a loading indicator is shown and the button is disabled.
  const PrimaryButton({
    required this.label,
    super.key,
    this.onPressed,
    this.leading,
    this.isLoading = false,
    this.expanded = true,
    this.enableHapticFeedback = false,
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

  /// Whether to trigger light haptic feedback when pressed.
  ///
  /// Defaults to false to preserve current behavior.
  final bool enableHapticFeedback;

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
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
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
      child: FilledButton(
        onPressed: disabled ? null : _handlePressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.size48),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
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

  void _handlePressed() {
    final VoidCallback? callback = onPressed;
    if (callback == null) {
      return;
    }
    if (enableHapticFeedback) {
      unawaited(HapticFeedback.lightImpact());
    }
    callback();
  }
}
