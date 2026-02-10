import 'package:flutter/material.dart';

import 'app_text_field.dart';

class NumberInput extends StatelessWidget {
  const NumberInput({
    super.key,
    this.controller,
    this.label,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      textInputType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.done,
    );
  }
}
