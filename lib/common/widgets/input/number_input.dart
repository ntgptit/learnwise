import 'package:flutter/material.dart';

import 'app_text_field.dart';

class LwNumberInput extends StatelessWidget {
  const LwNumberInput({
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
    return LwTextField(
      controller: controller,
      label: label,
      textInputType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.done,
    );
  }
}
