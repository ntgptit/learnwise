// quality-guard: allow-long-function - phase3 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

/// Typography builder aligned with Material 3 type scale.
///
/// Must follow:
/// - Start from `Typography.material2021`.
/// - Prefer semantic adjustments (family/weight/letterSpacing/height).
/// - Keep dynamic text scaling compatible with Flutter text pipeline.
///
/// Forbidden:
/// - Overriding `fontSize` globally without a strict design-system reason.
/// - Per-feature typography scale forks outside this module.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme({
    required ColorScheme colorScheme,
    String? fontFamily,
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
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontFamily: fontFamily, height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: fontFamily,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(fontFamily: fontFamily),
    );
  }
}
