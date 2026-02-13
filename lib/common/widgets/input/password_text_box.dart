import 'package:flutter/material.dart';

import 'text_box.dart';

/// A form-integrated password text field with visibility toggle.
///
/// This widget extends [TextBox] with password-specific functionality,
/// including obscured text by default and a toggle button to show/hide
/// the password. The toggle button includes appropriate tooltips and icons.
///
/// Example:
/// ```dart
/// PasswordTextBox(
///   labelText: 'Password',
///   hintText: 'Enter your password',
///   validator: (value) {
///     if (value == null || value.length < 8) {
///       return 'Password must be at least 8 characters';
///     }
///     return null;
///   },
///   onChanged: (value) => handlePasswordChange(value),
/// )
/// ```
///
/// See also:
///  * [TextBox], the base text field widget
///  * [AppTextField], for simpler text input without form integration
class PasswordTextBox extends StatefulWidget {
  const PasswordTextBox({
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
    this.textInputAction,
    this.maxLength,
  });

  /// Controller for managing the text field's content.
  final TextEditingController? controller;

  /// Initial value for uncontrolled text field.
  final String? initialValue;

  /// Label displayed above the password field.
  final String? labelText;

  /// Hint text displayed when the field is empty.
  final String? hintText;

  /// Helper text displayed below the field to provide guidance.
  final String? helperText;

  /// Error text displayed below the field when validation fails.
  final String? errorText;

  /// Called when the password field value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field (e.g., pressing Enter).
  final ValueChanged<String>? onSubmitted;

  /// Validator function for form validation.
  ///
  /// Returns an error message string if validation fails, or null if valid.
  final FormFieldValidator<String>? validator;

  /// Whether the password field is enabled for interaction. Defaults to true.
  final bool enabled;

  /// The action button to show on the keyboard (e.g., done, next).
  final TextInputAction? textInputAction;

  /// Maximum number of characters allowed.
  final int? maxLength;

  @override
  State<PasswordTextBox> createState() => _PasswordTextBoxState();
}

class _PasswordTextBoxState extends State<PasswordTextBox> {
  static const String _showPasswordTooltip = 'Show password';
  static const String _hidePasswordTooltip = 'Hide password';

  late final ValueNotifier<bool> _obscureTextNotifier;

  @override
  void initState() {
    super.initState();
    _obscureTextNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _obscureTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscureTextNotifier,
      builder: (context, obscureText, child) {
        return TextBox(
          controller: widget.controller,
          initialValue: widget.initialValue,
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          errorText: widget.errorText,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          validator: widget.validator,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          maxLength: widget.maxLength,
          obscureText: obscureText,
          suffixIcon: IconButton(
            tooltip: _resolveTooltip(obscureText),
            onPressed: () {
              _obscureTextNotifier.value = !obscureText;
            },
            icon: Icon(_resolveIconData(obscureText)),
          ),
        );
      },
    );
  }

  String _resolveTooltip(bool obscureText) {
    if (obscureText) {
      return _showPasswordTooltip;
    }
    return _hidePasswordTooltip;
  }

  IconData _resolveIconData(bool obscureText) {
    if (obscureText) {
      return Icons.visibility_outlined;
    }
    return Icons.visibility_off_outlined;
  }
}
