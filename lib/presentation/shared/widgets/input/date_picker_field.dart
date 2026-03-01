import 'package:flutter/material.dart';

import 'picker_date_time_format.dart';
import 'picker_field.dart';

class LwDatePickerField extends StatelessWidget {
  const LwDatePickerField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.selectedDate,
    this.onTap,
    this.enabled = true,
    this.formatDate,
  });

  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final DateTime? selectedDate;
  final VoidCallback? onTap;
  final bool enabled;
  final String Function(DateTime value)? formatDate;

  @override
  Widget build(BuildContext context) {
    String? valueText;
    if (selectedDate != null) {
      final String Function(DateTime value) formatter =
          formatDate ?? LwPickerDateTimeFormat.date;
      valueText = formatter(selectedDate!);
    }

    return LwPickerField(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      valueText: valueText,
      onTap: onTap,
      enabled: enabled,
      leadingIcon: Icons.event_outlined,
      trailingIcon: Icons.calendar_today_outlined,
    );
  }
}
