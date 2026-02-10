import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static const double titleSize = 20;
  static const double bodyLargeSize = 16;
  static const double bodyMediumSize = 14;
  static const double labelLargeSize = 14;
  static const double labelMediumSize = 12;

  static TextTheme textTheme({
    String? fontFamily,
    required ColorScheme colorScheme,
  }) {
    final Typography typography = Typography.material2021(
      colorScheme: colorScheme,
    );
    final TextTheme base = colorScheme.brightness == Brightness.dark
        ? typography.white
        : typography.black;
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: titleSize,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: bodyLargeSize,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: bodyLargeSize,
        height: 1.4,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: bodyMediumSize,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: labelLargeSize,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: labelMediumSize,
      ),
    );
  }
}
