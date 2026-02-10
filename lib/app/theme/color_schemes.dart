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
