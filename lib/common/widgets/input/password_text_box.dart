import 'package:flutter/material.dart';

import 'text_box.dart';

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

  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final TextInputAction? textInputAction;
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
      builder: (BuildContext context, bool obscureText, Widget? child) {
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
