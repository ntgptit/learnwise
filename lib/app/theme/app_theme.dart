// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
// theme-guard: allow-no-dynamic-color - static palette is intentionally used.
import 'package:flutter/material.dart';

import '../../common/styles/app_opacities.dart';
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
    final ColorScheme colorScheme = buildLightColorScheme();
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
      filledButtonTheme: _buildFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: AppSizes.size1,
        space: AppSizes.spacingXs,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
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
    final ColorScheme colorScheme = buildDarkColorScheme();
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
      filledButtonTheme: _buildFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: AppSizes.size1,
        space: AppSizes.spacingXs,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
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
    final Color cardBackgroundColor = _resolveCardBackgroundColor(colorScheme);
    return CardThemeData(
      color: cardBackgroundColor,
      elevation: 0,
      shadowColor: colorScheme.shadow,
      surfaceTintColor: colorScheme.surfaceTint,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }

  static Color _resolveCardBackgroundColor(ColorScheme colorScheme) {
    if (colorScheme.brightness == Brightness.dark) {
      return colorScheme.surfaceContainer;
    }
    return colorScheme.surfaceContainerLow;
  }

  static FilledButtonThemeData _buildFilledButtonTheme(
    ColorScheme colorScheme,
  ) {
    return FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: AppOpacities.soft12);
          }
          return colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: AppOpacities.disabled38);
          }
          return colorScheme.onPrimary;
        }),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: AppOpacities.disabled38);
          }
          return colorScheme.primary;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: colorScheme.onSurface.withValues(alpha: AppOpacities.soft12),
            );
          }
          return BorderSide(color: colorScheme.primary);
        }),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    final OutlineInputBorder base = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: colorScheme.outline),
    );
    return InputDecorationTheme(
      border: base,
      enabledBorder: base,
      focusedBorder: base.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: AppSizes.size2),
      ),
      errorBorder: base.copyWith(
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: base.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: AppSizes.size2),
      ),
      disabledBorder: base.copyWith(
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: AppOpacities.muted55),
        ),
      ),
    );
  }
}
