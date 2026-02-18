// quality-guard: allow-large-class - phase2 legacy backlog tracked for class decomposition.
// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import '../../../core/utils/string_utils.dart';
import 'input_field_variant.dart';

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
    this.helperIcon,
    this.errorText,
    this.errorIcon,
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
    this.variant = InputFieldVariant.outlined,
    this.fillColor,
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

  /// Optional helper icon shown before [helperText].
  final Widget? helperIcon;

  /// Error text displayed below the field when validation fails.
  final String? errorText;

  /// Optional error icon shown in the trailing area when [errorText] is set.
  ///
  /// Defaults to an error-outline icon with semantic error color.
  final Widget? errorIcon;

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

  /// Visual variant of the text input.
  ///
  /// Defaults to [InputFieldVariant.outlined] for backward compatibility.
  final InputFieldVariant variant;

  /// Optional custom fill color for [InputFieldVariant.filled].
  ///
  /// If null, uses [ColorScheme.surfaceContainerLow].
  final Color? fillColor;

  /// Called when the user taps on the field.
  final VoidCallback? onTap;

  /// Whether to obscure the text (e.g., for passwords). Defaults to false.
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final InputDecoration decoration = _buildDecoration(context);

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
        decoration: decoration,
      ),
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool hasErrorText = _hasText(errorText);
    final Widget? trailing = _buildTrailing(
      context,
      hasErrorText: hasErrorText,
    );
    final Widget? helper = _buildHelper(context);
    final OutlineInputBorder outlinedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    );
    const UnderlineInputBorder underlineBorder = UnderlineInputBorder();
    final TextStyle? errorStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.error,
      fontWeight: FontWeight.w600,
    );

    if (variant == InputFieldVariant.filled) {
      return InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helper: helper,
        helperText: helper == null ? helperText : null,
        errorText: errorText,
        errorStyle: errorStyle,
        prefixIcon: prefixIcon,
        suffixIcon: trailing,
        suffixIconConstraints: const BoxConstraints(
          minWidth: AppSizes.size48,
          minHeight: AppSizes.size48,
        ),
        filled: true,
        fillColor: fillColor ?? colorScheme.surfaceContainerLow,
        border: outlinedBorder.copyWith(borderSide: BorderSide.none),
        enabledBorder: outlinedBorder.copyWith(borderSide: BorderSide.none),
        focusedBorder: outlinedBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: AppSizes.size1,
          ),
        ),
        errorBorder: outlinedBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppSizes.size1,
          ),
        ),
        focusedErrorBorder: outlinedBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppSizes.size2,
          ),
        ),
      );
    }

    if (variant == InputFieldVariant.underline) {
      return InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helper: helper,
        helperText: helper == null ? helperText : null,
        errorText: errorText,
        errorStyle: errorStyle,
        prefixIcon: prefixIcon,
        suffixIcon: trailing,
        suffixIconConstraints: const BoxConstraints(
          minWidth: AppSizes.size48,
          minHeight: AppSizes.size48,
        ),
        border: underlineBorder,
        enabledBorder: underlineBorder,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: AppSizes.size2,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppSizes.size1,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppSizes.size2,
          ),
        ),
      );
    }

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helper: helper,
      helperText: helper == null ? helperText : null,
      errorText: errorText,
      errorStyle: errorStyle,
      prefixIcon: prefixIcon,
      suffixIcon: trailing,
      suffixIconConstraints: const BoxConstraints(
        minWidth: AppSizes.size48,
        minHeight: AppSizes.size48,
      ),
      border: outlinedBorder,
      enabledBorder: outlinedBorder,
      focusedBorder: outlinedBorder.copyWith(
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: AppSizes.size2,
        ),
      ),
      errorBorder: outlinedBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: AppSizes.size1),
      ),
      focusedErrorBorder: outlinedBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: AppSizes.size2),
      ),
    );
  }

  Widget? _buildHelper(BuildContext context) {
    if (!_hasText(helperText)) {
      return null;
    }
    if (helperIcon == null) {
      return null;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle? textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconTheme(
          data: IconThemeData(
            size: AppSizes.size18,
            color: colorScheme.onSurfaceVariant,
          ),
          child: helperIcon!,
        ),
        const SizedBox(width: AppSizes.spacing2Xs),
        Text(helperText!, style: textStyle),
      ],
    );
  }

  Widget? _buildTrailing(BuildContext context, {required bool hasErrorText}) {
    final Widget? resolvedErrorIcon = _resolveErrorIcon(context, hasErrorText);
    if (suffixIcon == null) {
      return resolvedErrorIcon;
    }
    if (resolvedErrorIcon == null) {
      return suffixIcon;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[suffixIcon!, resolvedErrorIcon],
    );
  }

  Widget? _resolveErrorIcon(BuildContext context, bool hasErrorText) {
    if (!hasErrorText) {
      return null;
    }
    if (errorIcon != null) {
      return errorIcon;
    }
    final Color errorColor = Theme.of(context).colorScheme.error;
    return Icon(
      Icons.error_outline_rounded,
      color: errorColor,
      size: AppSizes.size20,
    );
  }

  bool _hasText(String? value) {
    return StringUtils.isNotBlank(value);
  }
}
