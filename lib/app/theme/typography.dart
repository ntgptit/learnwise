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
    final TextTheme base = _baseTextTheme(colorScheme);
    return _applySemanticOverrides(base: base, fontFamily: fontFamily);
  }

  static TextTheme _baseTextTheme(ColorScheme colorScheme) {
    final Typography typography = Typography.material2021(
      colorScheme: colorScheme,
    );
    if (colorScheme.brightness == Brightness.dark) {
      return typography.white;
    }
    return typography.black;
  }

  static TextTheme _applySemanticOverrides({
    required TextTheme base,
    required String? fontFamily,
  }) {
    final TextTheme headlineTheme = _applyHeadlineStyles(
      base: base,
      fontFamily: fontFamily,
    );
    return _applyBodyAndLabelStyles(
      base: headlineTheme,
      fontFamily: fontFamily,
    );
  }

  static TextTheme _applyHeadlineStyles({
    required TextTheme base,
    required String? fontFamily,
  }) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static TextTheme _applyBodyAndLabelStyles({
    required TextTheme base,
    required String? fontFamily,
  }) {
    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(fontFamily: fontFamily, height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: fontFamily,
        height: 1.4,
      ),
      bodySmall: base.bodySmall?.copyWith(fontFamily: fontFamily, height: 1.4),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(fontFamily: fontFamily),
    );
  }
}
