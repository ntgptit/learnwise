import 'package:flutter/material.dart';

import 'constants/color_tokens.dart';
import 'colors.dart';

/// Material 3 light color scheme entrypoint required by theme contract guard.
final ColorScheme lightColorScheme =
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColorTokens.lightSurface,
      surfaceContainerLowest: AppColorTokens.lightSurfaceContainerLowest,
      surfaceContainerLow: AppColorTokens.lightSurfaceContainerLow,
      surfaceContainer: AppColorTokens.lightSurfaceContainer,
      surfaceContainerHigh: AppColorTokens.lightSurfaceContainerHigh,
      surfaceContainerHighest: AppColorTokens.lightSurfaceContainerHighest,
    );

/// Material 3 dark color scheme entrypoint required by theme contract guard.
final ColorScheme darkColorScheme =
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColorTokens.darkPrimary,
      onPrimary: AppColorTokens.darkOnPrimary,
      primaryContainer: AppColorTokens.darkPrimaryContainer,
      onPrimaryContainer: AppColorTokens.darkOnPrimaryContainer,
      secondary: AppColorTokens.darkSecondary,
      tertiary: AppColorTokens.darkTertiary,
      surface: AppColorTokens.darkSurface,
      onSurface: AppColorTokens.darkOnSurface,
      surfaceContainerLowest: AppColorTokens.darkSurfaceContainerLowest,
      surfaceContainerLow: AppColorTokens.darkSurfaceContainerLow,
      surfaceContainer: AppColorTokens.darkSurfaceContainer,
      surfaceContainerHigh: AppColorTokens.darkSurfaceContainerHigh,
      surfaceContainerHighest: AppColorTokens.darkSurfaceContainerHighest,
      onSurfaceVariant: AppColorTokens.darkOnSurfaceVariant,
      outline: AppColorTokens.darkOutline,
    );

/// Builds Material 3 light color scheme.
ColorScheme buildLightColorScheme() {
  return lightColorScheme;
}

/// Builds Material 3 dark color scheme.
ColorScheme buildDarkColorScheme() {
  return darkColorScheme;
}

/* Legacy builders kept for reference during palette tuning.
///
/// Must follow:
/// - Generate via `ColorScheme.fromSeed`.
/// - Keep overrides limited to documented surface ladder customizations.
ColorScheme _buildLightColorSchemeLegacy() {
  return ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.tertiary,
    surface: _lightSurface,
    surfaceContainerLowest: _lightSurfaceContainerLowest,
    surfaceContainerLow: _lightSurfaceContainerLow,
    surfaceContainer: _lightSurfaceContainer,
    surfaceContainerHigh: _lightSurfaceContainerHigh,
    surfaceContainerHighest: _lightSurfaceContainerHighest,
  );
}

/// Must follow:
/// - Generate via `ColorScheme.fromSeed`.
/// - Keep overrides limited to documented dark surface/outline adjustments.
ColorScheme _buildDarkColorSchemeLegacy() {
  return ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: _darkPrimary,
    onPrimary: _darkOnPrimary,
    primaryContainer: _darkPrimaryContainer,
    onPrimaryContainer: _darkOnPrimaryContainer,
    secondary: _darkSecondary,
    tertiary: _darkTertiary,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    surfaceContainerLowest: _darkSurfaceContainerLowest,
    surfaceContainerLow: _darkSurfaceContainerLow,
    surfaceContainer: _darkSurfaceContainer,
    surfaceContainerHigh: _darkSurfaceContainerHigh,
    surfaceContainerHighest: _darkSurfaceContainerHighest,
    onSurfaceVariant: _darkOnSurfaceVariant,
    outline: _darkOutline,
  );
}
*/
