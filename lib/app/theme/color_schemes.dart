import 'package:flutter/material.dart';

import 'colors.dart';

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
  // Surface container variants for Material 3
  // Used to create elevation hierarchy without using shadows
  surfaceContainerLowest: Color(0xFFFFFFFF), // Pure white - highest contrast
  surfaceContainerLow: Color(0xFFF2F5F6), // Very light gray - for cards on surface
  surfaceContainer: Color(0xFFECEFF0), // Light gray - for standard cards
  surfaceContainerHigh: Color(0xFFE6EAEB), // Medium gray - for dialogs, elevated cards
  surfaceContainerHighest: Color(0xFFE1E4E6), // Darker gray - for bottom sheets, top-level containers
);

final ColorScheme darkColorScheme =
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF0F1416),
      onSurface: const Color(0xFFE6ECEE),
      surfaceContainerHighest: const Color(0xFF2A3134),
      onSurfaceVariant: const Color(0xFFBEC8CC),
      outline: const Color(0xFF879296),
    );
