import 'package:flutter/material.dart';

import 'colors.dart';

// Material 3 surface ladder for light theme.
const Color _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
const Color _lightSurfaceContainerLow = Color(0xFFF2F5F6);
const Color _lightSurfaceContainer = Color(0xFFECEFF0);
const Color _lightSurfaceContainerHigh = Color(0xFFE6EAEB);
const Color _lightSurfaceContainerHighest = Color(0xFFE1E4E6);

// Material 3 surface ladder for dark theme.
const Color _darkSurface = Color(0xFF0F1416);
const Color _darkOnSurface = Color(0xFFE6ECEE);
const Color _darkSurfaceContainerLowest = Color(0xFF0A0F11);
const Color _darkSurfaceContainerLow = Color(0xFF151C1F);
const Color _darkSurfaceContainer = Color(0xFF1A2326);
const Color _darkSurfaceContainerHigh = Color(0xFF242E31);
const Color _darkSurfaceContainerHighest = Color(0xFF2A3134);
const Color _darkOnSurfaceVariant = Color(0xFFBEC8CC);
const Color _darkOutline = Color(0xFF879296);

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  error: AppColors.error,
  onError: AppColors.onError,
  surface: AppColors.surface,
  onSurface: AppColors.onSurface,
  surfaceContainerLowest: _lightSurfaceContainerLowest,
  surfaceContainerLow: _lightSurfaceContainerLow,
  surfaceContainer: _lightSurfaceContainer,
  surfaceContainerHigh: _lightSurfaceContainerHigh,
  surfaceContainerHighest: _lightSurfaceContainerHighest,
);

final ColorScheme darkColorScheme =
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
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
