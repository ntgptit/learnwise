import 'package:flutter/material.dart';

import 'colors.dart';

// Material 3 surface ladder for light theme.
const Color _lightSurface = Color(0xFFFFF7FA);
const Color _lightSurfaceContainerLowest = Color(0xFFFFFCFD);
const Color _lightSurfaceContainerLow = Color(0xFFFAF1F6);
const Color _lightSurfaceContainer = Color(0xFFF4E9F0);
const Color _lightSurfaceContainerHigh = Color(0xFFEEDFE8);
const Color _lightSurfaceContainerHighest = Color(0xFFE7D4DF);

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
const Color _darkPrimary = Color(0xFF8F2F5B);
const Color _darkOnPrimary = Color(0xFFFFFFFF);
const Color _darkPrimaryContainer = Color(0xFFB85682);
const Color _darkOnPrimaryContainer = Color(0xFFFFE6F0);
const Color _darkSecondary = Color(0xFFD37FA3);
const Color _darkTertiary = Color(0xFFE7A1BA);

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
