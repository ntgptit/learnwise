import 'package:flutter/material.dart';

class PickerDateTimeFormat {
  const PickerDateTimeFormat._();

  static const String dateSeparator = '-';
  static const String timeSeparator = ':';
  static const String dateTimeSeparator = ' ';
  static const String rangeSeparator = ' - ';
  static const String leadingZeroPadding = '0';
  static const int twoDigitWidth = 2;

  static String date(DateTime value) {
    final String year = value.year.toString();
    final String month = _twoDigits(value.month);
    final String day = _twoDigits(value.day);
    return '$year$dateSeparator$month$dateSeparator$day';
  }

  static String time(DateTime value) {
    final String hour = _twoDigits(value.hour);
    final String minute = _twoDigits(value.minute);
    return '$hour$timeSeparator$minute';
  }

  static String dateTime(DateTime value) {
    final String dateText = date(value);
    final String timeText = time(value);
    return '$dateText$dateTimeSeparator$timeText';
  }

  static String dateRange(DateTimeRange value) {
    final String startText = date(value.start);
    final String endText = date(value.end);
    return '$startText$rangeSeparator$endText';
  }

  static String dateTimeRange(DateTimeRange value) {
    final String startText = dateTime(value.start);
    final String endText = dateTime(value.end);
    return '$startText$rangeSeparator$endText';
  }

  static String _twoDigits(int value) {
    return value.toString().padLeft(twoDigitWidth, leadingZeroPadding);
  }
}
