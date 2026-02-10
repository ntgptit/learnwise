import 'package:flutter/material.dart';

import 'picker_date_time_format.dart';
import 'picker_field.dart';

class DateTimePickerField extends StatelessWidget {
  const DateTimePickerField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.selectedDateTime,
    this.onTap,
    this.enabled = true,
    this.formatDateTime,
  });

  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final DateTime? selectedDateTime;
  final VoidCallback? onTap;
  final bool enabled;
  final String Function(DateTime value)? formatDateTime;

  @override
  Widget build(BuildContext context) {
    String? valueText;
    if (selectedDateTime != null) {
      final String Function(DateTime value) formatter =
          formatDateTime ?? PickerDateTimeFormat.dateTime;
      valueText = formatter(selectedDateTime!);
    }

    return PickerField(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      valueText: valueText,
      onTap: onTap,
      enabled: enabled,
      leadingIcon: Icons.event_note_outlined,
      trailingIcon: Icons.schedule_outlined,
    );
  }
}
