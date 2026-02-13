import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// A form-integrated text input field with validation support.
///
/// This widget wraps [TextFormField] and provides consistent styling,
/// validation, and error handling. It is designed for use in forms
/// where validation and submission are required.
///
/// Supports both controlled (with [controller]) and uncontrolled
/// (with [initialValue]) usage patterns. You cannot provide both.
///
/// Example:
/// ```dart
/// TextBox(
///   labelText: 'Username',
///   hintText: 'Enter your username',
///   validator: (value) {
///     if (value?.isEmpty ?? true) return 'Required';
///     return null;
///   },
///   onChanged: (value) => handleUsernameChange(value),
/// )
/// ```
///
/// See also:
///  * [AppTextField], for a simpler text field without form integration
///  * [PasswordTextBox], for password input with visibility toggle
class TextBox extends StatelessWidget {
  const TextBox({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.obscureText = false,
  }) : assert(
         controller == null || initialValue == null,
         'Provide either controller or initialValue, not both.',
       );

  /// Controller for managing the text field's content.
  ///
  /// Cannot be used with [initialValue].
  final TextEditingController? controller;

  /// Initial value for uncontrolled text field.
  ///
  /// Cannot be used with [controller].
  final String? initialValue;

  /// Label displayed above the text field.
  final String? labelText;

  /// Hint text displayed when the field is empty.
  final String? hintText;

  /// Helper text displayed below the field to provide guidance.
  final String? helperText;

  /// Error text displayed below the field when validation fails.
  final String? errorText;

  /// Called when the text field value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field (e.g., pressing Enter).
  final ValueChanged<String>? onSubmitted;

  /// Validator function for form validation.
  ///
  /// Returns an error message string if validation fails, or null if valid.
  final FormFieldValidator<String>? validator;

  /// Whether the text field is enabled for interaction. Defaults to true.
  final bool enabled;

  /// Whether the field is read-only. Defaults to false.
  final bool readOnly;

  /// The type of keyboard to display (e.g., email, phone, number).
  final TextInputType? keyboardType;

  /// The action button to show on the keyboard (e.g., done, next, search).
  final TextInputAction? textInputAction;

  /// Maximum number of lines the text field can expand to. Defaults to 1.
  final int maxLines;

  /// Minimum number of lines the text field should occupy.
  final int? minLines;

  /// Maximum number of characters allowed.
  final int? maxLength;

  /// Widget to display before the input text (e.g., an icon).
  final Widget? prefixIcon;

  /// Widget to display after the input text (e.g., a clear button).
  final Widget? suffixIcon;

  /// Called when the user taps on the field.
  final VoidCallback? onTap;

  /// Whether to obscure the text (e.g., for passwords). Defaults to false.
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: labelText,
      hint: hintText,
      enabled: enabled,
      readOnly: readOnly,
      obscured: obscureText,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        validator: validator,
        enabled: enabled,
        readOnly: readOnly,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        onTap: onTap,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
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
