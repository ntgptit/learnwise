import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

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

  /// Whether the text field is enabled for interaction. Defaults to true.
  final bool enabled;

  /// Whether to obscure the text (e.g., for passwords). Defaults to false.
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
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
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),
    );
  }
}
