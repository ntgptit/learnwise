// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
// theme-guard: allow-no-dynamic-color - static palette is intentionally used.
import 'package:flutter/material.dart';

import '../../common/styles/app_radius.dart';
import '../../common/styles/app_sizes.dart';
import 'color_schemes.dart';
import 'typography.dart';

/// Theme module entrypoint.
///
/// Scope:
/// - Build app-wide [ThemeData] for light/dark mode.
/// - Keep Material 3 configuration centralized.
///
/// Must follow:
/// - Use `useMaterial3: true`.
/// - Consume `ColorScheme` from `color_schemes.dart`.
/// - Keep typography through `AppTypography`.
/// - Keep component defaults (card/appbar/icon) here, not in feature widgets.
///
/// Forbidden:
/// - Hardcoded widget-level colors/sizes in feature UI when Theme can provide.
/// - Reintroducing legacy `primaryColor`-style theming.
/// - Per-screen theme forks inside feature folders.
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
      cardTheme: _buildCardTheme(colorScheme),
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
          size: AppSizes.size24,
        ),
        toolbarHeight: AppSizes.size72,
      ),
      iconTheme: IconThemeData(
        size: AppSizes.size24,
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
      cardTheme: _buildCardTheme(colorScheme),
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
          size: AppSizes.size24,
        ),
        toolbarHeight: AppSizes.size72,
      ),
      iconTheme: IconThemeData(
        size: AppSizes.size24,
        color: colorScheme.onSurface,
      ),
    );
  }

  static CardThemeData _buildCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: colorScheme.shadow,
      surfaceTintColor: colorScheme.surfaceTint,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}
