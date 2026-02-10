import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class SelectOption<T> {
  const SelectOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.leading,
  });

  final T value;
  final String label;
  final bool enabled;
  final Widget? leading;
}

class SelectBox<T> extends StatelessWidget {
  const SelectBox({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.validator,
  });

  final List<SelectOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      items: options.map((SelectOption<T> option) {
        return DropdownMenuItem<T>(
          value: option.value,
          enabled: option.enabled,
          child: Row(
            children: <Widget>[
              if (option.leading != null) ...<Widget>[
                option.leading!,
                const SizedBox(width: AppSizes.spacingXs),
              ],
              Expanded(child: Text(option.label)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
