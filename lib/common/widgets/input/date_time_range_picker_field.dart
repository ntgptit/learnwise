import 'package:flutter/material.dart';

import 'picker_date_time_format.dart';
import 'picker_field.dart';

class DateTimeRangePickerField extends StatelessWidget {
  const DateTimeRangePickerField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.selectedRange,
    this.onTap,
    this.enabled = true,
    this.formatDateTime,
  });

  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final DateTimeRange? selectedRange;
  final VoidCallback? onTap;
  final bool enabled;
  final String Function(DateTime value)? formatDateTime;

  @override
  Widget build(BuildContext context) {
    final String? valueText = _resolveRangeText();
    return PickerField(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      valueText: valueText,
      onTap: onTap,
      enabled: enabled,
      leadingIcon: Icons.event_repeat_outlined,
      trailingIcon: Icons.schedule_outlined,
    );
  }

  String? _resolveRangeText() {
    if (selectedRange == null) {
      return null;
    }

    final String Function(DateTime value) formatter =
        formatDateTime ?? PickerDateTimeFormat.dateTime;
    final String startText = formatter(selectedRange!.start);
    final String endText = formatter(selectedRange!.end);
    return '$startText${PickerDateTimeFormat.rangeSeparator}$endText';
  }
}
