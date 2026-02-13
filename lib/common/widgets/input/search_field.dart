import 'package:flutter/material.dart';

import 'app_text_field.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.hint,
    super.key,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      hint: hint,
      textInputAction: TextInputAction.search,
      suffixIcon: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final bool hasInput = value.text.trim().isNotEmpty;
          if (hasInput) {
            return IconButton(
              onPressed: () => _handleClear(context),
              icon: const Icon(Icons.close_rounded),
              tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
            );
          }
          return IconButton(
            onPressed: _handleSearchIconTap,
            icon: const Icon(Icons.search_rounded),
            tooltip: hint,
          );
        },
      ),
    );
  }

  void _handleSearchIconTap() {
    focusNode?.requestFocus();
  }

  void _handleClear(BuildContext context) {
    if (onClear != null) {
      onClear!();
      return;
    }
    if (controller.text.isEmpty) {
      return;
    }
    controller.clear();
    onChanged?.call('');
    onSubmitted?.call('');
    focusNode?.requestFocus();
  }
}
