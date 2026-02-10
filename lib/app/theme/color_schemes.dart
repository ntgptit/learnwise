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

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.dark,
);
