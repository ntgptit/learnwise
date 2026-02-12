import 'package:flutter/material.dart';

import 'app_text_field.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    required this.hint, super.key,
    this.controller,
    this.onChanged,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      onChanged: onChanged,
      hint: hint,
      prefixIcon: const Icon(Icons.search),
      textInputAction: TextInputAction.search,
    );
  }
}
