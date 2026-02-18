// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.valueText,
    this.onTap,
    this.enabled = true,
    this.leadingIcon,
    this.trailingIcon = Icons.calendar_today_outlined,
  });

  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? valueText;
  final VoidCallback? onTap;
  final bool enabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final bool canTap = enabled && onTap != null;
    final InputDecoration decoration = InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: leadingIcon == null ? null : Icon(leadingIcon),
      suffixIcon: trailingIcon == null ? null : Icon(trailingIcon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      enabled: enabled,
    );

    final Widget field = InputDecorator(
      isEmpty: (valueText == null) || valueText!.isEmpty,
      decoration: decoration,
      child: Text(valueText ?? ''),
    );

    if (!canTap) {
      return field;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.size48),
        child: field,
      ),
    );
  }
}
