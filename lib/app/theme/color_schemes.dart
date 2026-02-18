import 'package:flutter/material.dart';

import 'colors.dart';

// Material 3 surface ladder for light theme.
const Color _lightSurface = Color(0xFFFFF8F3);
const Color _lightSurfaceContainerLowest = Color(0xFFFFFCF8);
const Color _lightSurfaceContainerLow = Color(0xFFFFF1E8);
const Color _lightSurfaceContainer = Color(0xFFFCE6D9);
const Color _lightSurfaceContainerHigh = Color(0xFFF8DCCB);
const Color _lightSurfaceContainerHighest = Color(0xFFF2CEB6);

// Material 3 surface ladder for dark theme.
const Color _darkSurface = Color(0xFF121212);
const Color _darkOnSurface = Color(0xFFF5F5F5);
const Color _darkSurfaceContainerLowest = Color(0xFF0E0E0E);
const Color _darkSurfaceContainerLow = Color(0xFF171717);
const Color _darkSurfaceContainer = Color(0xFF1E1E1E);
const Color _darkSurfaceContainerHigh = Color(0xFF262626);
const Color _darkSurfaceContainerHighest = Color(0xFF2E2E2E);
const Color _darkOnSurfaceVariant = Color(0xFFD1D1D1);
const Color _darkOutline = Color(0xFF8A8A8A);
const Color _darkPrimary = Color(0xFFFF6B6B);
const Color _darkOnPrimary = Color(0xFF000000);
const Color _darkPrimaryContainer = Color(0xFF8C3C1E);
const Color _darkOnPrimaryContainer = Color(0xFFFFDAD1);
const Color _darkSecondary = Color(0xFFF7B267);
const Color _darkTertiary = Color(0xFFFFD166);

/// Builds Material 3 light color scheme.
///
/// Must follow:
/// - Generate via `ColorScheme.fromSeed`.
/// - Keep overrides limited to documented surface ladder customizations.
ColorScheme buildLightColorScheme() {
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

/// Builds Material 3 dark color scheme.
///
/// Must follow:
/// - Generate via `ColorScheme.fromSeed`.
/// - Keep overrides limited to documented dark surface/outline adjustments.
ColorScheme buildDarkColorScheme() {
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
