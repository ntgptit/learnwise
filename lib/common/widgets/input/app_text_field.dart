import 'package:flutter/material.dart';

import '../../styles/app_opacities.dart';
import '../../styles/app_sizes.dart';
import 'input_field_variant.dart';

/// A customizable text input field following Material Design 3.
///
/// This widget wraps [TextField] with consistent styling and behavior.
/// It supports labels, hints, prefix/suffix icons, and various text input types.
///
/// For forms with validation, consider using [TextBox] which includes
/// [FormField] integration.
///
/// Example:
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   textInputType: TextInputType.emailAddress,
///   onChanged: (value) => handleEmailChange(value),
/// )
/// ```
///
/// See also:
///  * [TextBox], for form field integration with validation
///  * [PasswordTextBox], for password input with visibility toggle
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.textInputType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.variant = InputFieldVariant.outlined,
    this.fillColor,
    this.enabled = true,
    this.obscureText = false,
  });

  /// Controller for managing the text field's content.
  final TextEditingController? controller;

  /// Focus node for requesting and tracking focus state.
  final FocusNode? focusNode;

  /// Label displayed above the text field.
  final String? label;

  /// Hint text displayed when the field is empty.
  final String? hint;

  /// Called when the text field value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text field (e.g., pressing Enter).
  final ValueChanged<String>? onSubmitted;

  /// Maximum number of lines the text field can expand to. Defaults to 1.
  final int maxLines;

  /// Minimum number of lines the text field should occupy.
  final int? minLines;

  /// The type of keyboard to display (e.g., email, phone, number).
  final TextInputType? textInputType;

  /// The action button to show on the keyboard (e.g., done, next, search).
  final TextInputAction? textInputAction;

  /// Widget to display before the input text (e.g., an icon).
  final Widget? prefixIcon;

  /// Widget to display after the input text (e.g., a clear button).
  final Widget? suffixIcon;

  /// Visual variant of the text input.
  ///
  /// Defaults to [InputFieldVariant.outlined] for backward compatibility.
  final InputFieldVariant variant;

  /// Optional custom fill color for [InputFieldVariant.filled].
  ///
  /// If null, uses [ColorScheme.surfaceContainerLow].
  final Color? fillColor;

  /// Whether the text field is enabled for interaction. Defaults to true.
  final bool enabled;

  /// Whether to obscure the text (e.g., for passwords). Defaults to false.
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final InputDecoration decoration = _buildDecoration(context);

    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      enabled: enabled,
      obscured: obscureText,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        maxLines: maxLines,
        minLines: minLines,
        keyboardType: textInputType,
        textInputAction: textInputAction,
        enabled: enabled,
        obscureText: obscureText,
        decoration: decoration,
      ),
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return switch (variant) {
      InputFieldVariant.filled => _buildFilledDecoration(colorScheme),
      InputFieldVariant.underline => _buildUnderlineDecoration(colorScheme),
      InputFieldVariant.outlined => _buildOutlinedDecoration(colorScheme),
    };
  }

  InputDecoration _buildBaseDecoration() {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  InputDecoration _buildOutlinedDecoration(ColorScheme colorScheme) {
    final OutlineInputBorder outlinedBorder = _buildOutlinedBorder(
      borderSide: BorderSide(color: colorScheme.outline, width: AppSizes.size1),
    );
    final OutlineInputBorder focusedBorder = _buildOutlinedBorder(
      borderSide: BorderSide(color: colorScheme.primary, width: AppSizes.size2),
    );
    final OutlineInputBorder disabledBorder = _buildOutlinedBorder(
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: AppOpacities.muted55),
        width: AppSizes.size1,
      ),
    );
    return _buildBaseDecoration().copyWith(
      border: outlinedBorder,
      enabledBorder: outlinedBorder,
      focusedBorder: focusedBorder,
      disabledBorder: disabledBorder,
    );
  }

  InputDecoration _buildFilledDecoration(ColorScheme colorScheme) {
    final OutlineInputBorder filledBorder = _buildOutlinedBorder(
      borderSide: BorderSide.none,
    );
    return _buildBaseDecoration().copyWith(
      filled: true,
      fillColor: fillColor ?? colorScheme.surfaceContainerLow,
      border: filledBorder.copyWith(borderSide: BorderSide.none),
      enabledBorder: filledBorder.copyWith(borderSide: BorderSide.none),
      focusedBorder: filledBorder.copyWith(
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: AppSizes.size1,
        ),
      ),
    );
  }

  InputDecoration _buildUnderlineDecoration(ColorScheme colorScheme) {
    final UnderlineInputBorder underlineBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: colorScheme.outline, width: AppSizes.size1),
    );
    final UnderlineInputBorder focusedBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: colorScheme.primary, width: AppSizes.size2),
    );
    final UnderlineInputBorder disabledBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: AppOpacities.muted55),
        width: AppSizes.size1,
      ),
    );
    return _buildBaseDecoration().copyWith(
      border: underlineBorder,
      enabledBorder: underlineBorder,
      focusedBorder: focusedBorder,
      disabledBorder: disabledBorder,
    );
  }

  OutlineInputBorder _buildOutlinedBorder({required BorderSide borderSide}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: borderSide,
    );
  }
}
