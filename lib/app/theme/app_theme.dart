import 'package:flutter/material.dart';

import '../../common/styles/app_sizes.dart';
import 'color_schemes.dart';
import 'typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: AppTypography.textTheme(),
      scaffoldBackgroundColor: lightColorScheme.surface,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: AppSizes.size72,
      ),
      iconTheme: const IconThemeData(size: AppSizes.spacingLg),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: AppTypography.textTheme(),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: AppSizes.size72,
      ),
      iconTheme: const IconThemeData(size: AppSizes.spacingLg),
    );
  }
}
