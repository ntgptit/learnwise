import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF0A7E8C);
  static const Color onPrimary = Colors.white;

  static const Color secondary = Color(0xFF2F5D62);
  static const Color onSecondary = Colors.white;

  static const Color surface = Color(0xFFF7FAFB);
  static const Color onSurface = Color(0xFF1B1E1F);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Colors.white;

  @Deprecated(
    'Use Theme.of(context).colorScheme.successContainer or onSuccessContainer instead.',
  )
  static const Color success = Color(0xFF1B8F4B);

  @Deprecated(
    'Use Theme.of(context).colorScheme.warningContainer or onWarningContainer instead.',
  )
  static const Color warning = Color(0xFFECA300);

  @Deprecated(
    'Use Theme.of(context).colorScheme.infoContainer or onInfoContainer instead.',
  )
  static const Color info = Color(0xFF1976D2);
}
