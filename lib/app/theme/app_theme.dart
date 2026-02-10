import 'package:flutter/material.dart';

import '../../common/styles/app_sizes.dart';
import 'color_schemes.dart';
import 'typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final ColorScheme colorScheme = lightColorScheme;
    final TextTheme textTheme =
        AppTypography.textTheme(colorScheme: colorScheme).apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: AppSizes.spacingLg,
        ),
        toolbarHeight: AppSizes.size72,
      ),
      iconTheme: IconThemeData(
        size: AppSizes.spacingLg,
        color: colorScheme.onSurface,
      ),
    );
  }

  static ThemeData dark() {
    final ColorScheme colorScheme = darkColorScheme;
    final TextTheme textTheme =
        AppTypography.textTheme(colorScheme: colorScheme).apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: AppSizes.spacingLg,
        ),
        toolbarHeight: AppSizes.size72,
      ),
      iconTheme: IconThemeData(
        size: AppSizes.spacingLg,
        color: colorScheme.onSurface,
      ),
    );
  }
}
