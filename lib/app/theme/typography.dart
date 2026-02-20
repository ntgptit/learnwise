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

  static const double displayLargeFontSize = 22;
  static const double displayMediumFontSize = 20;
  static const double titleLargeFontSize = 18;
  static const double titleMediumFontSize = 16;
  static const double titleSmallFontSize = 15;
  static const double bodyLargeFontSize = 15;
  static const double bodyMediumFontSize = 14;
  static const double bodySmallFontSize = 13;
  static const double labelLargeFontSize = 13;
  static const double labelMediumFontSize = 12;
  static const double labelSmallFontSize = 11.5;

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
    final TextTheme displayTheme = _applyDisplayStyles(
      base: base,
      fontFamily: fontFamily,
    );
    return _applyTitleStyles(base: displayTheme, fontFamily: fontFamily);
  }

  static TextTheme _applyDisplayStyles({
    required TextTheme base,
    required String? fontFamily,
  }) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: displayLargeFontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: displayMediumFontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    );
  }

  static TextTheme _applyTitleStyles({
    required TextTheme base,
    required String? fontFamily,
  }) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: titleLargeFontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: titleMediumFontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: titleLargeFontSize,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: titleMediumFontSize,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: titleSmallFontSize,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static TextTheme _applyBodyAndLabelStyles({
    required TextTheme base,
    required String? fontFamily,
  }) {
    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: bodyLargeFontSize,
        height: 1.4,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: bodyMediumFontSize,
        height: 1.4,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: bodySmallFontSize,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: fontFamily,
        fontSize: labelLargeFontSize,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: fontFamily,
        fontSize: labelMediumFontSize,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: fontFamily,
        fontSize: labelSmallFontSize,
      ),
    );
  }
}
