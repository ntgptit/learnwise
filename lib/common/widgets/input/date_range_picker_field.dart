import 'package:flutter/material.dart';

import 'picker_date_time_format.dart';
import 'picker_field.dart';

class LwDateRangePickerField extends StatelessWidget {
  const LwDateRangePickerField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.selectedRange,
    this.onTap,
    this.enabled = true,
    this.formatDate,
  });

  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final DateTimeRange? selectedRange;
  final VoidCallback? onTap;
  final bool enabled;
  final String Function(DateTime value)? formatDate;

  @override
  Widget build(BuildContext context) {
    final String? valueText = _resolveRangeText();
    return LwPickerField(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      valueText: valueText,
      onTap: onTap,
      enabled: enabled,
      leadingIcon: Icons.date_range_outlined,
      trailingIcon: Icons.calendar_month_outlined,
    );
  }

  String? _resolveRangeText() {
    if (selectedRange == null) {
      return null;
    }

    final String Function(DateTime value) formatter =
        formatDate ?? LwPickerDateTimeFormat.date;
    final String startText = formatter(selectedRange!.start);
    final String endText = formatter(selectedRange!.end);
    return '$startText${LwPickerDateTimeFormat.rangeSeparator}$endText';
  }
}
